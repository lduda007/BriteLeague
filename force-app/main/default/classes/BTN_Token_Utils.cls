public class BTN_Token_Utils {
//    private static BTN_DAO_Contact contactDAOLayer{set;
//        get {
//            if (BTN_ValidationHandler.isNull(contactDAOLayer)) {
//                contactDAOLayer = new BTN_DAO_Contact();
//            }
//            return contactDAOLayer;
//        }
//    }
//    public static String tokenLinkArgumentName = 'token';
//    /**
//     * @author Mateusz Przywara
//     * @date   2016-05-25
//     * @description Pre validation of token
//     * @param  checkSum   3-char prefix of Contact.Token__c
//     * @param  token      Token
//     * @return            token format is valid?
//     */
//    public static Boolean isTokenValidatable(String checkSum, String token) {
//        Boolean success = true;
//
//        if ((token.length() < 64)
//            || (!(checkSum.equals(EncodingUtil.base64encode(
//                Crypto.generateDigest('SHA-512', Blob.valueOf(token))).substring(0, 3))))) {
//            success = false;
//        }
//        return success;
//    }
//
//    /**
//     * @author Mateusz Przywara
//     * @date   2016-05-25
//     * @description Method validates token by quering Contacts
//     * @param  token      token
//     * @return            is token valid?
//     */
//    public static Boolean isTokenValid(String token) {
//        Boolean success = false;
//        for (Contact contactItem : contactDAOLayer.findRequestors()) {
//            if (token.equals(contactItem.Token__c.split('_').get(1))) {
//                success = true;
//                break;
//            }
//        }
//        return success;
//    }
//
//    /**
//     * @author Mateusz Przywara
//     * @date   2016-05-25
//     * @description This method generates AES 256 Key for further encryption
//     * @return Blob with 44- char long String.
//     */
//    public static Blob generateTokenKey() {
//        return Crypto.generateAesKey(256);
//    }
//
//    /**
//     * @author Mateusz Przywara
//     * @date   2016-05-25
//     * @description This method generated new token for Contact object
//     * @param  contactData Contact object
//     * @return             New token
//     */
//    public static String generateNewToken(Contact contactData, Blob key) {
//        Blob contactBlob = Blob.valueOf(contactData.Email);
//        return EncodingUtil.base64encode(Crypto.encryptWithManagedIV('AES256', key, contactBlob));
//    }
//
//    /**
//     * @author Mateusz Przywara
//     * @date   2016-05-25
//     * @description Generates checksum for token. Only first 3 chars will be checked
//     * @param  token      Token
//     * @return            First 3 chars of hash(SHA512) from token
//     */
//    public static String generateTokenChecksum(String token) {
//        return EncodingUtil.base64encode(Crypto.generateDigest('SHA-512', Blob.valueOf(token))).substring(0, 3);
//    }
//
//    /**
//     * @author Mateusz Przywara
//     * @date   2016-05-25
//     * @description This method builds checksum and token data for Salesforce Contact.
//     * @param  contactData Contact sObject
//     * @return             Valid data for Contact.token__c
//     */
//    public static String buildTokenDataForContact(Contact contactData) {
//        String newToken = BTN_Token_Utils.generateNewToken(contactData, BTN_Token_Utils.generateTokenKey());
//        return BTN_Token_Utils.generateTokenChecksum(newToken) + '_' +  newToken;
//    }
//
//    /**
//     * @author Mateusz Przywara
//     * @date   2016-05-25
//     * @description Method generating Site URL with token argument
//     * @param  token      Token data
//     * @param  siteURL    Site Data
//     * @return            URL of Site with token
//     */
//    public static String buildRequestSiteUrl(String argName, String token, Site site) {
//        String url = site.Subdomain + '.secure.force.com/' + site.UrlPathPrefix;
//        String organizationString = System.URL.getSalesforceBaseUrl().getHost().remove('-api');
//        List<String> ss = organizationString.split('\\.');
//        String ss2;
//
//        if (organizationString.contains('dev') || organizationString.contains('uat') || organizationString.contains
//                ('int')) {
//            ss2 = url.replace('secure', ss.get(1));
//            //source = visual force page
//            if (organizationString.contains('visual.force')) {
//                if (organizationString.split('--').size() > 1) {
//                    url = 'https://'
//                        + (organizationString.split('--').get(1)
//                        + '-' + ss2);
//                    //source visual force page on production environment
//                } else {
//                    url = 'https://' + ss2;
//                }
//            } else {
//                url = 'https://'
//                    + (organizationString.substring(organizationString.lastIndexOf('-') + 1).split('\\.').get(0)
//                    + '-' + ss2);
//            }
//        //prod enviroment - no sandbox prefix
//        } else {
//            url = 'britenet.secure.force.com/' + site.UrlPathPrefix;
//        }
//        return url
//            + '?' + argName + '='
//            + EncodingUtil.urlEncode(token, 'UTF-8');
//    }
}