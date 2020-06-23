/**
 * @author Rémi Le Guin
 * @date 22/06/2020
 * @description In construction.
 */
@IsTest
private class OC_CaseAfterInsert_Test {

    /**
     * @description Data setup for the test class.
     */
    @TestSetup
    private static void setup() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrateur système' LIMIT 1][0].Id;
        Id permissionId = [SELECT Id FROM PermissionSet WHERE Name = 'OC_Agent' LIMIT 1][0].Id;
        User processingUser = new User(Firstname = 'Processing', LastName = 'User', alias = 'process', ProfileId = profileId,
                                       Email = 'processing.user@caseafterinsert.com', Username = 'processing.user@caseafterinsert.com',
                                       TimeZoneSidKey = 'Europe/Paris', EmailEncodingKey = 'UTF-8',
                                       LanguageLocaleKey = 'fr', LocaleSidKey = 'fr_FR');
        insert processingUser;
        insert new PermissionSetAssignment (PermissionSetId = permissionId, AssigneeId = processingUser.Id);
    }

    /**
     * @description Test a Public Deals Case insertion.
     */
    @IsTest
    private static void caseAfterInsert_Test() {
        User processingUser = [SELECT Id FROM User WHERE Username = 'processing.user@caseafterinsert.com' LIMIT 1];
        Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'OC_PublicDeals_Assigned' LIMIT 1].Id;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OC_PublicDeals').getRecordTypeId();

        Test.startTest();
        System.runAs(processingUser) {
            insert new Case(Origin = 'Email', OwnerId = queueId, Reason = 'OC - Test', RecordTypeId = recordTypeId);
        }
        Test.stopTest();
    }

}