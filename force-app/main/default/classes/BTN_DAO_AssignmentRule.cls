/**
 * @author Mateusz Przywara
 * @date   2016-09-01
 * @description DAO class - Data Access Object for Assignment Rule
 */
public with sharing class BTN_DAO_AssignmentRule extends BTN_DAO {

    public override Schema.SObjectType getSObjectType() {
        return AssignmentRule.getsObjectType();
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                AssignmentRule.Id
        };
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-01
     * @description findCaseAssignmentRule Find Assignment Rule for Case
     * @return List<Case> - found Cases in arranged List
    */
    public AssignmentRule findCaseAssignmentRule() {
        List<Object> objects = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('Active = true'),
                        new SearchCondition('AND SobjectType = \'Case\'')
                }
        );
        return objects.isEmpty() ? null : (AssignmentRule) objects.get(0);
    }
}