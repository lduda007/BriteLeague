/**
 * Achievement class tests
 * @author Adam Siwek
 */
@isTest
private class AchievementTest {

    @isTest
    private static void testTheInvalidConstructorAtritbutes() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill1 = new AchievementUtils.AchievementBuilder('Skill1', base).asSkill().buildAndSave();
        Achievement__c skill2 = new AchievementUtils.AchievementBuilder('Skill2', base).asSkill().buildAndSave();

        Achievement_Set__c pp1 = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').asPositionProfile(careerPath).
                addSkill(skill1, AchievementUtils.ACHIEVEMENT_LEVEL_1).buildAndSave();
        Achievement_Set__c pp2 = new AchievementUtils.AchievementSetBuilder('Senior Java Developer').asPositionProfile(careerPath).
                addSkill(skill2, AchievementUtils.ACHIEVEMENT_LEVEL_3).buildAndSave();

        try {
            new Achievement(skill1, null);
            System.assert(false, 'Should not create class instance when achievement set item is not set');
        } catch (SystemUtils.SystemException ex) {}

        try {
            new Achievement(null, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c LIMIT 1]);
            System.assert(false, 'Should not create class instance when achievement is not set');
        } catch (SystemUtils.SystemException ex) {}

        try {
            new Achievement(skill1, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c != :skill1.Id LIMIT 1]);
            System.assert(false, 'Should not create class instance when achievement is not related with the achievement set item');
        } catch (SystemUtils.SystemException ex) {}
    }

    @isTest
    private static void testTheInvalidRecordToCompare() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill1 = new AchievementUtils.AchievementBuilder('Skill1', base).asSkill().buildAndSave();
        Achievement__c skill2 = new AchievementUtils.AchievementBuilder('Skill2', base).asSkill().buildAndSave();

        Achievement_Set__c pp1 = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').asPositionProfile(careerPath).
                addSkill(skill1, AchievementUtils.ACHIEVEMENT_LEVEL_1).buildAndSave();
        Achievement_Set__c pp2 = new AchievementUtils.AchievementSetBuilder('Senior Java Developer').asPositionProfile(careerPath).
                addSkill(skill2, AchievementUtils.ACHIEVEMENT_LEVEL_3).buildAndSave();

        Achievement wrapper = new Achievement(skill1, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c = :skill1.Id LIMIT 1]);
        try {
            wrapper.setDataToCmp(null);
            System.assert(false, 'Data to compare cannot be null');
        } catch (SystemUtils.SystemException ex) {}

        try {
            wrapper.setDataToCmp([SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c != :skill1.Id LIMIT 1]);
            System.assert(false, 'Data to compare cannot be ralated to different achievent');
        } catch (SystemUtils.SystemException ex) {}
    }

    @isTest
    private static void shouldReturnValidValues() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement_Set__c specializationAchievementSet = new AchievementUtils.AchievementSetBuilder('Specialization').asProfile(careerPath).buildAndSave();

        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().build();
        Achievement__c cert = new AchievementUtils.AchievementBuilder('Cert1', base).asCert().build();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge1', base).asBadge().build();
        Achievement__c groupAch = new AchievementUtils.AchievementBuilder('Group', base).asGroup().build();
        Achievement__c specialization = new AchievementUtils.AchievementBuilder('Specialization', base).asSpecialization(specializationAchievementSet).build();
        insert new Achievement__c[] {skill, cert, badge, groupAch, specialization};

        Achievement_Set__c pp = new AchievementUtils.AchievementSetBuilder('Senior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addCert(cert).
                addBadge(badge, 2).
                addGroup(groupAch, 1).
                addSpecialization(specialization, 0.3.doubleValue()).
                buildAndSave();

        Achievement wrapper = new Achievement(skill, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c = :skill.Id LIMIT 1]);
        System.assertEquals(AchievementUtils.ACHIEVEMENT_LEVEL_2, wrapper.level);
        System.assertEquals(skill.Name, wrapper.getName());
        System.assertEquals(true, wrapper.getIsSkill());
        System.assertEquals(false, wrapper.getIsCert());
        System.assertEquals(false, wrapper.getIsGroup());
        System.assertEquals(false, wrapper.getIsBadge());
        System.assertEquals(false, wrapper.getIsNew());
        System.assertEquals(true, wrapper.getHasValue());
        System.assertEquals(false, wrapper.getHasDifferentValue());
        System.assertEquals('', wrapper.getDifferenceInfo());

        wrapper = new Achievement(badge, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c = :badge.Id LIMIT 1]);
        System.assertEquals('2', wrapper.amount);
        System.assertEquals(badge.Name, wrapper.getName());
        System.assertEquals(false, wrapper.getIsSkill());
        System.assertEquals(false, wrapper.getIsCert());
        System.assertEquals(true, wrapper.getIsBadge());
        System.assertEquals(false, wrapper.getIsGroup());
        System.assertEquals(false, wrapper.getIsSpecialization());
        System.assertEquals(false, wrapper.getIsNew());
        System.assertEquals(true, wrapper.getHasValue());
        System.assertEquals(false, wrapper.getHasDifferentValue());
        System.assertEquals('', wrapper.getDifferenceInfo());

        wrapper = new Achievement(cert, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c = :cert.Id LIMIT 1]);
        System.assertEquals(true, wrapper.selected);
        System.assertEquals(cert.Name, wrapper.getName());
        System.assertEquals(false, wrapper.getIsSkill());
        System.assertEquals(true, wrapper.getIsCert());
        System.assertEquals(false, wrapper.getIsBadge());
        System.assertEquals(false, wrapper.getIsGroup());
        System.assertEquals(false, wrapper.getIsSpecialization());
        System.assertEquals(false, wrapper.getIsNew());
        System.assertEquals(true, wrapper.getHasValue());
        System.assertEquals(false, wrapper.getHasDifferentValue());
        System.assertEquals('', wrapper.getDifferenceInfo());

        wrapper = new Achievement(groupAch, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c = :groupAch.Id LIMIT 1]);
        System.assertEquals('1', wrapper.amount);
        System.assertEquals(groupAch.Name, wrapper.getName());
        System.assertEquals(false, wrapper.getIsSkill());
        System.assertEquals(false, wrapper.getIsCert());
        System.assertEquals(false, wrapper.getIsBadge());
        System.assertEquals(true, wrapper.getIsGroup());
        System.assertEquals(false, wrapper.getIsSpecialization());
        System.assertEquals(false, wrapper.getIsNew());
        System.assertEquals(true, wrapper.getHasValue());
        System.assertEquals(false, wrapper.getHasDifferentValue());
        System.assertEquals('', wrapper.getDifferenceInfo());

        wrapper = new Achievement(specialization, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__c = :specialization.Id LIMIT 1]);
        System.assertEquals('0.30', wrapper.minSpecialityMatch);
        System.assertEquals(specialization.Name, wrapper.getName());
        System.assertEquals(false, wrapper.getIsSkill());
        System.assertEquals(false, wrapper.getIsCert());
        System.assertEquals(false, wrapper.getIsBadge());
        System.assertEquals(false, wrapper.getIsGroup());
        System.assertEquals(true, wrapper.getIsSpecialization());
        System.assertEquals(false, wrapper.getIsNew());
        System.assertEquals(true, wrapper.getHasValue());
        System.assertEquals(false, wrapper.getHasDifferentValue());
        System.assertEquals('', wrapper.getDifferenceInfo());
    }


    @isTest
    private static void shouldDetermineDifferences() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().build();
        Achievement__c cert = new AchievementUtils.AchievementBuilder('Cert1', base).asCert().build();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge1', base).asBadge().build();
        insert new Achievement__c[] {skill, cert, badge};

        Achievement_Set__c pp1 = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addBadge(badge, 2).
                buildAndSave();
        Achievement_Set__c pp2 = new AchievementUtils.AchievementSetBuilder('Senior Java Developer').
                asProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_3).
                addCert(cert).
                addBadge(badge, 3).
                buildAndSave();

        Achievement wrapper = new Achievement(skill, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :skill.Id AND Achievement_Set__c =:pp1.Id LIMIT 1]);
        wrapper.setDataToCmp([SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :skill.Id AND Achievement_Set__c =:pp2.Id LIMIT 1]);
        wrapper.level = AchievementUtils.ACHIEVEMENT_LEVEL_1;
        System.assertEquals(true, wrapper.getHasDifferentValue());
        System.assertEquals(true, wrapper.getHasDifferentLevel());
        System.assertNotEquals('', wrapper.getDifferenceInfo());

        wrapper = new Achievement(badge, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :badge.Id AND Achievement_Set__c =:pp1.Id LIMIT 1]);
        wrapper.setDataToCmp([SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :badge.Id AND Achievement_Set__c =:pp2.Id LIMIT 1]);
        wrapper.amount = '1';
        System.assertEquals(true, wrapper.getHasDifferentValue());
        System.assertEquals(true, wrapper.getHasDifferentAmount());
        System.assertNotEquals('', wrapper.getDifferenceInfo());

        wrapper = new Achievement(cert, new Achievement_Set_Item__c(Achievement__c=cert.Id));
        wrapper.setDataToCmp([SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :cert.Id AND Achievement_Set__c =:pp2.Id LIMIT 1]);
        System.assertEquals(true, wrapper.getHasDifferentValue());
        System.assertEquals('', wrapper.getDifferenceInfo());
        System.assertEquals(false, wrapper.getHasCert());
    }

    @isTest
    private static void shouldGetDescriptionWhenAchievementIsSkill() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                buildAndSave();
        Achievement a = new Achievement(skill, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :skill.Id AND Achievement_Set__c =:achievementSet.Id LIMIT 1]);

        System.assertEquals('Skill\nJunior - \nProfessional - \nSenior - ', a.getDescription());
    }

    @isTest
    private static void shouldGetEmptyDescriptionWhenAchievementIsNotSkill() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge1', base).asBadge().buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').
                asPositionProfile(careerPath).
                addBadge(badge, 2).
                buildAndSave();
        Achievement a = new Achievement(badge, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :badge.Id AND Achievement_Set__c =:achievementSet.Id LIMIT 1]);

        System.assertEquals('Badge1', a.getDescription());
    }

    @isTest
    private static void shouldGetHTMLDescriptionWhenAchievementIsSkill() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                buildAndSave();
        Achievement a = new Achievement(skill, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :skill.Id AND Achievement_Set__c =:achievementSet.Id LIMIT 1]);

        System.assertEquals('<h2>Skill</h2><br><b>Junior</b> - <br><b>Professional</b> - <br><b>Senior</b> - ', a.getHTMLDescription());
    }

    @isTest
    private static void shouldGetEmptyHTMLDescriptionWhenAchievementIsNotSkill() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge1', base).asBadge().buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').
                asPositionProfile(careerPath).
                addBadge(badge, 2).
                buildAndSave();
        Achievement a = new Achievement(badge, [SELECT Achievement__c, Level__c, Amount__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement__c = :badge.Id AND Achievement_Set__c =:achievementSet.Id LIMIT 1]);

        System.assertEquals('<h2>Badge1</h2>', a.getHTMLDescription());
    }
}