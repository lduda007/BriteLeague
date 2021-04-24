/**
 * @author Mateusz Przywara
 * @date   2016-10-24
 * @description BTN_DAO_SearchFragment
*/
public class BTN_DAO_SearchFragment extends BTN_DAO {

    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description Constructor
    */
    public BTN_DAO_SearchFragment() {}

    public override Schema.SObjectType getSObjectType() {
        return BTN_SearchFragment__c.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_SearchFragment__c.Id
        };
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description find Fragments for specified Ids
     * @param contactIds Set of Contact Ids
     * @return List<BTN_SearchFragment__c> - found BTN_SearchFragment__c in List
    */
    public List<BTN_SearchFragment__c> findSearchFragmentsForContact(Set<Id> contactIds) {
        return (List<BTN_SearchFragment__c>) findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('Contact__c', 'IN', contactIds)
                }
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description findContactsWithSearchFragments
     * @return List<BTN_SearchFragment__c> - found BTN_SearchFragment__c in List
    */
    public List<AggregateResult> findContactsWithSearchFragments(List<String> searchInTextParams) {
        currentFields.clear();
        currentFields.add('Contact__r.Id');
        groupByClause = 'Contact__r.Id HAVING count(Id) >= 1';
        orderClause = 'count(Id) desc';
        //SELECT Contact__r.Id, count(Id) FROM BTN_SearchFragment__c WHERE TextPart__c LIKE '%ziemnaki22%' OR TextPart__c LIKE '%werbalna22%' OR TextPart__c LIKE '%cras%' GROUP BY Contact__r.Id HAVING count(Id) >= 1 ORDER BY count(Id) desc
        List<SearchCondition> searchConditions = new List<SearchCondition>();
        Integer indx = 0;
        String  tmp;
        for (String searchParam : searchInTextParams) {
            if (indx != 0) {
                tmp = ' OR';
            } else {
                tmp = '';
            }
            tmp += ' TextPart__c LIKE \'%' + searchParam + '%\'';
            searchConditions.add(new SearchCondition(tmp));
            indx++;
        }
        return groupSObjectsBy(
                searchConditions
        );
    }
}