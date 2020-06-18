trigger SkillAfterUpdate on Skill__c (after update) {
    Callable skillCalloutsClass = Type.forName('SkillCallouts') == null ? null :
                                  (Callable)Type.forName('SkillCallouts').newInstance();
    if (skillCalloutsClass != null) {
        skillCalloutsClass.call('updateStandardSkills', new Map<String, Object> { 'skills' => Trigger.new,
                                                                                  'oldSkillsById' => Trigger.oldMap });
    }
}