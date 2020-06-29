/**
 * @author Rémi Le Guin
 * @date 14/06/2020
 * @description Handler class for Cases skills-based routing with Omni-channel for Omni-Channel package.
 */
public with sharing class OC_CaseSkillsBasedRoutingHandler implements Callable {

    private static final Id OC_SERVICECHANNELID = getServiceChannelId('OmniChannel');
    private static final Map<String, Skill> SKILLSBYLABEL = getSkillsByLabel();
    private static final Map<String, QueueRoutingConfig> OC_QUEUEROUTINGCONFIGSBYDEVELOPERNAME = getQueueRoutingConfigsByDeveloperName('OC_%');

    /**
     * @description Create a PendingServiceRouting record for each Case belonging to the Public Deals queue.
     * @param cases A list of Cases belonging to the Public Deals queue.
     * @return A message stating the method execution.
     */
    private static String createPublicDealsPendingServiceRouting(List<Case> cases) {

        Map<Id, PendingServiceRouting> pendingServiceRoutingsByCaseId = new Map<Id, PendingServiceRouting> ();
        QueueRoutingConfig qrc = OC_QUEUEROUTINGCONFIGSBYDEVELOPERNAME.get('OC_PublicDeals');
        if (OC_SERVICECHANNELID != null && SKILLSBYLABEL != null && qrc != null) {

            for (Case cs : cases) {
                if (SKILLSBYLABEL.get(cs.Reason) != null) {
                    PendingServiceRouting psr = new PendingServiceRouting(CapacityWeight = 1,
                                                                          IsReadyForRouting = false,
                                                                          RoutingModel  = qrc.RoutingModel,
                                                                          RoutingPriority = qrc.RoutingPriority,
                                                                          RoutingType = 'SkillsBased',
                                                                          ServiceChannelId = OC_SERVICECHANNELID,
                                                                          WorkItemId = cs.Id,
                                                                          PushTimeout = qrc.PushTimeout
                                                                         );
                    pendingServiceRoutingsByCaseId.put(cs.Id, psr);
                }
            }
            if (!pendingServiceRoutingsByCaseId.isEmpty()) {
                insert pendingServiceRoutingsByCaseId.values();
            }

            List<SkillRequirement> skillRequirements = new List<SkillRequirement> ();
            for (Case cs : cases) {
                if (SKILLSBYLABEL.get(cs.Reason) != null) {
                    SkillRequirement skillReq = new SkillRequirement(RelatedRecordId = pendingServiceRoutingsByCaseId.get(cs.Id).Id,
                                                                     SkillId = SKILLSBYLABEL.get(cs.Reason).Id,
                                                                     SkillLevel = 1
                                                                    );
                    skillRequirements.add(skillReq);
                    pendingServiceRoutingsByCaseId.get(cs.Id).IsReadyForRouting = true;
                }
            }
            if (!skillRequirements.isEmpty() && !pendingServiceRoutingsByCaseId.isEmpty()) {
                insert skillRequirements;
                update pendingServiceRoutingsByCaseId.values();
            }

        }

        return 'Method executed: CaseRoutingHandler.createPublicDealsPendingServiceRouting';

    }

    /**
     * @description Get a single service channel ID thanks to its developer name.
     * @param developerName A service channel developer name.
     * @return A service channel Salesforce ID.
     */
    private static Id getServiceChannelId(String developerName) {
        ServiceChannel serviceChannel;
        if (String.isNotBlank(developerName)) {
            try {
                serviceChannel = [SELECT Id FROM ServiceChannel WHERE DeveloperName = :developerName LIMIT 1];
            }
            catch(QueryException e) {
                if (e.getMessage() != 'List has no rows for assignment to SObject') {
                    throw e;
                }
            }
        }
        return serviceChannel == null ? null : serviceChannel.Id;
    }

    /**
     * @description Get a single service channel ID thanks to its developer name.
     * @return A Map of all standard skills by master label.
     */
    private static Map<String, Skill> getSkillsByLabel() {
        Map<String, Skill> skillsByLabel = new Map<String, Skill> ();
        List<Skill> skills;
        try {
            skills = [SELECT Id, MasterLabel FROM Skill];
        }
        catch(QueryException e) {
            if (e.getMessage() != 'List has no rows for assignment to SObject') {
                throw e;
            }
        }
        if (skills != null) {
            for (Skill skl : skills) {
                skillsByLabel.put(skl.MasterLabel, skl);
            }
        }
        return skillsByLabel.isEmpty() ? null : skillsByLabel;
    }

    /**
     * @description Get QueueRoutingConfigs by developer names.
     * @param developerNameWildcard Developer name for one or several QueueRoutingConfigs using wildcard, to use in a 'LIKE' SOQL clause. If null, returns all QueueRoutingConfigs.
     * @return A map of QueueRoutingConfigs by developer name.
     */
    private static Map<String, QueueRoutingConfig> getQueueRoutingConfigsByDeveloperName(String developerNameWildcard) {
        Map<String, QueueRoutingConfig> queueRoutingConfigsByDeveloperName = new Map<String, QueueRoutingConfig> ();
        List<QueueRoutingConfig> queueRoutingConfigs;
        try {
            if (String.isBlank(developerNameWildcard)) {
                queueRoutingConfigs = [SELECT DeveloperName, PushTimeout, RoutingModel, RoutingPriority FROM QueueRoutingConfig];
            }
            else {
                queueRoutingConfigs = [SELECT DeveloperName, PushTimeout, RoutingModel, RoutingPriority
                                       FROM QueueRoutingConfig
                                       WHERE DeveloperName LIKE :developerNameWildcard];
            }
        }
        catch(QueryException e) {
            if (e.getMessage() != 'List has no rows for assignment to SObject') {
                throw e;
            }
        }
        if (queueRoutingConfigs != null) {
            for (QueueRoutingConfig qrc : queueRoutingConfigs) {
                queueRoutingConfigsByDeveloperName.put(qrc.DeveloperName, qrc);
            }
        }
        return queueRoutingConfigsByDeveloperName.isEmpty() ? null : queueRoutingConfigsByDeveloperName;
    }

    /**
     * @description Provides functionality that other classes or packages can utilize and build upon.
     * @param action The behavior for the method to exhibit.
     * @param arguments Arguments to be used by the specified action.
     * @return The result of the method invocation.
     */
    public Object call(String action, Map<String, Object> arguments) {
        switch on action {
            when 'createPublicDealsPendingServiceRouting' {
                return createPublicDealsPendingServiceRouting((List<Case>)arguments.get('cases'));
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
