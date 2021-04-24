public with sharing class TriggerFactory {

    public static void createHandler(Schema.sObjectType soType) {
        // Get a handler appropriate to the object being processed
        TriggerHandler handler = getHandler(soType);

        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null) {
            throw new BTN_Exception('No Trigger Handler registered for Object Type: ' + soType);
        }

        // Execute the handler to fulfil the trigger
        execute(handler);
    }

    private static void execute(TriggerHandler handler) {
        // Before Trigger
        if (Trigger.isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();

            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    handler.beforeDelete(so);
                }
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert) {
                for (SObject so : Trigger.new) {
                    handler.beforeInsert(so);
                }
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate) {
                for (SObject so : Trigger.old) {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        } else {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();

            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    handler.afterDelete(so);
                }
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert) {
                for (SObject so : Trigger.new) {
                    handler.afterInsert(so);
                }
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate) {
                for (SObject so : Trigger.old) {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }

        // Perform any post processing
        handler.andFinally();
    }

    private static TriggerHandler getHandler(Schema.sObjectType soType) {
        if (soType == BTN_Equipment__c.sObjectType) {
            return new BTN_EquipmentTriggerHandler();
        }
        return null;
    }
}