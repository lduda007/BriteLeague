/**
 * Visualforce page controller extension for the Achievements Set record manipulations
 * @author Adam Siwek
 */
public with sharing virtual class AchievementSetPageExtension {

    public Achievement_Set__c achievementSet {get; set;}
    private Id achievementSetId;
    protected Id achievementSetToCmpId;

    public String searchAchievementName {get; set;}
    private List<CategoryWrapper> categoryFilters = new List<CategoryWrapper>();


    private List<SelectOption> achievementLevels = new List<SelectOption>();
    private List<AchievementUtils.AchievementGroup> achievementGroups = new List<AchievementUtils.AchievementGroup>();

    public AchievementSetPageExtension(ApexPages.StandardController ctr) {
        SObject record = getContextRecord(ctr, System.currentPageReference().getParameters());

        if (System.currentPageReference().getParameters().containsKey('RecordType')) {
            Id recordTypeId = System.currentPageReference().getParameters().get('RecordType');
            record.put('RecordTypeId', recordTypeId);
        }

        loadFirstAchievementSet(record, ApexPages.currentPage().getParameters());
        loadSecondAchievementSet(record, ApexPages.currentPage().getParameters());

        achievementSetId = achievementSet.Id;
    }

    protected virtual SObject getContextRecord(ApexPages.StandardController ctr, Map<String, String> pageParams) {
        try {
            return ctr.getRecord();
        } catch (Exception e) {
        }
        Id recordId = System.currentPageReference().getParameters().get('id');
        SObject record = new Achievement_Set__c();
        record.put('Id', recordId);
        return record;
    }

    protected virtual void loadFirstAchievementSet(SObject scopeRecord, Map<String, String> pageParams) {
        if (scopeRecord.Id != null) {
            achievementSet = [SELECT Id, Name, RecordTypeId, Score_Minimal_Value__c, Contact__c, Career_Path__c, Number_Of_Achievements__c, Parent_Profile__c, Who__c, AboutWho__c, SelfSurvey__c, Skip_Score_Calculation__c FROM Achievement_Set__c WHERE Id = :scopeRecord.Id AND IsDeleted = false LIMIT 1 ALL ROWS];
        } else {
            achievementSet = (Achievement_Set__c)scopeRecord;
        }
    }

    protected virtual void loadSecondAchievementSet(SObject scopeRecord, Map<String, String> pageParams) {
        if (pageParams.containsKey('achievementSetToCmp')) {
            achievementSetToCmpId = pageParams.get('achievementSetToCmp');
        }
    }

    public Boolean getCanEditAchievementSetName() {
        return achievementSet.RecordTypeId != AchievementUtils.getAchievementSetContactProfileRecordType().Id &&
                achievementSet.RecordTypeId != AchievementUtils.getAchievementSetSurveyRecordType().Id;
    }

    public Boolean getShowWhoField() {
        return achievementSet.RecordTypeId == AchievementUtils.getAchievementSetSurveyRecordType().Id;
    }

    public Boolean getShowAchievementSetContact() {
        return achievementSet.RecordTypeId == AchievementUtils.getAchievementSetContactProfileRecordType().Id;
    }

    public Boolean getShowAchievementSetMinScoreValue() {
        return achievementSet.RecordTypeId == AchievementUtils.getAchievementSetProfileRecordType().Id ||
                achievementSet.RecordTypeId == AchievementUtils.getAchievementSetPositionRecordType().Id;
    }

    public Boolean getShowCareerPath() {
        return achievementSet.RecordTypeId == AchievementUtils.getAchievementSetProfileRecordType().Id ||
                achievementSet.RecordTypeId == AchievementUtils.getAchievementSetPositionRecordType().Id;
    }

    public Boolean getShowGroups() {
        return achievementSet.RecordTypeId == AchievementUtils.getAchievementSetProfileRecordType().Id ||
                achievementSet.RecordTypeId == AchievementUtils.getAchievementSetPositionRecordType().Id;
    }

    public Boolean getShowSpecializations() {
        return achievementSet.RecordTypeId == AchievementUtils.getAchievementSetPositionRecordType().Id;
    }

    public Boolean getShowSpecializationGroups() {
        return achievementSet.RecordTypeId == AchievementUtils.getAchievementSetPositionRecordType().Id;
    }

    public SelectOption[] getAchievementLevels() {
        if (achievementLevels.isEmpty()) {
            List<Schema.PicklistEntry> ple = Achievement_Set_Item__c.Level__c.getDescribe().getPicklistValues();

            achievementLevels.add(new SelectOption('', System.Label.None));
            for (Schema.PicklistEntry pe : ple) {
                achievementLevels.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
        return achievementLevels;
    }

    public List<AchievementUtils.AchievementGroup> getAchievementGroups() {
        if (achievementGroups.isEmpty()) {
            achievementGroups = AchievementService.getAchievementGroups(achievementSetId, achievementSetToCmpId);
        }
        return applyFilter(achievementGroups);
    }

    private List<AchievementUtils.AchievementGroup> applyFilter(List<AchievementUtils.AchievementGroup> data) {
        List<AchievementUtils.AchievementGroup> filteredData = new List<AchievementUtils.AchievementGroup>();

        Set<String> categories = new Set<String>();
        for (CategoryWrapper cw : categoryFilters) {
            if (cw.selected) {
                categories.add(cw.category.Name.toLowerCase());
            }
        }

        for (AchievementUtils.AchievementGroup grp : data) {
            if (categories.contains(grp.name.toLowerCase())) {
                filteredData.add(grp);
            }
        }

        return filteredData;
    }

    public List<CategoryWrapper> getCategoryFilters() {
        if (categoryFilters.isEmpty()) {
            for (Achievement_Category__c ac : AchievementService.getAllAchievementCategories()) {
                categoryFilters.add(new CategoryWrapper(ac));
            }
        }
        return categoryFilters;
    }

    public void selectAllCategories() {
        for (CategoryWrapper cw : categoryFilters) {
            cw.selected = true;
        }
    }

    public void unselectAllCategories() {
        for (CategoryWrapper cw : categoryFilters) {
            cw.selected = false;
        }
    }

    public PageReference saveAchievementSet() {
        System.Savepoint sp = Database.setSavepoint();
        try {
            if (achievementSet.Id == null) {
                insert achievementSet;
                achievementSetId = achievementSet.Id;
                AchievementService.applyAchievementsToSet(achievementSet.Id, achievementGroups);
            } else {
                update achievementSet;
            }
            if (achievementSet.Skip_Score_Calculation__c != null && achievementSet.Skip_Score_Calculation__c) {
                achievementSet.Score_Minimal_Value__c = 0;
            }
            AchievementService.save(achievementGroups);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Saved_Successfully));
            if (ApexPages.currentPage().getParameters().get('saveURL') != null) {
                return new PageReference(ApexPages.currentPage().getParameters().get('saveURL')).setRedirect(true);
            } else {
                return new PageReference('/' + achievementSet.Id).setRedirect(true);
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }
        return null;
    }

    public with sharing class CategoryWrapper {
        public Boolean selected {get; set;}
        public Achievement_Category__c category {get; private set;}

        public CategoryWrapper(Achievement_Category__c category) {
            this.category = category;
            selected = true;
        }
    }
}