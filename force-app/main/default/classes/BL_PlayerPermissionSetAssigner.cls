public with sharing class BL_PlayerPermissionSetAssigner implements Queueable{
    private String userId;

    public BL_PlayerPermissionSetAssigner(String userId){
        this.userId = userId;
    }

    public void execute(QueueableContext context) {
        BL_UserActivationManager.assignPlayerPermissionSet(userId);
    }
}