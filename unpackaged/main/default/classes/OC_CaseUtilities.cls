/**
 * @author Rémi Le Guin
 * @date 14/06/2020
 * @description Utility class for the Case standard object for Omni-Channel package.
 */
public with sharing class OC_CaseUtilities implements Callable {

    public static final Map<String, Schema.RecordTypeInfo> CASERECORDTYPEINFOSBYDEVELOPERNAME = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    public static final Id RECORDTYPEID_OC_COMPLAINTS = caseRecordTypeInfosByDeveloperName.get('OC_Complaints') == null ? null :
                                                        caseRecordTypeInfosByDeveloperName.get('OC_Complaints').getRecordTypeId();
    public static final Id RECORDTYPEID_OC_MAJORACCOUNTS = caseRecordTypeInfosByDeveloperName.get('OC_MajorAccounts') == null ? null :
                                                           caseRecordTypeInfosByDeveloperName.get('OC_MajorAccounts').getRecordTypeId();
    public static final Id RECORDTYPEID_OC_PUBLICDEALS = caseRecordTypeInfosByDeveloperName.get('OC_PublicDeals') == null ? null :
                                                         caseRecordTypeInfosByDeveloperName.get('OC_PublicDeals').getRecordTypeId();
    public static final Id RECORDTYPEID_OC_RESTITUTIONS = caseRecordTypeInfosByDeveloperName.get('OC_Restitutions') == null ? null :
                                                          caseRecordTypeInfosByDeveloperName.get('OC_Restitutions').getRecordTypeId();
    public static final Id RECORDTYPEID_OC_SERVICES = caseRecordTypeInfosByDeveloperName.get('OC_Services') == null ? null :
                                                      caseRecordTypeInfosByDeveloperName.get('OC_Services').getRecordTypeId();

    public static final Map<Id, Group> OC_QUEUESBYID = getQueuesByIds('OC_%');
    public static final Map<String, Group> OC_QUEUESBYDEVELOPERNAME = OC_QUEUESBYID == null ? null :
                                                                      getQueuesByDeveloperNames(OC_QUEUESBYID.values());

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
            when 'RECORDTYPEID_OC_COMPLAINTS' {
                return RECORDTYPEID_OC_COMPLAINTS;
            }
            when 'RECORDTYPEID_OC_MAJORACCOUNTS' {
                return RECORDTYPEID_OC_MAJORACCOUNTS;
            }
            when 'RECORDTYPEID_OC_PUBLICDEALS' {
                return RECORDTYPEID_OC_PUBLICDEALS;
            }
            when 'RECORDTYPEID_OC_RESTITUTIONS' {
                return RECORDTYPEID_OC_RESTITUTIONS;
            }
            when 'RECORDTYPEID_OC_SERVICES' {
                return RECORDTYPEID_OC_SERVICES;
            }
            when 'OC_QUEUESBYID' {
                return OC_QUEUESBYID;
            }
            when 'OC_QUEUESBYDEVELOPERNAME' {
                return OC_QUEUESBYDEVELOPERNAME;
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