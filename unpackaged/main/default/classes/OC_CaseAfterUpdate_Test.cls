/**
 * @author Rémi Le Guin
 * @date 22/06/2020
 * @description In construction.
 */
@IsTest
private class OC_CaseAfterUpdate_Test {

    /**
     * @description Data setup for the test class.
     */
    @TestSetup
    private static void setup() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Utilisateur standard' LIMIT 1][0].Id;
        Id permissionId = [SELECT Id FROM PermissionSet WHERE Name = 'OC_Agent' LIMIT 1][0].Id;
        User testAgent = new User(Firstname = 'Agent', LastName = 'Test', alias = 'agent', ProfileId = profileId,
                                  Email = 'agent.test@caseafterupdate.com', Username = 'agent.test@caseafterupdate.com',
                                  TimeZoneSidKey = 'Europe/Paris', EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'fr', LocaleSidKey = 'fr_FR');
        insert testAgent;
        insert new PermissionSetAssignment (PermissionSetId = permissionId, AssigneeId = testAgent.Id);
    }

    /**
     * @description Test a Public Deals Case update.
     */
    @IsTest
    private static void caseAfterUpdate_Test() {
        User agentUser = [SELECT Id FROM User WHERE Username = 'agent.test@caseafterupdate.com' LIMIT 1];
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'OC_PublicDeals_Unassigned' LIMIT 1].Id;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OC_PublicDeals').getRecordTypeId();
        Case cs = new Case(Origin = 'Email', OwnerId = queueId, Reason = 'OC - Test', RecordTypeId = recordTypeId);
        insert cs;
        queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'OC_PublicDeals_Assigned' LIMIT 1].Id;

        Test.startTest();
        System.runAs(agentUser) {
            cs.OwnerId = queueId;
            update cs;
        }
        Test.stopTest();
    }

}