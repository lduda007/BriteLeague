public class BL_CompetitionProgressChartController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(String competitionId) {
        InitDataWrapper wrapper = new InitDataWrapper();
        try {
            Map<String, DataSet> teamIdToDataSet = new Map<String, DataSet>();

            for(BL_Match__c match : [
                    SELECT Id, Team1__c, Team1__r.Team__r.Name, Team2__c, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c
                    FROM BL_Match__c
                    WHERE League__c = :competitionId
                    AND isResolved__c = true
                    ORDER BY MatchDate__c ASC
            ]) {
                if(!teamIdToDataSet.containsKey(match.Team1__c)) {
                    teamIdToDataSet.put(match.Team1__c, new DataSet(match.Team1__r.Team__r.Name));
                    teamIdToDataSet.get(match.Team1__c).data.add(0);
                }
                if(!teamIdToDataSet.containsKey(match.Team2__c)) {
                    teamIdToDataSet.put(match.Team2__c, new DataSet(match.Team2__r.Team__r.Name));
                    teamIdToDataSet.get(match.Team2__c).data.add(0);
                }

                DataSet team1DataSet = teamIdToDataSet.get(match.Team1__c);
                DataSet team2DataSet = teamIdToDataSet.get(match.Team2__c);

                Integer team1Points = getPointsByScore(Integer.valueOf(match.Team1_Score__c));
                Integer team2Points = getPointsByScore(Integer.valueOf(match.Team2_Score__c));

                team1Points += team1DataSet.data[team1DataSet.data.size() - 1];
                team2Points += team2DataSet.data[team2DataSet.data.size() - 1];

                team1DataSet.data.add(team1Points);
                team2DataSet.data.add(team2Points);
            }

            wrapper.labels.addAll(prepareLabels(competitionId, new List<String>(teamIdToDataSet.keySet())[0]));
            wrapper.dataSets.addAll(teamIdToDataSet.values());
        } catch(Exception e) {
            AuraHandledException ae = new AuraHandledException(e.getMessage());
            ae.setMessage(e.getMessage());
            throw ae;
        }
        return wrapper;
    }

    private static Integer getPointsByScore(Integer score) {
        if(score == 0) {
            return 0;
        } else if(score == 1) {
            return 1;
        } else if(score == 2) {
            return 3;
        } else {
            return null;
        }
    }

    private static List<String> prepareLabels(String competitionId, String competitorId) {
        Integer numberOfMatches = [
                SELECT COUNT()
                FROM BL_Match__c
                WHERE League__c = :competitionId
                AND (
                        Team1__c = :competitorId
                        OR Team2__c = :competitorId
                )
        ];

        List<String> labels = new List<String>();
        for(Integer i = 0; i <= numberOfMatches; i++) {
            labels.add(String.valueOf(i));
        }

        return labels;
    }

    private static String getRandomHexColor() {
        Integer intColor = Integer.valueOf(Math.floor(Math.random() * 16777215));

        String [] digits = new String[] {
                '0' , '1' , '2' , '3' , '4' , '5' ,
                '6' , '7' , '8' , '9' , 'a' , 'b' ,
                'c' , 'd' , 'e' , 'f' , 'g' , 'h' ,
                'i' , 'j' , 'k' , 'l' , 'm' , 'n' ,
                'o' , 'p' , 'q' , 'r' , 's' , 't' ,
                'u' , 'v' , 'w' , 'x' , 'y' , 'z'
        };
        Integer shift = 4;

        String[] buf = new String[32];
        Integer charPos = 32;
        Integer radix = 1 << shift;
        Integer mask = radix - 1;
        do {
            buf[--charPos] = digits[intColor & mask];
            intColor >>>= shift;
        } while (intColor != 0);

        String result = '#';
        for (Integer pos = charPos; pos < 32; pos++) result += buf[pos];
        return result;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public List<String> labels = new List<String>();
        @AuraEnabled
        public List<DataSet> dataSets = new List<DataSet>();
    }

    public class DataSet {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<Integer> data = new List<Integer>();
        @AuraEnabled
        public Decimal lineTension = 0.25;
        @AuraEnabled
        public Boolean fill = false;
        @AuraEnabled
        public String borderColor = getRandomHexColor();

        public DataSet(String label) {
            this.label = label;
        }
    }
}