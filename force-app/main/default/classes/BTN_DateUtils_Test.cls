/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description Class test utils for Dates
*/
@isTest
private class BTN_DateUtils_Test {
    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Test date differences.
     * @return
    */
	@isTest static void testDateDiffMethod() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            System.assertEquals(
                    1313, BTN_DateUtils.getDiffBusinessDays(Date.newInstance(2016, 1, 20), Date.newInstance(2021, 1, 30)));
            System.assertEquals(
                    -1313, BTN_DateUtils.getDiffBusinessDays(Date.newInstance(2021, 1, 30), Date.newInstance(2016, 1, 20)));
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Test cases with null values.
     * @return
    */
	@isTest static void testDateDiffMethodWithNull() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            System.assertEquals(null, BTN_DateUtils.getDiffBusinessDays(null, Date.newInstance(2016, 1, 20)));
            System.assertEquals(null, BTN_DateUtils.getDiffBusinessDays(Date.newInstance(2016, 1, 20), null));
            System.assertEquals(null, BTN_DateUtils.getDiffBusinessDays(null, null));
        }
	}
	
	/**
     * @author Wojciech Mazur
     * @date   2016-09-16
     * @description test for parseDate method
     * @Link - https://developer.salesforce.com/forums/?id=906F000000093wuIAA
     */
	@isTest static void testParseDate() {
		System.assertEquals(Date.newInstance(2020,1,1),		BTN_DateUtils.parseDate('2020-01-01'));
		System.assertEquals(Date.newInstance(2020,1,1),		BTN_DateUtils.parseDate('2020-01-01T01:09:00Z'));
		//System.assertEquals(Date.newInstance(2020,1,1),		BTN_DateUtils.parseDate('01/01/2020'));
		//System.assertEquals(Date.newInstance(2020,1,1),		BTN_DateUtils.parseDate('1/1/2020'));
		//System.assertEquals(Date.newInstance(2020,1,1),		BTN_DateUtils.parseDate('01/01/2020 05:08:00.000-0800'));
		System.assertEquals(null,							BTN_DateUtils.parseDate(null));
		System.assertEquals(null,							BTN_DateUtils.parseDate(''));
		System.assertEquals(null,							BTN_DateUtils.parseDate('ab/de/1201'));
		System.assertEquals(null,							BTN_DateUtils.parseDate('13/01/2020'));
		System.assertEquals(null,							BTN_DateUtils.parseDate('2020-13-01'));
	}
	
	/**
     * @author Wojciech Mazur
     * @date   2016-09-16
     * @description test for getMonthName method
     * @Link - https://developer.salesforce.com/forums/?id=906F000000093wuIAA
     */
	@isTest static void testGetMonthName() {
		System.assertEquals('January',		BTN_DateUtils.getMonthName(Date.newInstance(2020,1,1)));
		System.assertEquals('February',		BTN_DateUtils.getMonthName(Date.newInstance(2020,2,1)));
		System.assertEquals('March',		BTN_DateUtils.getMonthName(Date.newInstance(2020,3,1)));
		System.assertEquals('April',		BTN_DateUtils.getMonthName(Date.newInstance(2020,4,1)));
		System.assertEquals('May',			BTN_DateUtils.getMonthName(Date.newInstance(2020,5,1)));
		System.assertEquals('June',			BTN_DateUtils.getMonthName(Date.newInstance(2020,6,1)));
		System.assertEquals('July',			BTN_DateUtils.getMonthName(Date.newInstance(2020,7,1)));
		System.assertEquals('August',		BTN_DateUtils.getMonthName(Date.newInstance(2020,8,1)));
		System.assertEquals('September',	BTN_DateUtils.getMonthName(Date.newInstance(2020,9,1)));
		System.assertEquals('October',		BTN_DateUtils.getMonthName(Date.newInstance(2020,10,1)));
		System.assertEquals('November',		BTN_DateUtils.getMonthName(Date.newInstance(2020,11,1)));
		System.assertEquals('December',		BTN_DateUtils.getMonthName(Date.newInstance(2020,12,1)));
	}
}