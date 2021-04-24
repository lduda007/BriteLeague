/**
 * @author Mateusz Przywara
 * @date   2016-07-12
 * @description DAO class - Data Access Object for AsyncApexJob
*/
public class BTN_DAO_Profile extends BTN_DAO {

  /**
     * @author Mateusz Przywara
     * @date   2016-07-12
     * @description Constructor
    */
    public BTN_DAO_Profile() {
    }

    public override Schema.SObjectType getSObjectType() {
        return Profile.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                Profile.Id,
                Profile.Name
        };
    }
    // TODO: remove and use BTN_ProfileUtils
        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Profile
         * @param  profileName - Name of Profile to search
         * @return     Profile       - found Profile
        */
    public Profile findProfileByName(String profileName) {
        return (Profile) findSObjectByName(profileName);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-07-12
     * @description find Profile
     * @return List<Profile> - all profiles
    */
    public List<Profile> getAllProfiles() {
        return (List<Profile>) findSObjects();
    }
}