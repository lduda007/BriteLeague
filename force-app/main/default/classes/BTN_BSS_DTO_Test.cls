@isTest
private class BTN_BSS_DTO_Test {
    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Parse static JSON to Contact.
     */
	@isTest static void testParseJSONtoContact() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            System.assertEquals(
                    1,
                    BTN_BSS_DTO.parseCert(new BTN_BSS_Mockup(BTN_BSS_Mockup.USER_MODE, 200).generateUserJSON(1)).size());
        }
	}
}