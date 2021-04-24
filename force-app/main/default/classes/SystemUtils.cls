/**
 * System Utils methods
 * @author Adam Siwek
 */
public with sharing class SystemUtils {

    private static Map<String, Map<String, RecordType>> recordTypeMap = new Map<String, Map<String, RecordType>>();
    private static Map<String, RecordType> recordTypes = null;

    public static RecordType loadAndGetRecordType(String objectType, String rtDevName) {
        if (!recordTypeMap.containsKey(objectType)) {
            recordTypeMap.put(objectType, new Map<String, RecordType>());
            for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = :objectType]) {
                recordTypeMap.get(objectType).put(rt.DeveloperName, rt);
            }
        }
        return recordTypeMap.get(objectType).get(rtDevName);
    }

    public static Map<String,RecordType> loadAndGetRecordTypes(String objectType) {
        if (recordTypes == null) {
            recordTypes = new Map<String,RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = :objectType]);
        }
        return recordTypes;
    }

    public interface Builder { 
         SObject build();
         SObject buildAndSave();
    }

    public with sharing class SystemException extends Exception {
    }
}