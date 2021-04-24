/**
 * @author Mateusz Przywara
 * @date   2016-07-06
 * @description DAO class - Data Access Object for Record Type sObject
*/
public class BTN_DAO_RecordType extends BTN_DAO {
    private final static String RECORD_TYPE_OBJECT_NAME = 'RecordType';
    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor
    */
    public BTN_DAO_RecordType() {
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                RecordType.Id,
                RecordType.Name,
                RecordType.DeveloperName,
                RecordType.SobjectType
        };
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description getSObjectName method - provides sObject api name from sObject type
     * @return API qualified object nama
    */
    public override Schema.SObjectType getSObjectType() {
        return new RecordType().getSObjectType();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-13
     * @description find Record Types for specified sObjects
     * @return List<RecordType> - found Record Types in arranged List
    */
    public List<RecordType> findRecordTypesForSObjectSet(Set<String> sObjectType) {
        return (List<RecordType>) findSObjectsBy(
                                            new List<SearchCondition>{
                                                new SearchCondition('SobjectType', 'IN', sObjectType)
                                            }
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-13
     * @description find Record Types for specified sObject
     * @return List<RecordType> - found Record Types in arranged List
    */
    public List<RecordType> findCaseRecordTypes() {
        return (List<RecordType>) findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('SobjectType', '=', Case.getSObjectType().getDescribe().getName()),
                        new SearchCondition('AND IsActive = true')
                }
        );
    }
}