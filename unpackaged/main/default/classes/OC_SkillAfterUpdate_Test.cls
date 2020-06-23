/**
 * @author Rémi Le Guin
 * @date 22/06/2020
 * @description In construction.
 */
@IsTest
private class OC_SkillAfterUpdate_Test {

    /**
     * @description Data setup for the test class.
     */
    @TestSetup
    private static void setup() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Utilisateur standard' LIMIT 1][0].Id;
        Id permissionId = [SELECT Id FROM PermissionSet WHERE Name = 'OC_SkillManagement' LIMIT 1][0].Id;
        User skillManager = new User(Firstname = 'Skill', LastName = 'Manager', alias = 'skill', ProfileId = profileId,
                                     Email = 'skill.manager@skillafterupdate.com', Username = 'skill.manager@skillafterupdate.com',
                                     TimeZoneSidKey = 'Europe/Paris', EmailEncodingKey = 'UTF-8',
                                     LanguageLocaleKey = 'fr', LocaleSidKey = 'fr_FR');
        insert skillManager;
        insert new PermissionSetAssignment (PermissionSetId = permissionId, AssigneeId = skillManager.Id);
    }

    /**
     * @description Test a Skill__c update.
     */
    @IsTest
    private static void skillAfterUpdate_Test() {
        User skillManager = [SELECT Id FROM User WHERE Username = 'skill.manager@skillafterupdate.com' LIMIT 1];
        OC_Skill__c skill =  new OC_Skill__c(Name = 'Test1');
        insert skill;

        Test.setMock(HttpCalloutMock.class, new OC_SkillCallouts_Mock());
        Test.startTest();
        System.runAs(skillManager) {
            skill.Name = 'Test2';
            update skill;
        }
        Test.stopTest();
    }

}