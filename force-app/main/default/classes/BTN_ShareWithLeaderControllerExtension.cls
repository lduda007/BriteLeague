/**
 * Created by Adam on 5/23/2018.
 */

public without sharing class BTN_ShareWithLeaderControllerExtension {

	private static final String LEADER_NAME_PLACEHOLDER = 'Leader';
	private static final String LEADER_NAME_PLACEHOLDER_LABEL = '-- Select leader --';

	private Contact recruit;
	private Map<String, Contact> leadersByNameMap;

	public String selectedLeaderName { get; set; }
	public String title { get; set; }

	public BTN_ShareWithLeaderControllerExtension(ApexPages.StandardController stdController) {
		if(!Test.isRunningTest()) stdController.addFields(new List<String>{'Name'});
		this.recruit = (Contact) stdController.getRecord();
		this.leadersByNameMap = new BTN_DAO_Contact().getLeadersByName();
		this.title = String.format(System.Label.ShareWithLeader, new List<String>{this.recruit.Name});
	}

	public List<SelectOption> getLeaderNames(){
		List<SelectOption> options = new List<SelectOption>();

		// add this option as placeholder
		options.add(new SelectOption(LEADER_NAME_PLACEHOLDER, LEADER_NAME_PLACEHOLDER_LABEL));

		for(String leaderName : leadersByNameMap.keySet()){
			options.add(new SelectOption(leaderName, leaderName));
		}

		return options;
	}

	public PageReference shareWithLeader(){
		Contact selectedLeader = leadersByNameMap.get(selectedLeaderName);
		User leaderUser = new BTN_DAO_User().findUserByEmail(selectedLeader.Email);

		if(leaderUser != null){
			Boolean sharingSuccessful = BTN_ContactShareUtils.shareRecruitsWithContacts(recruit, leaderUser.Id);
			if(!sharingSuccessful){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occurred while sharing recruit record with leader. Please contact administrator'));
				return null;
			} else {
				return new PageReference('/' + recruit.Id);
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occurred while sharing recruit record with leader. Please contact administrator'));
			return null;
		}
	}

}