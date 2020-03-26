public with sharing class BL_TeamRecordDetailController {
    @AuraEnabled
    public static String getUserContactId() {
        return BL_Utils.getCurrentUser().ContactId;
    }

    @AuraEnabled
    public static BL_Team__c loadTeamStatistics(String teamId) {
        List<BL_Team__c> teamStatistics = [
                SELECT Id, Total_Games_Won__c, Total_Games_Drawn__c, Total_Games_Lost__c, Total_Goals_Scored__c, Total_Goals_Lost__c, TotalRoundsWon__c, TotalRoundsLost__c
                FROM BL_Team__c
                WHERE Id = :teamId
        ];
        return teamStatistics.isEmpty() ? new BL_Team__c() : teamStatistics[0];
    }

    @AuraEnabled
    public static List<BL_Competition__c> getTeamCompetitions(String teamId) {
        List<String> compsIds = new List<String>();
        for (BL_Competitor__c comp : [SELECT Id, League__c FROM BL_Competitor__c WHERE Team__c = :teamId]) {
            compsIds.add(comp.League__c);
        }
        return [
                SELECT RecordType.DeveloperName, Start_Date__c, End_Date__c, Name
                FROM BL_Competition__c
                WHERE Id IN :compsIds
        ];
    }

    @AuraEnabled
    public static List<BL_TeamMember__c> getTeamMembers(String teamId) {
        List<BL_TeamMember__c> teamMembers = [
                SELECT Id, Member__r.Name, Member__r.Player1__r.Name, Member__r.Player2__r.Name,
                        Member__r.Player1__r.LastName, Member__r.Player2__r.LastName,
                        Member__r.Player1__r.ImageUrl__c, Member__r.Player2__r.ImageUrl__c
                FROM BL_TeamMember__c
                WHERE Team__c = :teamId
                ORDER BY Member__r.Name
        ];

        return teamMembers;
    }

    @AuraEnabled
    public static List<BL_TeamMember__c > getParentTeams(String teamId) {
        List<BL_TeamMember__c> parentTeams = [
                SELECT Id, Team__r.Name, Team__r.Player1__r.Name, Team__r.Team_Member_Count__c
                FROM BL_TeamMember__c
                WHERE Member__c = :teamId
        ];
        return parentTeams;
    }

    @AuraEnabled
    public static void addTeamMembers(Id parentTeamId, List<Id> memberTeamsIds) {
        List<BL_TeamMember__c> newTeamMembers = new List<BL_TeamMember__c>();
        for (Id memberId : memberTeamsIds) {
            newTeamMembers.add(new BL_TeamMember__c(
                    Member__c = memberId,
                    Team__c = parentTeamId
            ));
        }
        insert newTeamMembers;
    }

    @AuraEnabled
    public static void removeTeamMember(Id parentTeamId, Id teamMemberId) {
        BL_TeamMember__c memberToDelete = new BL_TeamMember__c(Id = teamMemberId);
        delete memberToDelete;
    }

    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {
        List<Attachment> att = [
                SELECT Id, Name, LastModifiedDate, ContentType
                FROM Attachment
                WHERE parentid = :ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif')
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];
        if(att.size() > 0) {
            return att[0];
        } else return new Attachment();
    }

    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        try {
            if(String.isBlank(fileId)) {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
        } catch(Exception e) {
            String uiMessage = 'An error occurred during saving the file: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return Id.valueOf(fileId);
    }

    private static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        delete [SELECT Id FROM Attachment WHERE ParentId = :parentId];

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = new Attachment(
                ParentId = parentId,
                Name = fileName,
                Body = EncodingUtil.base64Decode(base64Data),
                ContentType = contentType
        );
        insert a;
        return a.Id;
    }

    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = [
                SELECT Id, Body
                FROM Attachment
                WHERE Id = :fileId
        ];

        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
    }
}