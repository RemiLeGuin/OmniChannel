trigger OC_SkillAfterInsert on OC_Skill__c (after insert) {
    Callable ocSkillCalloutsClass = Type.forName('OC_SkillCallouts') == null ? null :
                                    (Callable)Type.forName('OC_SkillCallouts').newInstance();
    if (ocSkillCalloutsClass != null) {
        ocSkillCalloutsClass.call('createStandardSkills', new Map<String, Object> { 'skills' => Trigger.new });
    }
}