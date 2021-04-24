/**
 * @author Mateusz Przywara
 * @date   2016-07-05
 * @description DAO class - Data Access Object
 */
public virtual class BTN_DAO {
    private static final String OPERATOR_IN = 'IN';

    protected List<String> currentFields = new List<String>(getSObjectFieldsNames());
    protected List<SearchCondition> searchConditions = new List<SearchCondition>();
    protected List<Schema.SObjectField> customFields = new List<Schema.SObjectField>();
    protected String groupByClause;
    protected String orderClause;
    protected String queryLogic;

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description getSObjectFields virtual method - privides list of all fields (which are used)
     *              of sObject that child class is related to
     * @return List<Schema.SObjectField>
     */
    public virtual List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description getSObjectType virtual method - provides SObjectType of
     *              sObject that child class is related to
     * @return Schema.SObjectType
     */
    public virtual Schema.SObjectType getSObjectType() {
        return null;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description getSObjectFieldsNames method - provides list of fields to be fetched from database
     * @return list of API qualified field names
     */
    public List<String> getSObjectFieldsNames() {
        List<String> result = new List<String>();
        List<Schema.SObjectField> fields = customFields == null || customFields.isEmpty()
                ? getSObjectFields()
                : customFields;

        for (Schema.SObjectField field : fields) {
            result.add(field.getDescribe().getName());
        }
        return result;
    }

    public void setUpdatableFields() {
        Map<String, Schema.SobjectField> fieldsLabel = getSObjectType().getDescribe().fields.getMap();
        currentFields.clear();
        for (string apiName : fieldsLabel.keyset()) {
            if (fieldsLabel.get(apiName).getDescribe().isUpdateable() || fieldsLabel.get(apiName).getDescribe().isCalculated()) {
                currentFields.add(apiName);
            }
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description getSObjectName method - provides sObject api name from sObject type
     * @return API qualified object nama
     */
    public String getSObjectName() {
        return getSObjectType().getDescribe().getName();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description buildQuery method - creates database valid query based on internal state
     * @return - query that is valid and can be executed against database
     */
    public String buildQuery() {
        return buildQuery(this.searchConditions, this.queryLogic);
    }

    public String buildQuery(List<SearchCondition> conditions, String queryLogic) {
        if (String.isBlank(queryLogic)) {
            return buildQuery(conditions);
        }
        return buildQuery(buildWhere(conditions, queryLogic));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description buildQuery method - builds query based on internal field list and custom where clause
     * @param  conditions - custom where condition
     * @return                  - query that is valid and can be executed against database
     */
    public String buildQuery(List<SearchCondition> conditions) {
        return buildQuery(buildWhere(conditions));
    }

    public String buildWhere(List<SearchCondition> conditions, String queryLogic) {
        String whereClause = '';
        if (!conditions.isEmpty()) {
            if (!BTN_ValidationHandler.doFormattingArgumentsSizeMatchGivenSize(queryLogic, conditions.size())) {
                System.debug(LoggingLevel.ERROR, queryLogic + ' does not match list size: ' + conditions.size());
            }
            List<String> stringConditions = new List<String>();
            for (SearchCondition condition : conditions) {
                stringConditions.add(condition.queryString);
            }
            whereClause += String.format(queryLogic, stringConditions);
        }
        return whereClause;
    }

    public String buildWhere(List<SearchCondition> conditions) {
        String whereClause = '';
        if (!conditions.isEmpty()) {
            List<String> stringConditions = new List<String>();
            for (SearchCondition condition : conditions) {
                stringConditions.add(condition.queryString);
            }
            whereClause += String.join(stringConditions, ' ');
        }
        return whereClause;
    }

    public String buildWhere() {
        return buildWhere(this.searchConditions);
    }

    public BTN_DAO setSearchConditions(List<SearchCondition> searchConditions) {
        this.searchConditions.clear();
        this.searchConditions.addAll(searchConditions);
        return this;
    }

    public BTN_DAO setQueryLogic(String queryLogic) {
        this.queryLogic = queryLogic;
        return this;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description buildQuery method - builds query based on internal field list and custom where clause
     * @param  whereClause - custom where condition
     * @return             - query that is valid and can be executed against database
     */
    public String buildQuery(String whereClause) {
        String sObjectName = getSObjectName();
        String className = String.valueOf(this);
        className = className.substring(0, className.indexOf(':'));

        String query = '';
        query += ' SELECT ' + String.join(currentFields, ', ');
        query += ' FROM ' + sObjectName;
        if (String.isNotBlank(whereClause)) {
            query += ' WHERE ' + whereClause;
        }
        if (String.isNotBlank(groupByClause)) {
            query += ' GROUP BY ' + groupByClause;
        }
        if (String.isNotBlank(orderClause)) {
            query += ' ORDER BY ' + orderClause;
        }
        return query;
    }

    ///// ------------------ Generic selects

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description findSObjectById mthod - generic method that finds sObject with given Id
     * @param  sObjectId - Id to search for
     * @return           - sObject if found, null otherwise
     */
    public sObject findSObjectById(Id sObjectId) {
        List<sObject> objects = findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Id', '=', sObjectId)
        });
        return objects.isEmpty() ? null : objects.get(0);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-06
     * @description findSObjectByName method - generic method that finds sObject with given Name
     * @param  name - Name to search for
     * @return    sObject       - sObject if found, null otherwise
     */
    public sObject findSObjectByName(String name) {
        List<sObject> objects = findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Name', '=', name)
        });
        return objects.isEmpty() ? null : objects.get(0);
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description findSObjectsById mthod - generic method that finds sObjects with Id in given collection
     * @param  sObjectIds - collection of Id to search for
     * @return            - collection of found sObjectsDAO.query
     */
    public List<sObject> findSObjectsById(Set<Id> sObjectIds) {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Id', 'IN', sObjectIds)
        });
    }

    ///// ------------------ Filtering rows

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description findSObjects method - query sObjects based on internal state
     * @return - collection of found sObjects
     */
    public List<sObject> findSObjects() {
        return Database.query(buildQuery());
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description findSObjects method - query sObjects based on custom where clause
     * @param whereClause - custom where clause
     * @return            - collection of found sObjects
     */
    public List<sObject> findSObjects(String whereClause) {
        return Database.query(buildQuery(whereClause));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description findSObjects method - query sObjects based on custom search conditions
     * @param searchConditions - custom search condtions
     * @return                 - collection of found sObjects
     */
    public List<sObject> findSObjectsBy(List<SearchCondition> searchConditions) {
        setSearchConditions(searchConditions);
        return findSObjects();
    }

    public List<sObject> findSObjectsBy(List<SearchCondition> searchConditions, String queryLogic) {
        setSearchConditions(searchConditions);
        setQueryLogic(queryLogic);
        return findSObjects();
    }

    /**
    * @author Mateusz Przywara
    * @date   2016-07-05
    * @description countSObjects method - counts records in query
    * @param String whereClause - query condition
    * @return Integer - number of records in query
    */
    public Integer countSObjects() {
        return countSObjects(null);
    }

    public Integer countSObjects(String whereClause) {
        currentFields = new List<String>{
                'COUNT(Id) n'
        };

        String query;
        if (whereClause != null) {
            query = buildQuery(whereClause);
        } else {
            query = buildQuery();
        }

        List<AggregateResult> results = Database.query(query);

        return (Integer) results[0].get('n');
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
    * @description countSObjectsBy method - counts records in query with conditions
    * @param List<SearchCondition> searchConditions - list of query conditions
    * @return Integer - number of records in query
    */
    public Integer countSObjectsBy(List<SearchCondition> searchConditions) {
        setSearchConditions(searchConditions);
        return countSObjects();
    }

    public Integer countSObjectsBy(List<SearchCondition> searchConditions, String queryLogic) {
        setSearchConditions(searchConditions);
        setQueryLogic(queryLogic);
        return countSObjects();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
    * @description countSObjectsBy method - counts records in query with conditions
    * @param List<SearchCondition> searchConditions - list of query conditions
    * @return Integer - number of records in query
    */
    public List<AggregateResult> groupSObjectsBy(List<SearchCondition> searchConditions) {
        setSearchConditions(searchConditions);
        return Database.query(buildQuery());
    }

    // Query Locator

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
    * @description getSObjectsLocator method - creates QueryLocator based on internal state
    * @return QueryLocator
    */
    public Database.QueryLocator getSObjectsLocator() {
        return Database.getQueryLocator(buildQuery());
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
    * @description getSObjectsLocator method - creates QueryLocator based on custom where clause
    * @return QueryLocator
    */
    public Database.QueryLocator getSObjectsLocator(String whereClause) {
        return Database.getQueryLocator(buildQuery(whereClause));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
    * @description getSObjectsLocator method - creates QueryLocator based on custom search conditions
    * @return QueryLocator
    */
    public Database.QueryLocator getSObjectsByLocator(List<SearchCondition> searchConditions) {
        setSearchConditions(searchConditions);
        return getSObjectsLocator();
    }

    ///// ------------------ Include fields

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description includeFields method - include related sObject from Lookup field
     * @param baseField - lookup field name
     * @param dao - dao obect used to fetch all required fields
     */
    protected void includeFields(String baseField, BTN_DAO dao) {
        for (String field: dao.currentFields) {
            currentFields.add(baseField + '.' + field);
        }
    }

    public void withShares() {
        currentFields.add('(SELECT UserOrGroupId, AccessLevel FROM Shares)');
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description setCustomFields method - used to set custom field list in
     *              case of there is no need to fetch all
     * @param customFields - list of sObject fields to be replaced with
     */
    protected void setCustomFields(List<Schema.SObjectField> customFields) {
        this.customFields.addAll(customFields);
        this.currentFields = getSObjectFieldsNames();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description SearchCondition class - abstracts out handling search conditions logic from DAO class
     */
    public class SearchCondition {
        public String field { get; private set; }
        public String operator { get; private set; }
        public String value { get; private set; }
        public String sqlOperator { get; private set; }
        public String sqlQuery { get; private set; }

        public String queryString {
            get {
                if (String.isNotBlank(sqlQuery)) {
                    return sqlQuery;
                } else {
                    return sqlOperator + ' ' + field + ' ' + operator + ' ' + value;
                }
            }
        }

        /**
        * @author Mateusz Przywara
        * @date   2016-07-05
         * @description SearchCondition method - creates SearchCondition
         * @param  field       - sObject field to filter sObjects
         * @param  operator    - comparision operator used to filter sObjects
         * @param  value       - value used to filter sObjects
         */
        public SearchCondition(String field, String operator, Object value) {
            setFields('', field, operator, value);
        }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description SearchCondition method - creates SearchCondition
         * @param  queryString - custom query string
         */
        public SearchCondition(String queryString) {
            this.sqlQuery = queryString;
        }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description SearchCondition method - creates SearchCondition
         * @param  field       - sObject field to filter sObjects
         * @param  operator    - comparision operator used to filter sObjects
         * @param  values      - values used to filter sObjects
         */
        public SearchCondition(String field, String operator, Set<Object> values) {
            setFields('', field, operator, (Object) values);
        }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description SearchCondition method - creates SearchCondition
         * @param  field       - sObject field to filter sObjects
         * @param  operator    - comparision operator used to filter sObjects
         * @param  values      - values used to filter sObjects
         */
        public SearchCondition(String field, String operator, List<Object> values) {
            setFields('', field, operator, (Object) values);
        }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description setFields method - used to set internal variables
         * @param  sqloperator - operator used to joins soql clauses
         * @param  field       - sObject field to filter sObjects
         * @param  operator    - comparision operator used to filter sObjects
         * @param  value       - value used to filter sObjects
         */
        private void setFields(String sqloperator, String field, String operator, Object value) {
            this.sqlOperator = sqlOperator;
            this.field = field;
            this.operator = operator;
            if (value instanceof String) {
                this.value = '\'' + String.valueOf(value) + '\'';
            } else if (value instanceof Set<Id>) {
                if (!((Set<Id>)value).isEmpty()) {
                    this.value = parseIdsListToString(value);
                } else {
                    this.sqlOperator = '';
                    this.field = '';
                    this.value = '';
                    this.operator = '';
                }
            } else if (value instanceof Set<String>) {
                if (!((Set<String>)value).isEmpty()) {
                    this.value = parseStringListToString(value);
                } else {
                    this.sqlOperator = '';
                    this.field = '';
                    this.value = '';
                    this.operator = '';
                }
            } else if (value instanceof Set<Integer>) {
                if (!((Set<Integer>)value).isEmpty()) {
                    this.value = parseIntegerListToString(value);
                } else {
                    this.sqlOperator = '';
                    this.field = '';
                    this.value = '';
                    this.operator = '';
                }
            } else {
                this.value = String.valueOf(value);
            }

            if (this.operator == OPERATOR_IN && String.isBlank(this.value.substringBetween('(', ')'))) {
                this.sqlOperator = '';
                this.field = 'Id';
                this.operator = '=';
                this.value = 'null';
            }
        }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description parseSObjectListToString method - parse Object being instance of List<Sobject> to String for
         * SOQL query
         * @param  values      - object being List<sObject>
         * @return  String      - String correct in SOQL queries
         */
        public String parseIdsListToString(Object values) {
            Set<Id> objects = (Set<Id>) values;
            String output = '(';
            for (Object item : objects) {
                if (item != null) {
                    output += '\'' + item + '\',';
                }
            }
            return output.removeEnd(',') + ')';
        }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-13
         * @description parseSObjectListToString method - parse Object being instance of List<Sobject> to String for
         * SOQL query
         * @param  values      - object being List<sObject>
         * @return  String      - String correct in SOQL queries
         */
        public String parseStringListToString(Object values) {
            Set<String> objects = (Set<String>) values;
            String output = '(';
            for (Object item : objects) {
                if (item != null) {
                    output += '\'' + item + '\',';
                }
            }
            return output.removeEnd(',') + ')';
        }

        public String parseIntegerListToString(Object values) {
            Set<Integer> objects = (Set<Integer>) values;
            String output = '(';
            for (Object item : objects) {
                if (item != null) {
                    output += + item + ',';
                }
            }
            return output.removeEnd(',') + ')';
        }
    }
}