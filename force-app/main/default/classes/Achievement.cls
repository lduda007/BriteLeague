/**
 * Achievement Set Item wrapper class.
 * @author Adam Siwek
 */
public with sharing class Achievement {

    public Achievement_Set_Item__c oldRecord {get; set;}
    public Boolean selected {get; set;}

    private Achievement_Set_Item__c cmpRecord;
    private Achievement__c achievement;

    public Achievement(Achievement__c achievement, Achievement_Set_Item__c data) {
        if (achievement == null || data == null || achievement.Id != data.Achievement__c) {
            throw new SystemUtils.SystemException(System.Label.InvalidConstructorParameters);
        }
        this.achievement = achievement;
        this.oldRecord = data;
        this.selected = data.Id != null && getIsCert();
    }

    public Achievement setDataToCmp(Achievement_Set_Item__c dataToCmp) {
        if (dataToCmp == null || achievement.Id != dataToCmp.Achievement__c || dataToCmp.Achievement__c != oldRecord.Achievement__c) {
            throw new SystemUtils.SystemException(System.Label.InvalidMethodParameters);
        }
        this.cmpRecord = dataToCmp;
        return this;
    }

    public Boolean getIsSkill() {
        return achievement.RecordTypeId == AchievementUtils.getAchievementSkillRecordType().Id;
    }
    public Boolean getIsCert() {
        return achievement.RecordTypeId == AchievementUtils.getAchievementCertificateRecordType().Id;
    }
    public Boolean getIsBadge() {
        return achievement.RecordTypeId == AchievementUtils.getAchievementBadgeRecordType().Id;
    }
    public Boolean getIsGroup() {
        return achievement.RecordTypeId == AchievementUtils.getAchievementGroupRecordType().Id;
    }
    public Boolean getIsSpecialization() {
        return achievement.RecordTypeId == AchievementUtils.getAchievementSpecializationRecordType().Id;
    }
    public Boolean getIsAttribute() {
        return achievement.RecordTypeId == AchievementUtils.getAchievementAttributeRecordType().Id;
    }
    public Boolean getIsMonthsFromDate() {
        return achievement.RecordTypeId == AchievementUtils.getAchievementMonthsFromDateRecordType().Id;
    }

    public List<SelectOption> getAttributeLevels() {
        List<SelectOption> attributeLevels = new List<SelectOption>();
        attributeLevels.add(new SelectOption('', System.Label.None));
        for (Achievement_Value__c av : achievement.AchievementValues__r) {
            attributeLevels.add(new SelectOption(String.valueOf(av.Value__c), av.Name));
        }
        return attributeLevels;
    }

    public String getAttributeLevelValues() {
         return getValueLevel(oldRecord.Amount__c);
    }

    public String getCmpRecordAttributeLevelValues() {
        return getValueLevel(cmpRecord.Amount__c);
    }

    private String getValueLevel(Decimal amount) {
        Map<Integer, Achievement_Value__c> levelValues = AchievementService.getAchievementsValues().get(achievement.Id);
        String valueLevel = '';
        Integer tmp = Integer.valueOf(amount);
        if (!levelValues.isEmpty() && tmp != null){
            for(Integer key : levelValues.keySet()) {
                if(tmp - key >= 0) {
                    valueLevel += levelValues.get(key).name + ', ';
                    tmp = tmp - key;
                }
                if (tmp == 0) {
                    break;
                }
            }
            valueLevel = valueLevel.substring(0, valueLevel.length()-2);
        }
        return valueLevel;
    }

    public String getDescription() {
        String dsc = achievement.Details__c != null ? achievement.Details__c : achievement.Name;
        String endline = '\n';//'&#013;';
        if (getIsSkill()) {
            dsc += endline + 'Junior - ' + (achievement.Level_1_Details__c != null ? achievement.Level_1_Details__c : '');
            dsc += endline + 'Professional - ' + (achievement.Level_2_Details__c != null ? achievement.Level_2_Details__c : '');
            dsc += endline + 'Senior - ' + (achievement.Level_3_Details__c != null ? achievement.Level_3_Details__c : '');
        }
        return dsc;
    }

    public String getHTMLDescription() {
        String dsc = '<h2>' + (achievement.Details__c != null ? achievement.Details__c : achievement.Name) + '</h2>';
        String endline = '<br>';
        if (getIsSkill()) {
            dsc += endline + '<b>Junior</b> - ' + (achievement.Level_1_Details__c != null ? achievement.Level_1_Details__c : '');
            dsc += endline + '<b>Professional</b> - ' + (achievement.Level_2_Details__c != null ? achievement.Level_2_Details__c : '');
            dsc += endline + '<b>Senior</b> - ' + (achievement.Level_3_Details__c != null ? achievement.Level_3_Details__c : '');
        }
        return dsc;
    }

    public Boolean getHasValue() {
        return level != '' || amount != '0' || minSpecialityMatch != '0.0' || selected;
    }

    public Boolean getIsNew() {
        return oldRecord.Id == null;
    }

    public Boolean getIsModificableGroup() {
        return achievement.Group_Type__c == AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE;
    }

    public String level {
        get{return oldRecord.Level__c == null ? '' : oldRecord.Level__c;}
        set{oldRecord.Level__c = value;}
    }

    public String amount {
        get{return oldRecord.Amount__c == null ? '0' : String.valueOf(oldRecord.Amount__c);}
        set{oldRecord.Amount__c = value == null ? 0 : Integer.valueOf(value);}
    }

    public String minSpecialityMatch {
        get{return oldRecord.Min_Speciality_Match__c == null ? '0.0' : String.valueOf(oldRecord.Min_Speciality_Match__c);}
        set{oldRecord.Min_Speciality_Match__c = Double.valueOf(value);}
    }

    public String getName() {
        return achievement.Name;
    }

    public Boolean getHasValueToCompare() {
        return cmpRecord != null;
    }

    public Boolean getHasDifferentValue() {
        return getHasDifferentLevel() || getHasDifferentAmount() || getHasDifferentMinSpecialityMatch() || !getHasCert() || getHasDifferentNumberOfMonths() || getHasDifferentAttributeValue();
    }
    public Boolean getHasDifferentLevel() {
        return cmpRecord != null && AchievementUtils.compareLevel(oldRecord.Level__c, cmpRecord.Level__c);
    }
    public Boolean getHasDifferentAttributeValue() {
        return cmpRecord != null && oldRecord.Amount__c < cmpRecord.Amount__c && getIsAttribute();
    }
    public Boolean getHasDifferentAmount() {
        return cmpRecord != null && oldRecord.Amount__c < cmpRecord.Amount__c && getIsBadge();
    }
    public Boolean getHasDifferentMinSpecialityMatch() {
        return cmpRecord != null && oldRecord.Min_Speciality_Match__c < cmpRecord.Min_Speciality_Match__c;
    }
    public Boolean getHasCert() {
        return !(cmpRecord != null && !selected && getIsCert());
    }
    public Boolean getHasDifferentNumberOfMonths() {
        return cmpRecord != null && oldRecord.NumberOfMonths__c < cmpRecord.NumberOfMonths__c;
    }

    public String getDifferenceInfo() {
        if (getHasDifferentLevel()) {
            return ' (' + cmpRecord.Level__c + ')';
        }
        if (getHasDifferentAmount()) {
            return ' (' + String.valueOf(cmpRecord.Amount__c) + ')';
        }
        if (getHasDifferentNumberOfMonths()) {
            Double numberOfMonths = cmpRecord.NumberOfMonths__c.setScale(0);
            return ' (' + String.valueOf(numberOfMonths) + ')';
        }
        if (getHasDifferentMinSpecialityMatch()) {
            return ' (' + String.valueOf(cmpRecord.Min_Speciality_Match__c * 100) + '%)';
        }
        if (getHasDifferentAttributeValue()) {
            return   ' (' + getCmpRecordAttributeLevelValues() + ')';
        }
        return '';
    }
}