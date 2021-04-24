/**
 * @author Mateusz Przywara
 * @date   2016-07-05
 * @description DAO class - Data Access Object for Account
*/
public class BTN_DAO_Account extends BTN_DAO {
    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor
    */
    public BTN_DAO_Account() {
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description find Contact
         * @param  accountName - Name of Account to search for
         * @return     Account       - found Account
         */
    public Account findAccountById(Id accountId) {
        return (Account) findSObjectById(accountId);
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description find Accounts
         * @return     List<Account>       - found Accounts
         */
    public List<Account> findAccounts() {
        return (List<Account>) findSObjects();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description find Account by Name
     * @param  accountName - Name of Account to search for
     * @return     Account       - found Account
    */
    public Account findAccountByName(String accountName) {
        return (Account) findSObjectByName(accountName);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-08
     * @description find Account Id by Name
     * @param  accountName - Name of Account to search for
     * @return     Id       - found Account Id
    */
    public Id findAccountIdByName(String accountName) {
        Account acc = (Account) findSObjectByName(accountName);
        return BTN_ValidationHandler.isNull(acc) ? null : acc.Id;
    }

    public override Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                Account.Id,
                Account.Name
        };
    }
}