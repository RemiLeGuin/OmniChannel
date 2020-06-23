trigger OC_SkillAfterUpdate on OC_Skill__c (after update) {
    Callable ocSkillCalloutsClass = Type.forName('OC_SkillCallouts') == null ? null :
                                    (Callable)Type.forName('OC_SkillCallouts').newInstance();
    if (ocSkillCalloutsClass != null) {
        ocSkillCalloutsClass.call('updateStandardSkills', new Map<String, Object> { 'skills' => Trigger.new,
                                                                                    'oldSkillsById' => Trigger.oldMap });
    }
}