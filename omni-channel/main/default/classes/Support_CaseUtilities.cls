/**
 * @author Rémi Le Guin
 * @date 14/06/2020
 * @description Utility class for the Case standard object for Support.
 */
public with sharing class Support_CaseUtilities implements Callable {

    public static final Map<String, Schema.RecordTypeInfo> CASERECORDTYPEINFOSBYDEVELOPERNAME = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    public static final Id RECORDTYPEID_SUPPORT_COMPLAINTS = caseRecordTypeInfosByDeveloperName.get('Support_Complaints') == null ? null :
                                                             caseRecordTypeInfosByDeveloperName.get('Support_Complaints').getRecordTypeId();
    public static final Id RECORDTYPEID_SUPPORT_MAJORACCOUNTS = caseRecordTypeInfosByDeveloperName.get('Support_MajorAccounts') == null ? null :
                                                                caseRecordTypeInfosByDeveloperName.get('Support_MajorAccounts').getRecordTypeId();
    public static final Id RECORDTYPEID_SUPPORT_PUBLICDEALS = caseRecordTypeInfosByDeveloperName.get('Support_PublicDeals') == null ? null :
                                                              caseRecordTypeInfosByDeveloperName.get('Support_PublicDeals').getRecordTypeId();
    public static final Id RECORDTYPEID_SUPPORT_RESTITUTIONS = caseRecordTypeInfosByDeveloperName.get('Support_Restitutions') == null ? null :
                                                               caseRecordTypeInfosByDeveloperName.get('Support_Restitutions').getRecordTypeId();
    public static final Id RECORDTYPEID_SUPPORT_SERVICES = caseRecordTypeInfosByDeveloperName.get('Support_Services') == null ? null :
                                                           caseRecordTypeInfosByDeveloperName.get('Support_Services').getRecordTypeId();

    public static final Map<Id, Group> SUPPORT_QUEUESBYID = getQueuesByIds('Support_%');
    public static final Map<String, Group> SUPPORT_QUEUESBYDEVELOPERNAME = SUPPORT_QUEUESBYID == null ? null :
                                                                           getQueuesByDeveloperNames(SUPPORT_QUEUESBYID.values());

    /**
     * @description Get queues by IDs.
     * @param developerNameWildcard Developer name for one or several queues using wildcard, to use in a 'LIKE' SOQL clause.
     * @return A map of queues by IDs.
     */
    private static Map<Id, Group> getQueuesByIds(String developerNameWildcard) {
        Map<Id, Group> queuesByIds = new Map<Id, Group> ();
        try {
            queuesByIds = new Map<Id, Group> ([SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName LIKE :developerNameWildcard]);
        }
        catch(QueryException e) {
            if (e.getMessage() != 'List has no rows for assignment to SObject') {
                throw e;
            }
        }
        return queuesByIds.isEmpty() ? null : queuesByIds;
    }

    /**
     * @description Get queues by developer names.
     * @param queues A list of groups of type queue.
     * @return A map of queues by developer names.
     */
    private static Map<String, Group> getQueuesByDeveloperNames(List<Group> queues) {
        Map<String, Group> queuesByDeveloperNames = new Map<String, Group> ();
        if (queues != null) {
            for (Group queue : queues) {
                queuesByDeveloperNames.put(queue.DeveloperName, queue);
            }
        }
        return queuesByDeveloperNames.isEmpty() ? null : queuesByDeveloperNames;
    }

    /**
     * @description Provides functionality that other classes or packages can utilize and build upon.
     * @param action The behavior for the method to exhibit.
     * @param arguments Arguments to be used by the specified action.
     * @return The result of the method invocation.
     */
    public Object call(String action, Map<String, Object> arguments) {
        switch on action {
            when 'RECORDTYPEID_SUPPORT_COMPLAINTS' {
                return RECORDTYPEID_SUPPORT_COMPLAINTS;
            }
            when 'RECORDTYPEID_SUPPORT_MAJORACCOUNTS' {
                return RECORDTYPEID_SUPPORT_MAJORACCOUNTS;
            }
            when 'RECORDTYPEID_SUPPORT_PUBLICDEALS' {
                return RECORDTYPEID_SUPPORT_PUBLICDEALS;
            }
            when 'RECORDTYPEID_SUPPORT_RESTITUTIONS' {
                return RECORDTYPEID_SUPPORT_RESTITUTIONS;
            }
            when 'RECORDTYPEID_SUPPORT_SERVICES' {
                return RECORDTYPEID_SUPPORT_SERVICES;
            }
            when 'SUPPORT_QUEUESBYID' {
                return SUPPORT_QUEUESBYID;
            }
            when 'SUPPORT_QUEUESBYDEVELOPERNAME' {
                return SUPPORT_QUEUESBYDEVELOPERNAME;
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