public with sharing class BTN_TestDataFactory {
    private static final String TEST_BS_USER_SEX = 'Female';
    private static final String TEST_BS_USER_EMAIL = 'testbsuser' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL;
    private static final String TEST_BS_USER_FIRSTNAME = 'Dżordź';
    private static final String TEST_BS_USER_LASTNAME = 'Tester';
    private static final String TEST_BS_USER_TITLE = 'Principus Maximus Decimus';
    private static final String TEST_BS_USER_PROJECTROLE = 'Tester';
    private static final Integer TEST_BS_USER_PROJECTROLE_ID = 0;
    private static final Boolean TEST_BS_USER_B2B = false;

    private static final String TEST_EQUIPMENT_TYPE_EQUIPMENT = 'Komputer';
    private static final String TEST_EQUIPMENT_TYPE_LICENSE = 'Licencja';
    private static final String TEST_EQUIPMENT_TYPE_PHONE_CONTRACT = 'Karta SIM';
    private static final String TEST_EQUIPMENT_MANUFACTURER = 'Dell';
    private static final String TEST_EQUIPMENT_MANUFACTURER_LICENSE = 'Microsoft';
    private static final String TEST_EQUIPMENT_LICENSE_NAME = 'Windows';
    private static final String TEST_EQUIPMENT_LICENSE_TYPE = 'Box';
    private static final String TEST_EQUIPMENT_MODEL = 'Latitude E7450';
    private static final String TEST_EQUIPMENT_COMPANY = 'Britenet';
    private static final String TEST_EQUIPMENT_LOCATION = 'Lublin Morwowa';
    private static final String TEST_EQUIPMENT_DESCRIPTION = 'Testowy Opis';

    public static final String TEST_HR_COLLABORATION_GROUP_NAME = 'Test HR Group';

    public static String TESTCURRENCY = 'PLN';
    public static String TEST_PROJECT_NAME = 'Test Project';
    private static String ACCOUNT_SOBJECT_NAME = 'Account';
    private static String FIRST_NAME_TEST_USER = 'Dzordz';
    private static String TEST_MAIN_SKILLS = 'java hard';
    private static String TEST_SECONDARY_SKILLS = 'git svn etc.';
    private static String TEST_PROJECT_DESC = 'very impresive project';
    private static String LAST_NAME_TEST_USER = 'UserCreatedForTest';
    public static String READ_LEVEL_ACCESS = 'Read';
    public static String EDIT_LEVEL_ACCESS = 'Edit';
    public static String ALL_LEVEL_ACCESS = 'All';
    public static String TEST_TEXT = 'TEST_REICHSNER';
    public static String COLLABORATION_GROUP_TYPE = 'Public';
    public static Integer BS_INTERNAL_USER_BS_ID = 9999;
    private static String EMAIL_TEST_USER =
            FIRST_NAME_TEST_USER +
                    LAST_NAME_TEST_USER +
                    BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL;

    // prepare Users - EXTERNAL_RESOURCE_REQUEST_PROFILE_NAME - Guest Profile
    // EXTERNAL_RESOURCE_REQUEST_PROFILE_NAME inserted with PublicUsers group membership
    public static Map<String, User> USER_MAP_BY_PROFILE {
        set;
        get {
            if (BTN_ValidationHandler.isNull(USER_MAP_BY_PROFILE)) {
                USER_MAP_BY_PROFILE = new Map<String, User>{
                        BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME =>
                                BTN_TestDataFactory.getActiveResourceManagerUser(),
                        BTN_ConstantRepo.SALES_PROFILE_NAME =>
                                BTN_TestDataFactory.getActiveSalesUser(),
                        BTN_ConstantRepo.EXTERNAL_RESOURCE_REQUEST_PROFILE_NAME =>
                                BTN_TestDataFactory.getActiveExternalSiteResourceRequestUser(),
                        BTN_ConstantRepo.EXTERNAL_CV_PROFILE_NAME =>
                                BTN_TestDataFactory.getActiveExternalSiteCVUser(),
                        BTN_ConstantRepo.PROFILE_NAME_COMMUNITY =>
                                BTN_TestDataFactory.getCommunityUser()
                };
            }
            return USER_MAP_BY_PROFILE;
        }
    }

    private static BTN_DAO_Account accountDAO{set;
        get {
            if (BTN_ValidationHandler.isNull(accountDAO)) {
                accountDAO = new BTN_DAO_Account();
            }
            return accountDAO;
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Pricebook2
     * @return            Pricebook2
     */
    public static Pricebook2 getPricebook() {
        Pricebook2 myPB = new Pricebook2(Name = 'testPB', CurrencyIsoCode = BTN_TestDataFactory.testCurrency, IsActive = true);
        insert myPB;
        return myPB;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Custom Setting with Number of Products per page
     * @return            Custom Setting
    */
    public static BTN_UtilitiesSettings__c getUtilCS() {
        BTN_UtilitiesSettings__c setting = new BTN_UtilitiesSettings__c();
        setting.Name = 'productsPerPage';
        setting.IntegerValue__c = 25;
        insert setting;
        return setting;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Products
     * @return            List of 2 Products
    */
    public static List<Product2> getProduct() {
        List<Product2> prods = new List<Product2>();
        prods.add(new Product2(ProductCode = 'amelinium', Name = 'tmpTestProduct2', Level__c = 'Junior', Family = 'Developer', Technology__c = 'Android', IsActive = true));
        prods.add(new Product2(ProductCode = 'amelinium2PRO', Name = 'tmpTestProduct222', Level__c = 'Junior', Family = 'Developer', Technology__c = 'Android', IsActive = true));
        insert prods;
        return prods;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Products
     * @param n Nymber of Products
     * @return            List of Products
    */
    public static List<Product2> getProduct(Integer n) {
        List<Product2> prods = new List<Product2>();
        for (Integer i = 0;i < n;i++) {
            prods.add(new Product2(ProductCode = 'amelinium2PRO' + i, Name = 'tmpTestProduct222' + i, Level__c = 'Junior', Family = 'Developer', Technology__c = 'Android', IsActive = true));
        }
        insert prods;
        return prods;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Procebook Entries based on provided Products and Pricebook
     * @param prods Pricebook Id
     * @param myPb Pricebook for Pricebook Entries
     * @return            List of Pricebook Entries
    */
    public static List<PricebookEntry> getPriceBookEntries(Pricebook2 myPb, List<Product2> prods) {
        Id pbId = Test.getStandardPricebookId();
        Integer i = 1;
        List<PricebookEntry> entries = new List<PricebookEntry>();
        List<PricebookEntry> entries2 = new List<PricebookEntry>();
        for(Product2 prod : prods) {
            entries.add(new PricebookEntry(CurrencyIsoCode = BTN_TestDataFactory.testCurrency, UnitPrice = i, Product2Id = prod.Id, Pricebook2Id = pbId, IsActive = true));
            entries2.add(new PricebookEntry(CurrencyIsoCode = BTN_TestDataFactory.testCurrency, UnitPrice = i, Product2Id = prod.Id, Pricebook2Id = myPb.Id, IsActive = true));
            i++;
        }
        insert entries;
        insert entries2;
        return entries2;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Procebook Entries based on provided products
     * @param prods Pricebook Id
     * @return            List of Pricebook Entries
    */
    public static List<PricebookEntry> getStandardPriceBookEntries(List<Product2> prods) {
        Id pbId = Test.getStandardPricebookId();
        Integer i = 1;
        List<PricebookEntry> entries = new List<PricebookEntry>();
        List<PricebookEntry> entries2 = new List<PricebookEntry>();
        for(Product2 prod : prods) {
            entries.add(new PricebookEntry(CurrencyIsoCode = BTN_TestDataFactory.testCurrency, UnitPrice = i, Product2Id = prod.Id, Pricebook2Id = pbId, IsActive = true));
            i++;
        }
        insert entries;
        return entries;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Opportunity with provided pricebook Id and Account
     * @param pbId Pricebook Id
     * @param account Account Id
     * @return            Opportunity
    */
    public static Opportunity getOpportunity(Id pbId, Id account) {
        Contact cont = BTN_TestDataFactory.getBusinessContact(account);
        Opportunity newOppo = new Opportunity(
                AccountId = account,
                ContactId__c = cont.Id,
                Name = 'veryNiceOppo',
                StageName = 'Draft',
                CloseDate = (System.today() + 15),
                CurrencyIsoCode = BTN_TestDataFactory.testCurrency,
                Pricebook2Id = pbId,
                NextStep__c = 'dummy stepping',
                NextStepDeadline__c = (System.today() + 10),
                ContractStart__c = Date.newInstance(2000, 1, 1),
                ContractEnd__c = Date.newInstance(2010, 1, 1),
                Description = 'sample Description',
                Location__c = 'kielce',
                Product_Main_Skills__c = 'main skillzz',
                Product_Secondary_Skills__c = 'sec600',
                Type = 'T&M'
        );
        insert newOppo;
        return newOppo;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Opportunity with provided pricebook Id
     * @param pbId Pricebook Id
     * @return            Opportunity
    */
    public static Opportunity getOpportunity(Id pbId) {
        Id accountRecordType = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id;
        Account acc = new Account(Name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME, CurrencyIsoCode = 'PLN', RecordTypeId = accountRecordType);
        insert acc;
        Contact cont = BTN_TestDataFactory.getBusinessContact(acc.Id);
        Opportunity newOppo = new Opportunity(AccountId = acc.Id, ContactId__c = cont.Id, Name = 'veryNiceOppo', StageName = 'Draft'
        , CloseDate = (System.today() + 15), CurrencyIsoCode = BTN_TestDataFactory.testCurrency, Pricebook2Id = pbId
        , NextStep__c = 'dummy stepping', NextStepDeadline__c = (System.today() + 10)
        , ContractStart__c = Date.newInstance(2000, 1, 1), ContractEnd__c = Date.newInstance(2010, 1, 1)
        , Description = 'sample Description', Location__c = 'kielce'
        , Product_Main_Skills__c = 'main skillzz', Product_Secondary_Skills__c = 'sec600');
        insert newOppo;
        return newOppo;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Opportunity with provided pricebook Id
     * @param pbId Pricebook Id
     * @return            Opportunity
    */
    public static Opportunity getOpportunityOld(Id pbId) {
        Account acc;
        if (BTN_ValidationHandler.isNull(accountDAO.findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME))) {
            acc = BTN_TestDataFactory.getBriteNetAccount();
        }
        Contact cont = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);
        Opportunity newOppo = new Opportunity(AccountId = acc.Id, ContactId__c = cont.Id, Name = 'veryNiceOppo', StageName = 'Draft'
        , CloseDate = (System.today() + 15), CurrencyIsoCode = BTN_TestDataFactory.testCurrency, Pricebook2Id = pbId
        , NextStep__c = 'dummy stepping', NextStepDeadline__c = (System.today() + 10)
        , ContractStart__c = Date.newInstance(2000, 1, 1), ContractEnd__c = Date.newInstance(2010, 1, 1)
        , Description = 'sample Description', Location__c = 'kielce'
        , Product_Main_Skills__c = 'main skillzz', Product_Secondary_Skills__c = 'sec600'
        , CVLanguage__c = 'Polish');
        insert newOppo;
        return newOppo;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Business Contact
     * @param accId Account Id required for Contact
     * @return            Britenet Account
    */
    public static Contact getRequestorInternalContact(Id accId) {
        return getRequestorInternalContact(
                accId,
                BS_INTERNAL_USER_BS_ID + BTN_TestDataFactory.getGeneratedInteger(0, 100)
        );
    }

    /**
     * @author Adam Jedrys
     * @date   2018-05-24
     * @description Creates and insert leader contact
     * @param accId Account Id required for Contact
     * @return            leader contact
    */
    public static Contact getLeaderInternalContact(Id accId) {
        Contact cont = new Contact(
                AccountId = accId,
                FirstName = 'Test',
                LastName = 'Leader',
                IsLeader__c = true,
                Email = 'test.leader@example.com',
                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactInternal().Id);
        insert cont;
        return cont;
    }

    /**
     * @author Konrad Kozaczuk
     * @date   2016-10-21
     * @description Creates and insert External Contact
     * @param accId Account Id required for Contact
     * @return            Britenet Account
    */
    public static Contact getRequestorExternalContact(Id accId) {
        return getRequestorExternalContact(
                accId,
                BS_INTERNAL_USER_BS_ID + BTN_TestDataFactory.getGeneratedInteger(0, 100)
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Business Contact
     * @param accId Account Id required for Contact
     * @return            Britenet Account
    */
    public static Contact getRequestorInternalContact(Id accId, Integer bsId) {
        Contact cont = new Contact(
                AccountId = accId,
                FirstName = FIRST_NAME_TEST_USER,
                LastName = LAST_NAME_TEST_USER + EncodingUtil.base64encode(Crypto.generateAesKey(128)),
                ResourceRequestor__c = true,
                Email = EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL,
                // unique
                BSexternalId__c = bsId,
                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactInternal().Id,
                Sex__c = 'Male'
        );
        insert cont;
        return cont;
    }

    /**
     * @author Konrad Kozaczuk
     * @date   2016-10-21
     * @description Creates and insert External Contact
     * @param accId Account Id required for Contact
     * @return            Britenet Account
    */
    //TODO BSId is only for BT internal BS Users
    public static Contact getRequestorExternalContact(Id accId, Integer bsId) {
        Contact cont = new Contact(
                AccountId = accId,
                FirstName = FIRST_NAME_TEST_USER,
                LastName = LAST_NAME_TEST_USER + EncodingUtil.base64encode(Crypto.generateAesKey(128)),
                ResourceRequestor__c = true,
                Email =
                        EncodingUtil.base64encode(Crypto.generateAesKey(128))
                                + String.valueOf(bsId)
                                + EMAIL_TEST_USER,
                // unique
                BSexternalId__c = bsId,
                MailingCity = 'Las Vegas Lublin',
                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactRecruit().Id
        );
        insert cont;
        return cont;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-21
     * @description Creates and insert Recruit Contact
     * @param accId Account Id required for Contact
     * @return Contact Recruit
    */
    public static Contact getRecruitContact(Id accId) {
        return getRecruitContact(
                accId,
                EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-21
     * @description Creates and insert Recruit Contact
     * @param accId Account Id required for Contact
     * @return Contact Recruit
    */
    public static Contact getRecruitContact(Id accId, String email) {
        return new BTN_ContactBuilderHelper()
                .buildWithRecruitRecordType()
                .buildWithDefaultAddress()
                .withLastName(FIRST_NAME_TEST_USER + EncodingUtil.base64encode(Crypto.generateAesKey(128)))
                .withFirstName(FIRST_NAME_TEST_USER)
                .withEmail(email)
                .withAccount(accId)
                .save();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description Creates and insert Recruit Contact
     * @param accId Account Id required for Contact
     * @return Contact Recruit
    */
    public static Contact getRecruitContactWithSkills(Id accId, String skills) {
        return new BTN_ContactBuilderHelper()
                .buildWithRecruitRecordType()
                .buildWithDefaultAddress()
                .withLastName(FIRST_NAME_TEST_USER + EncodingUtil.base64encode(Crypto.generateAesKey(128)))
                .withFirstName(FIRST_NAME_TEST_USER)
                .withEmail(
                        EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL
                )
                .withAccount(accId)
                .withSkills(skills)
                .save();
    }

    public static Contact getInternalContact(Id accId) {
        return BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .buildWithDefaultAddress()
                .withLastName(FIRST_NAME_TEST_USER + EncodingUtil.base64encode(Crypto.generateAesKey(128)))
                .withFirstName(FIRST_NAME_TEST_USER)
                .withEmail(
                        EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL
                )
                .withAccount(accId)
                .save();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Business Contact
     * @param accId Account Id required for Contact
     * @return            Britenet Account
    */
    public static Contact getBusinessContact(Id accId) {
        Id contactRecordType = BTN_RecordTypeUtils.getRecordTypeContactBusiness().Id;
        Contact cont = new Contact(
                AccountId = accId,
                FirstName = 'firstName',
                LastName = 'lastName' + EncodingUtil.base64encode(Crypto.generateAesKey(128)),
                ResourceRequestor__c = true,
                Email = EncodingUtil.base64encode(Crypto.generateAesKey(128)) + 'example@example.com',
                RecordTypeId = contactRecordType
        );
        insert cont;
        return cont;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Schedules BSS Contact Sync
     */
    public static void scheduleBSSSync() {
        BTN_JOB_BSSSynchronizations apexJob = new BTN_JOB_BSSSynchronizations();
        System.schedule(BTN_ConstantRepo.BSS_JOB_NAME + 'test', BTN_ConstantRepo.BSS_JOB_CRON, apexJob);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description mockup test for REST webservices does not require valid connection.
    */
    public static void getNewBssDummyConnections() {
        List<ConnectionProperty__c>  connections = new List<ConnectionProperty__c>{
                new ConnectionProperty__c(
                        Name = 'BS:users',
                        Username__c = 'SFDC',
                        Endpoint__c = 'https://bs.britenet.com.pl/api/users',
                        Password__c = 'dummy'
                ),
                new ConnectionProperty__c(
                        Name = 'BS:certs',
                        Username__c = 'SFDC',
                        Endpoint__c = 'https://bs.britenet.com.pl/api/users',
                        Password__c = 'dummy'
                ),
                new ConnectionProperty__c(
                        Name = 'BS:projects',
                        Username__c = 'SFDC',
                        Endpoint__c = 'https://bs.britenet.com.pl/api/projects',
                        Password__c = 'dummy'
                ),
                new ConnectionProperty__c(
                        Name = 'BS:assignments',
                        Username__c = 'SFDC',
                        Endpoint__c = 'https://bs.britenet.com.pl/api/assignments',
                        Password__c = 'dummy'
                ),
                new ConnectionProperty__c(
                        Name = 'BS:projectroles',
                        Username__c = 'SFDC',
                        Endpoint__c = 'https://bs.britenet.com.pl/api/projectroles',
                        Password__c = 'dummy'
                )
        };
        insert connections;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Britenet Account
     * @return            Britenet Account
     */
    public static Account getBriteNetAccount() {
        Account acc = new Account(
                Name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME,
                CurrencyIsoCode = 'PLN',
                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountBritenet().Id
        );
        insert acc;
        return acc;
    }

    /**
     * @author Adam Jedrys
     * @date   2018-04-23
     * @description Creates and insert Open Candidate
     * @param  resourceRequestId  Id of Resource Request
     * @return            Candidate
     */
    public static BTN_CV__c getCV(Id resourceRequestId, Id contactId) {
        BTN_CV__c cv = new BTN_CV__c(
                ResourceRequest__c = resourceRequestId,
                Status__c = BTN_ConstantRepo.CANDIDATE_STATUS_OPEN,
                Contact__c = contactId,
                Project_Manager_Email__c = 'test.email@example.com'
        );
        insert cv;
        return cv;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Creates and insert Auto Resource Request
     * @param  myAwesomeOppo  Id of Opportunity
     * @return            Resource Request
     */
    public static BTN_ResourceRequest__c getAutoResourceRequest(Opportunity myAwesomeOppo) {
        BTN_ResourceRequest__c resreq = new BTN_ResourceRequest__c(
                Description__c = myAwesomeOppo.Description,
                CurrencyIsoCode = 'PLN',
                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeResourceRequestAuto().Id,
                MainSkills__c = myAwesomeOppo.Product_Main_Skills__c,
                SecondarySkills__c = myAwesomeOppo.Product_Secondary_Skills__c,
                Status__c = 'Open',
                RequestorUser__c = BTN_Utils.getCurrentUser().Id,
                Opportunity__c = myAwesomeOppo.Id
        );
        insert resreq;
        return resreq;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Method generating Double number with floating point between lowBound and highBound
     * @param  lowBound   output will be greater than or equal lowBound
     * @param  highBound  output will be less or equal than highBound
     * @return            Generated Number
     */
    public static Double getGeneratedNumber(Integer lowBound, Integer highBound) {
        return ((Math.random() * (highBound - lowBound)) + lowBound);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Method generating number without floating point between lowBound and highBound
     * @param  lowBound   output will be greater than or equal lowBound
     * @param  highBound  output will be less or equal than highBound
     * @return            Generated Integer Number
     */
    public static Integer getGeneratedInteger(Integer lowBound, Integer highBound) {
        return (Integer) ((Math.random() * (highBound - lowBound)) + lowBound);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Generates high quality random String with specified length
     * @param  length     length of output String
     * @return            random String
     */
    public static String getGeneratedString(Integer length) {
        String output = '';
        for (Integer i = 0; i <= Math.ceil(length / 44); i++) {
            output += EncodingUtil.base64encode(crypto.generateAesKey(256));
        }
        return output.substring(0, length);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-24
     * @description Generates test email
     * @return            random Email
     */
    public static String getRandomEmail() {
        return BTN_DateUtils.getPastUNIXTimeStamp(0) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL;
    }

    public static String getRandomPhone() {
        return '+48' + String.valueOf(BTN_DateUtils.getPastUNIXTimeStamp(0) + (Math.random() * 100000).round()).right(9);
    }

    public static String getRandomSerialNumber() {
        String result = String.valueOf(BTN_DateUtils.getPastUNIXTimeStamp(0) + (Math.random() * 100000).round()).reverse();
        String encodedResult = EncodingUtil.base64Encode(Blob.valueOf(result));
        List<String> charactersNumeric = result.split('');
        charactersNumeric.remove(0);
        List<String> charactersAlphanumeric = encodedResult.split('');
        charactersAlphanumeric.remove(0);
        charactersNumeric.addAll(charactersAlphanumeric);
        return String.format('{0}{1}{2}{3}-{4}{5}{6}{7}-{8}{9}{10}{11}-{12}{13}{14}{15}', charactersNumeric).toUpperCase();
    }

    public static String getRandomBTNId() {
        List<String> characters = String.valueOf(BTN_DateUtils.getPastUNIXTimeStamp(0) + (Math.random() * 100000).round()).right(4).split('');
        characters.remove(0);
        return String.format('BTN-{0}{1}{2}{3}', characters);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description Generates test Date
     * @return            random Email
     */
    public static Date getRandomDate() {
        return Date.newInstance(
                getGeneratedInteger(2000, 2020),
                getGeneratedInteger(1, 12),
                getGeneratedInteger(1,30)
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description getBSSRandomDate Generates test Date
     * @return  String
     */
    public static String getBSSRandomDate() {
        return getGeneratedInteger(1960, 2000) + '-' + getGeneratedInteger(1, 12) + '-' + getGeneratedInteger(1,30);
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-06-21
     * @description This method creates and insert Attachment
     * @param name Name of attachment
     * @param data String Attachment content
     * @param parentId Id of sObject assigned as parent to Attachment
     * @return           Created Attachment
     */
    public static Attachment getAttachment(String name, String data, Id parentId) {
        return BTN_TestDataFactory.getAttachment(name, Blob.valueOf(data), parentId);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-12
     * @description Create General Event for Contact
     * @param contactId Parent record
     * @param postOnCandidates Escalate Feed Message to Contact Candidates?
     * @return           Created BTN_Event__c
    */
    public static BTN_Event__c getGeneralEvent(Id contactId, Boolean postOnCandidates) {
        BTN_Event__c result = new BTN_Event__c(
                Interviewed__c = contactId,
                Description__c = TEST_TEXT,
                PostOnRelatedCandidates__c = postOnCandidates,
                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id
        );
        insert result;
        return result;
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-06-21
     * @description This method creates and insert Attachment
     * @param name String Name of attachment
     * @param data Blob Attachment content
     * @param parentId Id of sObject assigned as parent to Attachment
     * @return           Created Attachment
     */
    public static Attachment getAttachment(String name, Blob data, Id parentId) {
        Attachment atta = new Attachment(Name = name, Body = data, ParentId = parentId);
        insert atta;
        return atta;
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-06-22
     * @description This method creates new User
     * @param firstName String Fisrst Name of User
     * @param lastName String Last Name of User
     * @param roleId Id of Salesforce Role
     * @param profileId Id of Salesforce Profile
     * @return           User
    */
    public static User getActiveUser(String firstName, String lastName, Id roleId, String profileId) {

        String name = firstName + lastName;

        String nickname = name;
        if (nickname.length() > 40) {
            nickname = nickname.substring(0, 40);
        }

        User u = new User();
        u.FirstName = firstName;
        u.LastName = lastName + EncodingUtil.base64encode(Crypto.generateAesKey(128));
        u.Username = (name + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX + System.now().millisecond());
        u.Email = name + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX;
        u.UserRoleId = roleId;
        u.Alias = name.substring(0, Math.min(8, name.length()));
        u.CommunityNickname = nickname;
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = BTN_ConstantRepo.UTF_ENCODING;
        u.ProfileId = profileId;
        u.LanguageLocaleKey = 'en_US';
        u.IsActive = true;

        return u;
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-06-27
     * @description Returns Id of profile
     * @param name String with name of profile
     * @return           Found Profile Id
     */
    public static Id getProfileId(String profileName) {
        return new BTN_DAO_Profile().findProfileByName(profileName).Id;
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-07-13
     * @description getActiveSalesUser Returns New User with Sales profile
     * @return  User         New Sales User
     */
    public static User getActiveSalesUser() {
        return BTN_TestDataFactory.getActiveUser(
                FIRST_NAME_TEST_USER,
                LAST_NAME_TEST_USER + 'Sales',
                null,
                BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME)
        );
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-07-13
     * @description getActiveSalesUser Returns New User with RM profile
     * @return  User         New Resource Management User
     */
    public static User getActiveResourceManagerUser() {
        return BTN_TestDataFactory.getActiveUser(
                FIRST_NAME_TEST_USER,
                LAST_NAME_TEST_USER + 'RM',
                null,
                BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME)
        );
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-07-13
     * @description getCommunityUser Returns New User with BTN_Community_Plus profile
     * @return  User         New Community User
     */
    public static User getCommunityUser() {
        Contact relatedContact = getRequestorInternalContact(
                new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id
        );
        return getCommunityUser(relatedContact.Id, relatedContact.Email);
    }

     /**
     * @author Mateusz Przywara
     * @date   2016-07-17
     * @description getCommunityUser Returns New User with BTN_Community_Plus profile
     * @param contactId Related Contact
     * @param email Related Contact's Email
     * @return  User         New Community User
     */
    public static User getCommunityUser(Id contactId, String email) {
        User hrUser  = BTN_UserBuilderHelper.buildUserWithDefaults()
                .withLastName(FIRST_NAME_TEST_USER + LAST_NAME_TEST_USER + 'HR')
                .withUserName(EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX)
                .withAlias(FIRST_NAME_TEST_USER)
                .withEmailEncoding(BTN_ConstantRepo.UTF_ENCODING)
                .withLanguage('en_US')
                .withLocal('en_GB')
                .withNickName(EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX)
                .withProfile(BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.PROFILE_NAME_COMMUNITY))
                .withContactId(contactId)
                .withLanguage('en_US')
                .withTimeZone('Europe/Berlin')
                .withEmail(email)
                .isActive(true)
                .get();
        return hrUser;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-07-13
     * @description getActiveSalesUser Returns New User with RM profile
     * @return  User         New Resource Management User
    */
    public static User getActiveExternalSiteResourceRequestUser() {
        User newUser = BTN_TestDataFactory.getActiveUser(
                FIRST_NAME_TEST_USER,
                LAST_NAME_TEST_USER + 'RR',
                null,
                BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.EXTERNAL_RESOURCE_REQUEST_PROFILE_NAME)
        );
        insert newUser;
        return newUser;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-13
     * @description getActiveExternalSiteCVUser Returns New User with CV Site User
     * @return  User         New Resource Management User
    */
    public static User getActiveExternalSiteCVUser() {
        User newUser = BTN_TestDataFactory.getActiveUser(
                FIRST_NAME_TEST_USER,
                LAST_NAME_TEST_USER + 'CV',
                null,
                BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.EXTERNAL_CV_PROFILE_NAME)
        );
        insert newUser;
        return newUser;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-07-14
     * @description shareContactWithUser - Shares record with provided User
     * @description contactId - Record Id of Contact
     * @description shareWithUserId - Share Contact with User
     * @description String - Access level Read/Edit
     * @return  ContactShare         New Sharing
    */
    /*public static ContactShare shareContactWithUser (Id contactId, Id shareWithUserId, String accessLevel) {
        ContactShare newSharing = new ContactShare(
                ContactAccessLevel = accessLevel,
                ContactId = contactId,
                UserOrGroupId = shareWithUserId
        );
        insert newSharing;
        return newSharing;
    }*/

   /**
     * @author Mateusz Przywara
     * @date   2016-07-14
     * @description createDataStructureForBriteCRM - method creates structure for BriteRM
     *  From Opportunity to required Accounts, Contacts etc.
    */
    public static void createDataStructureForBriteRM () {
        getTriggerSkipperCustomSetting();
        //get standard Pricebook Id required for Opportunity
        Id pricebookId = Test.getStandardPricebookId();
        getHRCollaborationGroup();

        // Account preparations
        Map<String, Account> accounts = new Map<String, Account> {
                BTN_ConstantRepo.BRITENET_ACCOUNT_NAME =>
                        new Account(
                                Name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME,
                                CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
                                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountBritenet().Id
                        ),
                BTN_ConstantRepo.ACCOUNT_PRIVATE_NAME =>
                        new Account(
                                Name = BTN_ConstantRepo.ACCOUNT_PRIVATE_NAME,
                                CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
                                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id
                        ),
                BTN_ConstantRepo.ACCOUNT_PUBLIC_NAME =>
                        new Account(
                                Name = BTN_ConstantRepo.ACCOUNT_PUBLIC_NAME,
                                CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
                                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountPublicSector().Id
                        )
        };
        insert accounts.values();

        // Prepare Contacts
        Map<String, Contact> contacts = new Map<String, Contact> {
                BTN_ConstantRepo.INTERNAL_CONTACT_RECORDTYPE_NAME =>
                        BTN_TestDataFactory.getRequestorInternalContact(
                                accounts.get(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id),
                BTN_ConstantRepo.EXTERNAL_CONTACT_RECORDTYPE_NAME =>
                        BTN_TestDataFactory.getRequestorExternalContact(
                                accounts.get(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id),
                BTN_ConstantRepo.BUSINESS_CONTACT_RECORDTYPE_NAME =>
                        BTN_TestDataFactory.getBusinessContact(accounts.get(BTN_ConstantRepo.ACCOUNT_PRIVATE_NAME).Id)
        };

        //Prepare Map of Opportunities by RecordType
        Opportunity tmDraftOpportunity =
                getOpportunity(pricebookId, accounts.get(BTN_ConstantRepo.ACCOUNT_PRIVATE_NAME).Id);

        //Prepare Auto Resource Request
        Map<String, BTN_ResourceRequest__c> resourceRequests = new Map<String, BTN_ResourceRequest__c> {
                BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_AUTO =>
                        BTN_TestDataFactory.getAutoResourceRequest(tmDraftOpportunity)
        };

        // Add Candidate Request to Resource Request
        /*BTN_TestDataFactory.getCandidateRequest(
                resourceRequests.get(BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_AUTO).Id
        );*/

        // Add candidate to Resource Request
        /*getCV(resourceRequests.get(BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_AUTO).Id,
                contacts.get(BTN_ConstantRepo.INTERNAL_CONTACT_RECORDTYPE_NAME).Id);*/
        // Add Internal Open Candidate to specified internal Contact
        getCV(resourceRequests.get(BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_AUTO).Id,
                contacts.get(BTN_ConstantRepo.INTERNAL_CONTACT_RECORDTYPE_NAME).Id);
        // Add Internal Open Candidate to specified internal Contact
        getCV(resourceRequests.get(BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_AUTO).Id,
                contacts.get(BTN_ConstantRepo.EXTERNAL_CONTACT_RECORDTYPE_NAME).Id);
        BTN_BSS_Mockup mockAPI =
                new BTN_BSS_Mockup(BTN_BSS_Mockup.ASSIGNMENT_MODE, 200, BTN_BSS_Mockup.TEST_ASSIGNMENT_QUANTITY);
        // Provide BSS Contacts
        List<Contact> bssContacts =
                BTN_ContactUtils.newContactFromBS(
                        BTN_BSS_DTO.parseUser(mockAPI.generateUserJSON(BTN_BSS_Mockup.TEST_USER_QUANTITY))
                );
        insert bssContacts;
        // Provide BSS Projects
        List<BTN_Project__c> bssProjects =
                BTN_ProjectUtils.parseDTOProjectsFromBSSToSObjects(
                        BTN_BSS_DTO.parseProject(mockAPI.generateProjectJSON(200)),
                        new BTN_DAO_Account().findAccounts()
                );
        insert bssProjects;
        // Provide BSS Assignments
        List<BTN_Assignment__c> assignments = BTN_AssignmentUtils.parseDTOAssignmentsFromBSSToSObjects(
                BTN_BSS_DTO.parseAssignment(mockAPI.generateAssignmentJSON(200)),
                bssContacts,
                bssProjects
        );
        insert assignments;
        List<Case> externalCasesList = new List<Case>{
                new Case(
                        RecordTypeId =
                                BTN_RecordTypeUtils.getRecordTypeCaseExternalOnBoarding().Id,
                        Assignment__c = assignments.get(0).Id,
                        NewUserFirstName__c = TEST_TEXT,
                        NewUserTitle__c = TEST_TEXT,
                        NewUserLastName__c = TEST_TEXT,
                        NewUserB2B__c = false,
                        NewUserEmail__c = TEST_TEXT + 2 + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX
                ),
                new Case(
                        RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCaseExternalOffBoarding().Id,
                        Assignment__c = assignments.get(0).Id,
                        NewUserFirstName__c = TEST_TEXT,
                        NewUserTitle__c = TEST_TEXT,
                        NewUserLastName__c = TEST_TEXT,
                        NewUserB2B__c = false,
                        NewUserEmail__c = TEST_TEXT + 1 + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX
                )
        };
        insert externalCasesList;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description setAssignmentGroup Set Assignment group for Batch - flow functionality
     * @param assignment
     * @return  BTN_Assignment__c
    */
    public static BTN_Assignment__c setAssignmentGroup(BTN_Assignment__c assignment) {
        assignment.AssignmentGroup__c =
                BTN_Utils.buldAssignmentGroupString(assignment.Contact__c, assignment.Project__r.Account__c);
        return assignment;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description getPreparedAssignments Get Inserted Assignments with new Project
     * @param outputSize Number of Assignments on Output
     * @param assignmentLength Days difference between End Date and Start Date
     * @param assignmentInterval Days between Assignments
     * @return  BTN_Assignment__c
    */
    public static List<BTN_Assignment__c> getPreparedAssignments(
            Integer outputSize,
            Integer assignmentLength,
            Integer assignmentInterval
    ) {
        List<BTN_Assignment__c> result = new List<BTN_Assignment__c>();
        Account btAccount = new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME);
        Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
        BTN_Project__c  projectTest = new BTN_Project__c(
                Name = TEST_PROJECT_NAME,
                BritesheetProjectId__c = 1,
                Account__c = btAccount.Id
        );
        insert projectTest;
        Date tmpDate = System.Today().addDays(assignmentLength);
        for (Integer i = 0; i < outputSize; i++) {

            result.add(setAssignmentGroup(new BTN_Assignment__c(
                    BritesheetExternalId__c = i,
                    StartDate__c = tmpDate,
                    EndDate__c = tmpDate.addDays(assignmentLength),
                    Contact__c = internalContact.Id,
                    Project__c = projectTest.Id
            )));
            tmpDate = tmpDate.addDays(assignmentInterval + assignmentLength);
        }
        insert result;
        return result;
    }

    /**
     * @author Konrad Kozaczuk
     * @date   2016-10-19
     * @description getPreparedAssignments Get Inserted Assignments with new Project
     * @param outputSize Number of Assignments on Output
     * @param assignmentLength Days difference between End Date and Start Date
     * @param assignmentInterval Days between Assignments
     * @param startingFrom date when first assignment starts
     * @return  BTN_Assignment__c
    */
    public static List<BTN_Assignment__c> getPreparedAssignments(
            Integer outputSize,
            Integer assignmentLength,
            Integer assignmentInterval,
            Date startingFrom
    ) {
        List<BTN_Assignment__c> result = new List<BTN_Assignment__c>();
        Account btAccount = new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME);
        Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
        BTN_Project__c  projectTest = new BTN_Project__c(
                Name = TEST_PROJECT_NAME,
                BritesheetProjectId__c = 1,
                Account__c = btAccount.Id
        );
        insert projectTest;
        Date tmpDate = startingFrom;
        for (Integer i = 0; i < outputSize; i++) {

            result.add(setAssignmentGroup(new BTN_Assignment__c(
                    BritesheetExternalId__c = i,
                    StartDate__c = tmpDate,
                    EndDate__c = tmpDate.addDays(assignmentLength),
                    Contact__c = internalContact.Id,
                    Project__c = projectTest.Id
            )));
            tmpDate = tmpDate.addDays(assignmentInterval + assignmentLength);
        }
        insert result;
        return result;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-30
     * @description getInternalOnboardingCase Create and Insert Internal Onboarding Case
    */
    public static Case getInternalOnboardingCase(Id leaderId) {
        Case internalOnBoarding = BTN_CaseBuilderHelper.buildWithInternalOnBoardingRecordType()
                        .withStatus(BTN_ConstantRepo.CASE_STATUS_OPEN)
                        .withSex(TEST_BS_USER_SEX)
                        .withB2b(TEST_BS_USER_B2B)
                        .withEmail(System.currentTimeMillis() + TEST_BS_USER_EMAIL)
                        .withFirstName(TEST_BS_USER_FIRSTNAME)
                        .withLastName(TEST_BS_USER_LASTNAME)
                        .withTitle(TEST_BS_USER_TITLE)
                        .withLeader(leaderId)
                        .get();
        internalOnBoarding.Project_Manager_Email__c = 'test.email@example.com';
        insert internalOnBoarding;
        return internalOnBoarding;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-30
     * @description getInternalOnboardingCase Create and Insert Internal Onboarding Case
     *  Onboarding Case Leader field for Contact will have first retrieved from DB Internal Contact Id value.
    */
    public static Case getInternalOnboardingCase() {
        List<Contact> leaderList;
        Contact leader;
        Account acc;
        if ((acc = new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME)) == null) {
            acc = getBriteNetAccount();
        }
        if((leaderList = new BTN_DAO_Contact().findInternals()).isEmpty()) {
            leader = getRequestorInternalContact(acc.Id);
        } else {
            leader = leaderList.get(0);
        }
        return getInternalOnboardingCase(leader.Id);
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-30
     * @description getInternalOnboardingCase Create and Insert Internal Onboarding Case
    */
    public static Case getInternalOffboardingCase() {
        return getInternalOffboardingCase(null);
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-12-20
     * @description getInternalOnboardingCase Create and Insert Internal Onboarding Case
    */
    public static Case getInternalOffboardingCase(Id contactId) {
        Case internalOffBoarding = BTN_CaseBuilderHelper.buildWithInternalOffBoardingRecordType()
                .withStatus(BTN_ConstantRepo.CASE_STATUS_OPEN)
                .withSex(TEST_BS_USER_SEX)
                .withB2b(TEST_BS_USER_B2B)
                .withEmail(TEST_BS_USER_EMAIL + System.currentTimeMillis())
                .withFirstName(TEST_BS_USER_FIRSTNAME)
                .withLastName(TEST_BS_USER_LASTNAME)
                .withTitle(TEST_BS_USER_TITLE)
                .withProjectRole(TEST_BS_USER_PROJECTROLE)
                .withContact(contactId)
                .get();
        insert internalOffBoarding;
        return internalOffBoarding;
    }

    public static BTN_Equipment__c getEquipment(String recordTypeId) {
        BTN_Equipment__c equipment = new BTN_Equipment__c(
                RecordTypeId = recordTypeId,
                Active__c = true
        );

        if (BTN_RecordTypeUtils.isEquipmentEquipment(equipment)) {
            equipment.Type__c = TEST_EQUIPMENT_TYPE_EQUIPMENT;
            equipment.Manufacturer__c = TEST_EQUIPMENT_MANUFACTURER;
            equipment.Model__c = TEST_EQUIPMENT_MODEL;
            equipment.Serial_Number__c = BTN_TestDataFactory.getRandomSerialNumber();
            equipment.Britenet_ID__c = BTN_TestDataFactory.getRandomBTNId();
        } else if (BTN_RecordTypeUtils.isEquipmentLicense(equipment)) {
            equipment.Type__c = TEST_EQUIPMENT_TYPE_LICENSE;
            equipment.Manufacturer__c = TEST_EQUIPMENT_MANUFACTURER_LICENSE;
            equipment.License_Name__c = TEST_EQUIPMENT_LICENSE_NAME;
            equipment.License_Type__c = TEST_EQUIPMENT_LICENSE_TYPE;
            equipment.Serial_Number__c = BTN_TestDataFactory.getRandomSerialNumber();
            equipment.Expiration_Date__c = Date.today().addYears(1);
        } else if (BTN_RecordTypeUtils.isEquipmentPhoneContract(equipment)) {
            equipment.Type__c = TEST_EQUIPMENT_TYPE_PHONE_CONTRACT;
            equipment.Phone_Number__c = BTN_TestDataFactory.getRandomPhone();
            equipment.Expiration_Date__c = Date.today().addYears(1);
        }
        insert equipment;
        return equipment;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-09-13
     * @description getCandidateRequest Create and Insert Candidate Request Affiliated with request
     *  normally system insert Candidate Request when User Send an Email to HR.
    */
    /*
    public static BTN_CandidateRequest__c getCandidateRequest(Id requestId) {
        BTN_CandidateRequest__c candidateRequest = new BTN_CandidateRequest__c(
                ResourceRequest__c = requestId,
                MainSkills__c = TEST_MAIN_SKILLS,
                SecondarySkills__c = TEST_SECONDARY_SKILLS,
                Recipient__c = BTN_Utils.getCurrentUser().Id,
                ProjectDescription__c = TEST_PROJECT_DESC);
        insert candidateRequest;
        return candidateRequest;
    }
*/

   /**
     * @author Mateusz Przywara
     * @date   2016-09-30
     * @description getCandidateRequest Create and Insert Candidate Request Affiliated with request
     *  normally system insert Candidate Request when User Send an Email to HR.
    */
    public static List<BTN_ProjectRolesSetting__c> getProjectRolesCustomSetting() {
        List<BTN_ProjectRolesSetting__c> projectRoles = new List<BTN_ProjectRolesSetting__c>{
                new BTN_ProjectRolesSetting__c(Name = 'Administracja BTN', BSExternalId__c = 0),
                new BTN_ProjectRolesSetting__c(Name = 'Tester', BSExternalId__c = 1),
                new BTN_ProjectRolesSetting__c(Name = 'KP/ScrumMaster', BSExternalId__c = 2),
                new BTN_ProjectRolesSetting__c(Name = 'Administrator/Wdrożeniowiec', BSExternalId__c = 3),
                new BTN_ProjectRolesSetting__c(Name = 'Analityk', BSExternalId__c = 4),
                new BTN_ProjectRolesSetting__c(Name = 'Inne', BSExternalId__c = 5),
                new BTN_ProjectRolesSetting__c(Name = 'FrontEnd/WebDeveloper', BSExternalId__c = 6),
                new BTN_ProjectRolesSetting__c(Name = 'Salesforce', BSExternalId__c = 7),
                new BTN_ProjectRolesSetting__c(Name = 'JAVA', BSExternalId__c = 8),
                new BTN_ProjectRolesSetting__c(Name = 'PEGA', BSExternalId__c = 9),
                new BTN_ProjectRolesSetting__c(Name = 'ServiceDesk', BSExternalId__c = 10),
                new BTN_ProjectRolesSetting__c(Name = 'Mobilne', BSExternalId__c = 11),
                new BTN_ProjectRolesSetting__c(Name = 'SAP', BSExternalId__c = 12),
                new BTN_ProjectRolesSetting__c(Name = '.NET', BSExternalId__c = 13)
        };
        insert projectRoles;
        return projectRoles;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-10-17
     * @description getHRCollaborationGroup Create and Insert Collaboration Group for Community HR Users
    */
    public static CollaborationGroup getHRCollaborationGroup() {
        CollaborationGroup hrGroup = new CollaborationGroup(
                Name = TEST_HR_COLLABORATION_GROUP_NAME,
                CollaborationType = COLLABORATION_GROUP_TYPE
        );
        insert hrGroup;
        return hrGroup;
    }
    
    /**
     * @author Mateusz Przywara
     * @date   2016-12-19
     * @description Creates and insert Custom Setting with *table* of skip trigger info
     * for more info search for BTN_TriggerUtils.
     * @return            Custom Setting
    */
    public static BTN_BriteCRM_TriggerException__c getTriggerSkipperCustomSetting() {
        BTN_BriteCRM_TriggerException__c setting = new BTN_BriteCRM_TriggerException__c();
        // Trigger fields are false by default so there is no need to modify setting content
        insert setting;
        return setting;
    }
}