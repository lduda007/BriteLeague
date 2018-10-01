public class BL_CompetitionProgressChartController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(String competitionId) {
        return new InitDataWrapper();
    }

    public class InitDataWrapper {

    }
}