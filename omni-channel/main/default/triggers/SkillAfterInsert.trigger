trigger SkillAfterInsert on Skill__c (after insert) {
    Callable skillCalloutsClass = Type.forName('SkillCallouts') == null ? null :
                                  (Callable)Type.forName('SkillCallouts').newInstance();
    if (skillCalloutsClass != null) {
        skillCalloutsClass.call('createStandardSkills', new Map<String, Object> { 'skills' => Trigger.new });
    }
}