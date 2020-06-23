trigger OC_CaseAfterInsert on Case (after insert) {
    Callable ocCaseUtilitiesClass = Type.forName('OC_CaseUtilities') == null ? null :
                                    (Callable)Type.forName('OC_CaseUtilities').newInstance();
    Callable ocCaseSkillsBasedRoutingHandlerClass = Type.forName('OC_CaseSkillsBasedRoutingHandler') == null ? null :
                                                    (Callable)Type.forName('OC_CaseSkillsBasedRoutingHandler').newInstance();
    List<Case> publicDealsCases = new List<Case> ();
    if (ocCaseUtilitiesClass != null) {
        Map<String, Group> queuesByDeveloperNames = (Map<String, Group>)ocCaseUtilitiesClass.call('OC_QUEUESBYDEVELOPERNAME', null);
        if (queuesByDeveloperNames != null && queuesByDeveloperNames.get('OC_PublicDeals_Assigned') != null) {
            for (Case cs : Trigger.new) {
                if (cs.OwnerId == queuesByDeveloperNames.get('OC_PublicDeals_Assigned').Id) {
                    publicDealsCases.add(cs);
                }
            }
        }
    }
    if (!publicDealsCases.isEmpty() && ocCaseSkillsBasedRoutingHandlerClass != null) {
        ocCaseSkillsBasedRoutingHandlerClass.call('createPublicDealsPendingServiceRouting', new Map<String, Object> { 'cases' => publicDealsCases });
    }
}