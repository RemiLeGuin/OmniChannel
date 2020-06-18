trigger Support_CaseAfterInsert on Case (after insert) {
    Callable supportCaseUtilitiesClass = Type.forName('Support_CaseUtilities') == null ? null :
                                         (Callable)Type.forName('Support_CaseUtilities').newInstance();
    Callable supportCaseRoutingHandlerClass = Type.forName('Support_CaseRoutingHandler') == null ? null :
                                              (Callable)Type.forName('Support_CaseRoutingHandler').newInstance();
    List<Case> publicDealsCases = new List<Case> ();
    if (supportCaseUtilitiesClass != null) {
        Map<String, Group> queuesByDeveloperNames = (Map<String, Group>)supportCaseUtilitiesClass.call('SUPPORT_QUEUESBYDEVELOPERNAME', null);
        if (queuesByDeveloperNames != null && queuesByDeveloperNames.get('Support_PublicDeals_Assigned') != null) {
            for (Case cs : Trigger.new) {
                if (cs.OwnerId == queuesByDeveloperNames.get('Support_PublicDeals_Assigned').Id) {
                    publicDealsCases.add(cs);
                }
            }
        }
    }
    if (!publicDealsCases.isEmpty() && supportCaseRoutingHandlerClass != null) {
        supportCaseRoutingHandlerClass.call('createPublicDealsPendingServiceRouting', new Map<String, Object> { 'cases' => publicDealsCases });
    }
}