/**
 * @author Mateusz Przywara
 * @date   2016-10-12
 * @description DAO class - Data Access Object for CollaborationGroup(Chatter Group)
 */
public class BTN_DAO_CollaborationGroup extends BTN_DAO {
   /**
     * @author Mateusz Przywara
     * @date   2016-10-12
     * @description Constructor
    */
    public BTN_DAO_CollaborationGroup() {
    }

    public override Schema.SObjectType getSObjectType() {
        return CollaborationGroup.sObjectType;
    }

    // Network Id is Community Id
    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                CollaborationGroup.Id,
                CollaborationGroup.Name,
                CollaborationGroup.NetworkId

        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-10-12
         * @description find Group with provided Developer Name
         * @return Group
        */
    public CollaborationGroup findGroupByName(String groupName) {
        List<CollaborationGroup> objects = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('Name', '=', groupName)
                }
        );
        return objects.isEmpty() ? null : objects.get(0);
    }
}