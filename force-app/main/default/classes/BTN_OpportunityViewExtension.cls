public with sharing class BTN_OpportunityViewExtension {
	private Opportunity mysObject;
	public List<SelectOption> pricebookOptions{set; get;}
	public String recordTypeName{set; get;}
	public List<Pricebook2> pricebooks{set; get;}
	public List<OpportunityStage> probStages{set; get{
			if(probStages == NULL) {
				return [SELECT Id, MasterLabel, DefaultProbability FROM OpportunityStage];
			} else {
				return probStages;
			}
		}}

	public BTN_OpportunityViewExtension(ApexPages.StandardController stdController) {
		this.mysObject = (Opportunity)stdController.getRecord();
		pricebooks = [SELECT Id, Name, IsStandard, CurrencyIsoCode FROM Pricebook2 WHERE IsActive = true];
		pricebookOptions = getpricebookOptionList();
	}

	public List<SelectOption> getpricebookOptionList() {
		Set<SelectOption> pbOptions = new Set<SelectOption>();
		if(mysObject.Pricebook2Id != NULL) {
			pbOptions.add(new SelectOption(mysObject.Pricebook2Id, mysObject.Pricebook2.Name));
		}
		String defaultCurrency = [SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true LIMIT 1].IsoCode;
		for(Pricebook2 item : pricebooks) {
			if(item.CurrencyIsoCode.equals(defaultCurrency)) {
				pbOptions.add(new SelectOption(item.Id, item.Name));
			}
		}
		for(Pricebook2 item : pricebooks) {
			pbOptions.add(new SelectOption(item.Id, item.Name));
		}
		return new List<SelectOption>(pbOptions);
	}

	public Boolean getHasProducts() {
		try {
			return BTN_Utils.getOppoHasProducts(mysObject.Id);
		} catch(Exception e) {
			return false;
		}
	}

	public void setOppoCurrency() {
		try {
			for (Pricebook2 item : pricebooks) {
				if (mysObject.Pricebook2Id.equals(item.Id)) {
					mysObject.CurrencyIsoCode = item.CurrencyIsoCode;
				}
			}
		} catch (Exception e) {
			mysObject.CurrencyIsoCode = NULL;
		}
	}

	public void setOpportunityProbability() {
		for (OpportunityStage item : probStages) {
			if (item.MasterLabel.equals(mysObject.StageName)) {
				mysObject.Probability = item.DefaultProbability;
			}
		}
	}

	public List<SelectOption> getRelatedContactsToAccount() {
		List<SelectOption> contacts = new List<SelectOption>();
		for (Contact item : [SELECT Id, Name, CurrencyIsoCode FROM Contact 
			WHERE AccountId = :mysObject.AccountId]) {
			contacts.add(new SelectOption(item.Id, item.Name));
		}
		return contacts;
	}

	public void setPriceBookByAccountCurrency() {
		if (!BTN_Utils.getOppoHasProducts(mysObject.Id)) {
			String curr = [SELECT CurrencyIsoCode FROM Account WHERE Id = :mysObject.AccountId].CurrencyIsoCode;
			mysObject.Pricebook2Id = [SELECT Id, CurrencyIsoCode FROM Pricebook2 WHERE CurrencyIsoCode = :curr AND IsActive = true LIMIT 1].Id;
			setOppoCurrency();
		}
	}
}