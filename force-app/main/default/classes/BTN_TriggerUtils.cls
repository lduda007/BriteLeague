/**
 * Created by zienkowm on 2016-11-19.
 */

public with sharing class BTN_TriggerUtils {

    public static Boolean skipTrigger(String triggerName) {
        if(triggerName != null && !triggerName.endsWith('__c')){
            triggerName += '__c'; //because we need API Name
        }
        try {
            final BTN_BriteCRM_TriggerException__c triggerSettings = BTN_BriteCRM_TriggerException__c.getInstance();
            return triggerSettings != null && Boolean.valueOf(String.valueOf(triggerSettings.get(triggerName)));
        } catch (SObjectException exSO) {
            // Do nothing field not defined in settings
        } catch (Exception ex) {
            System.debug('Error while determining if trigger ' + triggerName + ' should be skipped: ' + ex.getMessage());
        }
        return false;
    }
}