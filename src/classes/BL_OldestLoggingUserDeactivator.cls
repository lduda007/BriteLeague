public with sharing class BL_OldestLoggingUserDeactivator implements Queueable{
    public BL_OldestLoggingUserDeactivator(){

    }

    public void execute(QueueableContext context) {
        BL_UserActivationManager.deactivateLastLoggingUser('');
    }
}