/**
 * Created by Adam on 5/28/2018.
 */

@IsTest
private class BTN_ShareWithLeaderControllerExt_Test
{
	static testMethod void shareWithLeader_test(){
		BTN_TestDataFactory.getTriggerSkipperCustomSetting();
		BTN_TestDataFactory.getHRCollaborationGroup();

		Account britenet = BTN_TestDataFactory.getBriteNetAccount();

		Contact leader = BTN_TestDataFactory.getLeaderInternalContact(britenet.Id);
		leader = new BTN_DAO_Contact().findContactById(leader.Id);

		Contact recruit = BTN_TestDataFactory.getRecruitContact(britenet.Id, '');

		Profile leaderProfile = new BTN_DAO_Profile().findProfileByName(BTN_ConstantRepo.PROFILE_NAME_COMMUNITY);
		//UserRole leaderRole = new BTN_DAO_Role().findByName(BTN_UserRoleUtils.ROLE_NAME_BTN_CUSTOMER_USER);

		User leaderUser;

		System.runAs(new BTN_DAO_User().findUserByEmail(UserInfo.getUserEmail())){
			leaderUser = BTN_UserBuilderHelper.buildUserWithDefaults()
					.withContactId(leader.Id)
					.withProfile(leaderProfile.Id)
					.withEmail(leader.Email)
					//.withRole(leaderRole.Id)
					.isActive(true)
					.save();

			BTN_PermissionSetUtils.assignPermissionSetToUser(BTN_ConstantRepo.PERM_SET_NAME_TECHNICAL_LEADER, leaderUser);
		}

		PageReference testPage = Page.BTN_ShareWithLeader;
		testPage.getParameters().put(BTN_ConstantRepo.URL_PARAM_CONTACT_ID, recruit.Id);
		Test.setCurrentPage(testPage);

		ApexPages.StandardController stdController = new ApexPages.StandardController(recruit);
		BTN_ShareWithLeaderControllerExtension controller = new BTN_ShareWithLeaderControllerExtension(stdController);

		Test.startTest();

		controller.selectedLeaderName = leader.Name;
		PageReference returnedPageReference = controller.shareWithLeader();

		Test.stopTest();

		System.assertEquals(new PageReference('/' +recruit.Id).getUrl(), returnedPageReference.getUrl());

		List<ContactShare> contactShares = new BTN_DAO_ContactShare().findByContactIdAndRowCause(recruit.Id, 'Manual');
		System.assertEquals(1, contactShares.size());
		System.assertEquals(leaderUser.Id, contactShares[0].UserOrGroupId);
	}

	static testMethod void getLeaderNames_test(){
		BTN_TestDataFactory.getTriggerSkipperCustomSetting();
		BTN_TestDataFactory.getHRCollaborationGroup();

		Account britenet = BTN_TestDataFactory.getBriteNetAccount();

		Contact leader = BTN_TestDataFactory.getLeaderInternalContact(britenet.Id);
		leader = new BTN_DAO_Contact().findContactById(leader.Id);
		Contact recruit = BTN_TestDataFactory.getRecruitContact(britenet.Id, '');

		PageReference testPage = Page.BTN_ShareWithLeader;
		testPage.getParameters().put(BTN_ConstantRepo.URL_PARAM_CONTACT_ID, recruit.Id);
		Test.setCurrentPage(testPage);

		ApexPages.StandardController stdController = new ApexPages.StandardController(recruit);
		BTN_ShareWithLeaderControllerExtension controller = new BTN_ShareWithLeaderControllerExtension(stdController);

		Test.startTest();

		List<SelectOption> leaderNames = controller.getLeaderNames();

		Test.stopTest();

		System.assertEquals(2, leaderNames.size());
		// checking the second item, first is a placeholder
		System.assertEquals(leader.Name, leaderNames[1].getValue());
	}
}