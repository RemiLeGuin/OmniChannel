/**
 * @author Rémi Le Guin
 * @date 14/06/2020
 * @description Class to insert or update standard Skills using REST API when custom Skill__c are created or edited.
 */
public with sharing class SkillCallouts implements Database.AllowsCallouts, Callable, Queueable {

    private String method;
    private String endpoint;
    private String jsonBody;

    public SkillCallouts() {}

    public SkillCallouts(String method, String endpoint, String jsonBody) {
        this.method = method;
        this.endpoint = endpoint;
        this.jsonBody = jsonBody;
    }

    public void execute(QueueableContext context) {
        makeCallout(method, endpoint, jsonBody);
    }

    /**
     * @description Insert a standard skill using REST API based on a custom Skill__c.
     * @param skills A list of custom skills.
     * @return A message stating the method execution.
     */
    private static String createStandardSkills(List<Skill__c> skills) {
        List<String> jsonSkills = new List<String> ();
        for (Integer i=0; i < skills.size(); i++) {
            String description = String.isBlank(skills[i].Description__c) ? '' : skills[i].Description__c;
            jsonSkills.add('{"attributes":{"type":"Skill","referenceId":"' + i + '"},'
                           + '"Description":"' + description + '"'
                           + ',"DeveloperName":"' + skills[i].Name.replaceAll('[^a-zA-Z0-9\\\\s+]', '_').removeEnd('_') + '"'
                           + ',"MasterLabel":"' + skills[i].Name + '"}');
        }
        String jsonBody = '{"records":[' + String.join(jsonSkills, ',') + ']}';
        System.enqueueJob(new SkillCallouts('POST', '/services/data/v49.0/composite/tree/Skill', jsonBody));
        return 'Method executed: SkillCallouts.createStandardSkills';
    }

    /**
     * @description Update a standard skill using REST API based on a custom Skill__c.
     * @param skills A list of custom skills.
     * @param skills A Map of old versions of cases by ID.
     * @return A message stating the method execution.
     */
    private static String updateStandardSkills(List<Skill__c> skills, Map<Id, Skill__c> oldSkillsById) {
        Set<String> skillDeveloperNames = new Set<String> ();
        for (Skill__c oldSkl : oldSkillsById.values()) {
            skillDeveloperNames.add(oldSkl.Name.replaceAll('[^a-zA-Z0-9\\\\s+]', '_').removeEnd('_'));
        }
        Map<String, Id> standardSkillIdsByDeveloperName = new Map<String, Id> ();
        Map<Id, Skill> standardSkillsByIds = getStandardSkillsByIds(skillDeveloperNames);
        if (standardSkillsByIds != null && !standardSkillsByIds.isEmpty()) {
            for (Skill standardSkill : standardSkillsByIds.values()) {
                standardSkillIdsByDeveloperName.put(standardSkill.DeveloperName, standardSkill.Id);
            }
        }
        List<String> jsonSkills = new List<String> ();
        for (Skill__c skl : skills) {
            String description = String.isBlank(skl.Description__c) ? '' : skl.Description__c;
            jsonSkills.add('{"attributes":{"type":"Skill"},'
                           + '"id":"' + standardSkillIdsByDeveloperName.get(oldSkillsById.get(skl.Id).Name.replaceAll('[^a-zA-Z0-9\\\\s+]', '_').removeEnd('_')) + '"'
                           + ',"Description":"' + description + '"'
                           + ',"DeveloperName":"' + skl.Name.replaceAll('[^a-zA-Z0-9\\\\s+]', '_').removeEnd('_') + '"'
                           + ',"MasterLabel":"' + skl.Name + '"}');
        }
        String jsonBody = '{"allOrNone":true,"records":[' + String.join(jsonSkills, ',') + ']}';
        System.enqueueJob(new SkillCallouts('PATCH', '/services/data/v49.0/composite/sobjects', jsonBody));
        return 'Method executed: SkillCallouts.updateStandardSkills';
    }

    /**
     * @description Get standard skills by IDs.
     * @param skillDeveloperNames Developer names for one or several standard skills, to use in a 'IN' SOQL clause.
     * @return A map of standard skills by IDs.
     */
    private static Map<Id, Skill> getStandardSkillsByIds(Set<String> skillDeveloperNames) {
        Map<Id, Skill> skillsByIds = new Map<Id, Skill> ();
        try {
            skillsByIds = new Map<Id, Skill> ([SELECT Id, DeveloperName FROM Skill WHERE DeveloperName IN :skillDeveloperNames]);
        }
        catch(QueryException e) {
            if (e.getMessage() != 'List has no rows for assignment to SObject') {
                throw e;
            }
        }
        return skillsByIds.isEmpty() ? null : skillsByIds;
    }

    /**
     * @description Perform a callout to the actual Salesforce instance using the REST API using the user's session ID to authenticate.
     * @param method The REST method to use (GET, POST, PATCH...).
     * @param endpoint The path to use. Not the complete endpoint, just the path after the instance's base URL.
     * @param jsonBody JSON body for the callout.
     * @return The raw callout response.
     */
    private static HttpResponse makeCallout(String method, String endpoint, String jsonBody) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setBody(jsonBody);
        return new Http().send(request);
    }

    /**
     * @description Provides functionality that other classes or packages can utilize and build upon.
     * @param action The behavior for the method to exhibit.
     * @param arguments Arguments to be used by the specified action.
     * @return The result of the method invocation.
     */
    public Object call(String action, Map<String, Object> arguments) {
        switch on action {
            when 'createStandardSkills' {
                return createStandardSkills((List<Skill__c>)arguments.get('skills'));
            }
            when 'updateStandardSkills' {
                return updateStandardSkills((List<Skill__c>)arguments.get('skills'),
                                            (Map<Id, Skill__c>)arguments.get('oldSkillsById'));
            }
            when else {
                throw new ExtensionMalformedCallException('Method not implemented');
            }
        }
    }

    /**
     * @description Throws new exceptions.
     */
    public class ExtensionMalformedCallException extends Exception {}

}