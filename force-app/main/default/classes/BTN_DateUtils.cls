public with sharing class BTN_DateUtils {
	/**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Method empowering date difference calculations. If endDate > startDate it will return negative value of working days.
	 similar to formula:
			CASE(MOD( ContractStart__c - DATE(1985,6,24),7),
			0 , CASE( MOD( ContractEnd__c - ContractStart__c ,7),1,2,2,3,3,4,4,5,5,5,6,5,1),
			1 , CASE( MOD( ContractEnd__c - ContractStart__c ,7),1,2,2,3,3,4,4,4,5,4,6,5,1),
			2 , CASE( MOD( ContractEnd__c - ContractStart__c ,7),1,2,2,3,3,3,4,3,5,4,6,5,1),
			3 , CASE( MOD( ContractEnd__c - ContractStart__c ,7),1,2,2,2,3,2,4,3,5,4,6,5,1),
			4 , CASE( MOD( ContractEnd__c - ContractStart__c ,7),1,1,2,1,3,2,4,3,5,4,6,5,1),
			5 , CASE( MOD( ContractEnd__c - ContractStart__c ,7),1,0,2,1,3,2,4,3,5,4,6,5,0),
			6 , CASE( MOD( ContractEnd__c - ContractStart__c ,7),1,1,2,2,3,3,4,4,5,5,6,5,0),
			999)
			+
			(FLOOR(( ContractEnd__c - ContractStart__c )/7)*5)
     * @return difference in days
    */
	public static Integer getDiffBusinessDays(Date startdt, Date enddt) {
        Integer result;
        if (BTN_ValidationHandler.isParamSetForDateUtilsValid(startdt, enddt)) {
            Date tempdate = null;
            if (startdt > enddt) {
                tempdate = enddt;
                enddt = startdt;
                startdt = tempdate;
            }
            Integer i = Math.mod((date.newinstance(1985, 6, 24)).daysBetween(startdt), 7); // 24/6/85 was a monday
            Map<Integer, Map<Integer, Integer>> m = new Map<Integer, Map<Integer, Integer>>{
                    0 => new Map<Integer, Integer>{
                            1 => 2, 2 => 3, 3 => 4, 4 => 5, 5 => 5, 6 => 5
                    },
                    1 => new Map<Integer, Integer>{
                            1 => 2, 2 => 3, 3 => 4, 4 => 4, 5 => 4, 6 => 5
                    },
                    2 => new Map<Integer, Integer>{
                            1 => 2, 2 => 3, 3 => 3, 4 => 3, 5 => 4, 6 => 5
                    },
                    3 => new Map<Integer, Integer>{
                            1 => 2, 2 => 2, 3 => 2, 4 => 3, 5 => 4, 6 => 5
                    },
                    4 => new Map<Integer, Integer>{
                            1 => 1, 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5
                    },
                    5 => new Map<Integer, Integer>{
                            1 => 0, 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5
                    },
                    6 => new Map<Integer, Integer>{
                            1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 5
                    }
            };
            Integer i2 = Math.mod((startdt.daysBetween(enddt)), 7);
            Integer i3 = (m.get(i)).get(i2);
            if (i2 == null || i2 < 1 || i2 > 6) {
                if (i >= 0 && i <= 4) {
                    i3 = 1;
                } else {
                    i3 = 0;
                }
            }
            i3 = i3 + 5 * (Math.floor(((Decimal) startdt.daysBetween(enddt)).divide(7, 4))).intValue();
            if (tempdate != null) {
                i3 *= -1;
            } // negative number of days
            result = i3;
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-08
     * @description getPastUNIXTimeStamp returns UNIX time stamp
     * @param minusDays Days between Now and returned Timestamp for positive value timestamp in the past
     * @return Long  UNIX format timestamp
     */
    public static Long getPastUNIXTimeStamp(Integer minusDays) {
        return DateTime.now().addDays(-minusDays).getTime();
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-09-16
     * @description parses date
     * @param inDate date in string format
     * @return Date
     * @Link - https://developer.salesforce.com/forums/?id=906F000000093wuIAA
     */
    public static Date parseDate(String inDate) {
		Date	dateRes		= null;
		//	1 - Try locale specific mm/dd/yyyy or dd/mm/yyyy	
		try {
			String candDate		= inDate.substring(0,Math.min(10,inDate.length()));// grab date portion only m[m]/d[d]/yyyy , ignore time
			dateRes 	= Date.parse(candDate);
		}
		catch (Exception e) {}
	
		if (dateRes == null) {
		//	2 - Try yyyy-mm-dd			
			try {
				String candDate		= inDate.substring(0,10);			// grab date portion only, ignore time, if any
				dateRes				= Date.valueOf(candDate);
			}
			catch (Exception e) {} 
		}
		
		return dateRes;
	}
	
	 /**
     * @author Wojciech Mazur
     * @date   2016-09-16
     * @description parses date
     * @param inDate date in string format
     * @return Date
     * @Link - https://developer.salesforce.com/forums/?id=906F000000093wuIAA
     */
    public static String getMonthName(Date inDate) {
    	if(inDate == null)
    		return null;
    	
    	Map<Integer, String> months = new Map<Integer, String>
    			{1=>'January',
    			2=>'February',
    			3=>'March',
    			4=>'April',
    			5=>'May',
    			6=>'June',
    			7=>'July',
    			8=>'August',
    			9=>'September',
    			10=>'October',
    			11=>'November',
    			12=>'December'};
    	return months.get(inDate.month());
    }
}