public class BL_UserSettings {

    @AuraEnabled
    public Id userId;

    public BL_UserSettings() {
        this.userId = UserInfo.getUserId();
    }
}