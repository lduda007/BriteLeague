public class BTN_GoogleSidebarController{
    
    public boolean integrated {get;set;}

    public BTN_GoogleSidebarController(){
        BTN_DAO_User userDao = new BTN_DAO_User();
        userDao.addGoogleFields();
        User currUser = userDao.findUserById(UserInfo.getUserId());
        integrated = currUser.GoogleRefreshToken__c !=null;
    }
}