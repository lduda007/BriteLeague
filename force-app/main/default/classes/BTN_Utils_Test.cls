@isTest
private class BTN_Utils_Test {

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method test if Custom setting methods are ok.
     * @return void
    */
	@isTest static void utilsCSmethodsTesterAsSalesUser() {
        System.RunAs(BTN_TestDataFactory.getActiveSalesUser()) {
            System.assertEquals(null, BTN_Utils.getIntegerValueFromCS('testCS'));
            System.assertEquals(false, BTN_Utils.isCSContains('testCS', 'dracula'));
            BTN_UtilitiesSettings__c setting = new BTN_UtilitiesSettings__c();
            setting.Name = 'testCS';
            setting.Value__c = 'dracula';
            setting.IntegerValue__c = 25;
            insert setting;
            System.assertEquals(BTN_Utils.getIntegerValueFromCS('testCS'), 25);
            System.assertNotEquals(BTN_Utils.getIntegerValueFromCS('testCS'), 24);
            System.assert(BTN_Utils.isCSContains('testCS', 'dracula'));
            System.assert(!BTN_Utils.isCSContains('testCS', 'Tojo-Mojo'));
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-07-14
     * @description Method test if Custom setting methods are ok.
     * @return void
    */
    @isTest static void utilsCSmethodsTesterAsRM() {
        System.RunAs(BTN_TestDataFactory.getActiveResourceManagerUser()) {
            System.assertEquals(null, BTN_Utils.getIntegerValueFromCS('testCS'));
            System.assertEquals(false, BTN_Utils.isCSContains('testCS', 'dracula'));
            BTN_UtilitiesSettings__c setting = new BTN_UtilitiesSettings__c();
            setting.Name = 'testCS';
            setting.Value__c = 'dracula';
            setting.IntegerValue__c = 25;
            insert setting;
            System.assertEquals(BTN_Utils.getIntegerValueFromCS('testCS'), 25);
            System.assertNotEquals(BTN_Utils.getIntegerValueFromCS('testCS'), 24);
            System.assert(BTN_Utils.isCSContains('testCS', 'dracula'));
            System.assert(!BTN_Utils.isCSContains('testCS', 'Tojo-Mojo'));
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method test if getCurrentUser method works.
     * @return void
    */
	@isTest static void utilsGetUserTester() {
        Id dummyRoleId;
        User testUser = BTN_TestDataFactory.getActiveUser(
                'Matthias',
                'Hannavald',
                dummyRoleId,
                BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.SALES_PROFILE_NAME)
        );
        Id result;
        System.RunAs(testUser) {
            result = BTN_Utils.getCurrentUser().Id;
            System.assertEquals(UserInfo.getUserId(), result);
        }

	}

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method test if Opportunity has products method works.
     * @return void
    */
	@isTest static void utilsHasMethodsTester() {
		Id standardPbId = Test.getStandardPricebookId();
		Account acc = BTN_TestDataFactory.getBriteNetAccount();
		List<Product2> prod = BTN_TestDataFactory.getProduct();

		PricebookEntry pbEntry = new PricebookEntry(
                CurrencyIsoCode = 'PLN',
                UnitPrice = 50,
                Product2Id = prod.get(0).Id,
                Pricebook2Id = standardPbId,
                IsActive = true
        );
		insert pbEntry;

		Opportunity newOppo = BTN_TestDataFactory.getOpportunity(standardPbId);
		System.assert(!BTN_Utils.getOppoHasProducts(newOppo.Id));
		OpportunityLineItem newProductInOppo = new OpportunityLineItem(
                Quantity = 20,
                PricebookEntryId = pbEntry.Id,
                Hourly_Rate__c = 1,
                OpportunityId = newOppo.Id,
                TotalPrice = 1
        );
		insert newProductInOppo;
		System.assert(BTN_Utils.getOppoHasProducts(newOppo.Id));
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method test if parsing User from BSS to SF Contact works.
     * @return void
    */
	@isTest static void utilsBriteSheetParseUsersToContactsTester() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Account accountDAO = new BTN_DAO_Account();
            BTN_TestDataFactory.getBriteNetAccount();
            BTN_Utils.getSObjectIds(accountDAO.findAccounts());
            List<BTN_BSS_DTO.User> bsUserList = new List<BTN_BSS_DTO.User>();
            for (Integer i = 0; i < 200; i++) {
                BTN_BSS_DTO.User newBSUser = new BTN_BSS_DTO.User();
                newBSUser.user_id = i;
                newBSUser.user_fname = 'fname' + i;
                newBSUser.user_lname = 'lname' + i;
                newBSUser.user_mail = 'mm@mm.de';
                newBSUser.user_phone = '123456789';
                newBSUser.user_location = 'Spain';
                newBSUser.user_join_date = '2100-12-22';
                newBSUser.projectrole_desc = 'dev';
                newBSUser.user_deleted = false;
                bsUserList.add(newBSUser);
            }
            System.assertEquals(200, BTN_ContactUtils.newContactFromBS(bsUserList).size());
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method test if methods retrieving Currencies works.
     * @return void
    */
	@isTest static void currencyMethodsTester() {
		Integer currC = [SELECT count() FROM CurrencyType WHERE IsActive = true];
		System.assertEquals(currC, BTN_Utils.getAvailableCurrencyIsoCodeList(true).size());
		System.assertEquals(1, BTN_Utils.getAvailableCurrencyIsoCodeList(false).size()); 
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method test if XOR operation is ok.
     * @return void
    */
	@isTest static void xorSetsMethodTester() {
		Set<String> setA = new Set<String>{'JAVA', 'C', 'C++', 'JavaScript', 'HTML_CSS'
			, 'Android', 'IOS', 'WindowsPhone', 'Salesforce.com'};
		Set<String> setB = new Set<String>{'JAVA', 'C', 'JavaScript', 'HTML_CSS'
			, 'Android', 'IOS'};
		Set<String> expectedResult = new Set<String>{'C++', 'WindowsPhone', 'Salesforce.com'};
		
		System.assertEquals(expectedResult, BTN_Utils.setXor(setA, setB));
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testBuildAssignmentGroupString
    */
    @isTest static void testBuildAssignmentGroupString() {
        Id accId = BTN_TestDataFactory.getBriteNetAccount().Id;
        Id conId = BTN_TestDataFactory.getRequestorInternalContact(accId).Id;
        System.assertEquals(
                conId + ';' + accId,
                BTN_Utils.buldAssignmentGroupString(conId, accId)
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testBuildAssignmentGroupString
    */
    @isTest static void testFindAccountOnListByCompanyInfo() {
        List<Account> accounts = new List<Account>{
                BTN_TestDataFactory.getBriteNetAccount()
        };
        System.assertNotEquals(null, BTN_Utils.findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME, accounts));
    }

    /**
     * @author Pawel Iwanowicz
     * @date   2016-11-30
     * @description testpostInsertCandidatesStatuses
    */
    @isTest static void testpostInsertCandidatesStatuses() {

        BTN_TestDataFactory.getHRCollaborationGroup();

	    Account acc = BTN_TestDataFactory.getBriteNetAccount();
	    Contact requestor = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);

        BTN_ResourceRequest__c rr1 = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save();
        BTN_ResourceRequest__c rr2 = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save();

	    rr1.Resource_Manager__c = requestor.Id;
	    rr2.Resource_Manager__c = requestor.Id;
	    update new List<BTN_ResourceRequest__c>{rr1, rr2};

        Contact cont = BTN_ContactBuilderHelper.buildWithInternalRecordType().get();
        cont.Email = 'test-btn-utils@britenet.com.pl';
        insert cont;

        BTN_CV__c candidate1 = BTN_TestDataFactory.getCV(rr1.Id, cont.Id);
        System.assertEquals(BTN_ConstantRepo.CANDIDATE_STATUS_OPEN, candidate1.Status__c);

        BTN_CV__c candidate2 = new BTN_CV__c(
                ResourceRequest__c = rr2.Id,
                Status__c = BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED,
                Contact__c = cont.Id
        );
        insert candidate2;

        BTN_CV__c candidatetAfterChange = [SELECT id, Status__c FROM BTN_CV__c WHERE id = :candidate1.Id];

        System.assertEquals(BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED_WITH_DIFFERENT_EXTERNAL, candidatetAfterChange.Status__c);
    }

    /**
     * @author Pawel Iwanowicz
     * @date   2016-11-30
     * @description testpostUpdateCandidatesStatuses
    */
    @isTest static void testpostUpdateCandidatesStatuses() {

        BTN_TestDataFactory.getHRCollaborationGroup();

	    Account acc = BTN_TestDataFactory.getBriteNetAccount();
	    Contact requestor = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);

        BTN_ResourceRequest__c rr1 = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save();
        BTN_ResourceRequest__c rr2 = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save();

	    rr1.Resource_Manager__c = requestor.Id;
	    rr2.Resource_Manager__c = requestor.Id;
	    update new List<BTN_ResourceRequest__c>{rr1, rr2};

        Contact cont = BTN_ContactBuilderHelper.buildWithInternalRecordType().get();
        cont.Email = 'test-btn-utils@britenet.com.pl';
        insert cont;

        BTN_CV__c candidate1 = BTN_TestDataFactory.getCV(rr1.Id, cont.Id);
        System.assertEquals(BTN_ConstantRepo.CANDIDATE_STATUS_OPEN, candidate1.Status__c);
        BTN_CV__c candidate2 = BTN_TestDataFactory.getCV(rr2.Id, cont.Id);

        candidate2.Status__c = BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED;
        update candidate2;

        BTN_CV__c candidatetAfterChange = [SELECT id, Status__c FROM BTN_CV__c WHERE id = :candidate1.Id];

        System.assertEquals(BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED_WITH_DIFFERENT_EXTERNAL, candidatetAfterChange.Status__c);
    }
}