@IsTest
private class BTN_LogUtils_Test {

	 /**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description Test checks logs with error level
	 */
	static testMethod void checksErrorLogs() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
		    checkLoggingClass(BTN_LogUtils.ERROR);
        }
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description Test checks logs with warning level
	 */
	static testMethod void checksWarningLogs() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
		    checkLoggingClass(BTN_LogUtils.WARN);
        }
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description Test checks logs with info level
	 */
	static testMethod void checksInfoLogs() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            checkLoggingClass(BTN_LogUtils.INFO);
        }
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description Test checks logs with debug level
	 */
	static testMethod void checksDebugLogs() {
		System.RunAs(BTN_Utils.getCurrentUser()) {
			checkLoggingClass(BTN_LogUtils.DEBUG);
		}
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description checkLoggingClass - helper method for checking saved logs for specified level with different parameters
	 * @param String level - log level
	 */
	private static void checkLoggingClass(String level) {
		String className = 'testClass';
		BTN_LogUtils logger = new BTN_LogUtils(className);
		Map<Id, LogData> data = createLogTestData();

		if (level == BTN_LogUtils.ERROR) {
			logger.error(data.get(getId().get('0')).message, data.get(getId().get('0')).parentId);
			logger.error(data.get(getId().get('1')).message, data.get(getId().get('1')).parentId, data.get(getId().get('1')).listMsg);
			logger.error(data.get(getId().get('2')).message, data.get(getId().get('2')).parentId, data.get(getId().get('2')).setMsg);
			logger.error(data.get(getId().get('3')).message, data.get(getId().get('3')).parentId, data.get(getId().get('3')).mapMsg);
		}

		if (level == BTN_LogUtils.WARN) {
			logger.warning(data.get(getId().get('0')).message, data.get(getId().get('0')).parentId);
			logger.warning(data.get(getId().get('1')).message, data.get(getId().get('1')).parentId, data.get(getId().get('1')).listMsg);
			logger.warning(data.get(getId().get('2')).message, data.get(getId().get('2')).parentId, data.get(getId().get('2')).setMsg);
			logger.warning(data.get(getId().get('3')).message, data.get(getId().get('3')).parentId, data.get(getId().get('3')).mapMsg);
		}

		if (level == BTN_LogUtils.INFO) {
			logger.info(data.get(getId().get('0')).message, data.get(getId().get('0')).parentId);
			logger.info(data.get(getId().get('1')).message, data.get(getId().get('1')).parentId, data.get(getId().get('1')).listMsg);
			logger.info(data.get(getId().get('2')).message, data.get(getId().get('2')).parentId, data.get(getId().get('2')).setMsg);
			logger.info(data.get(getId().get('3')).message, data.get(getId().get('3')).parentId, data.get(getId().get('3')).mapMsg);
		}

		if (level == BTN_LogUtils.DEBUG) {
			logger.debug(data.get(getId().get('0')).message, data.get(getId().get('0')).parentId);
			logger.debug(data.get(getId().get('1')).message, data.get(getId().get('1')).parentId, data.get(getId().get('1')).listMsg);
			logger.debug(data.get(getId().get('2')).message, data.get(getId().get('2')).parentId, data.get(getId().get('2')).setMsg);
			logger.debug(data.get(getId().get('3')).message, data.get(getId().get('3')).parentId, data.get(getId().get('3')).mapMsg);
		}

		checkSavedLogs(data, level, className);
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description checkSavedLogs - helper method - loads logs from database and compares to saved log patern
	 * @param Map<Id, LogData> data - map of logs pattern
	 * @param String level - logs level
	 * @param String className - name of the class
	 */
	private static void checkSavedLogs(Map<Id, LogData> data, String level, String className) {
		List<Log__c> logs = [
			SELECT
				Level__c, Message__c, ParentId__c, Error_Code__c
			FROM
				Log__c
			WHERE
				Level__c = :level
		];

		System.assertEquals(7, logs.size());

		for (Log__c log : logs) {
			System.assertEquals(true, log.Message__c.containsIgnoreCase(data.get(log.ParentId__c).message));
			System.assertEquals(true, log.Message__c.containsIgnoreCase(className));

			Boolean messageValid = false;

			if (data.get(log.ParentId__c).listMsg != null) {

				for (String msg : data.get(log.ParentId__c).listMsg) {
					if (log.Message__c.containsIgnoreCase(msg)) {
						messageValid = true;
						break;
					}
				}

				System.assertEquals(true,messageValid);
			}

			if (data.get(log.ParentId__c).setMsg != null) {

				for (String msg : data.get(log.ParentId__c).setMsg) {
					if (log.Message__c.containsIgnoreCase(msg)) {
						messageValid = true;
						break;
					}
				}

				System.assertEquals(true,messageValid);
			}

			if (data.get(log.ParentId__c).mapMsg != null) {

				for (String msg : data.get(log.ParentId__c).mapMsg.keySet()) {
					if (log.Message__c.containsIgnoreCase(msg)) {
						messageValid = true;
						break;
					}
				}

				System.assertEquals(true,messageValid);
			}

		}
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description LogData - helper class for prepare log data patern
	 */
	private class LogData {
		public String message;
		public Id parentId;
		public List<String> listMsg;
		public Set<String> setMsg;
		public Map<String, String> mapMsg;

		public LogData(String msg, Id parent) {
			message = msg;
			parentId = parent;
			listMsg = null;
			setMsg = null;
			mapMsg = null;
		}

		public LogData(String msg, Id parent, List<String> errors) {
			message = msg;
			parentId = parent;
			listMsg = errors;
			setMsg = null;
			mapMsg = null;
		}

		public LogData(String msg, Id parent, Set<String> errors) {
			message = msg;
			parentId = parent;
			listMsg = null;
			setMsg = errors;
			mapMsg = null;
		}

		public LogData(String msg, Id parent, Map<String, String> errors) {
			message = msg;
			parentId = parent;
			listMsg = null;
			setMsg = null;
			mapMsg = errors;
		}
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description createLogTestData - helper method - generates log data
	 * @return Map<Id, LogData> data - map of logs data
	 */
	private static Map<Id, LogData> createLogTestData() {
		Map<Id, LogData> data = new Map<Id, LogData>();
		data.put(getId().get('0'), new LogData('message0', getId().get('0')));
		data.put(getId().get('1'), new LogData('message1', getId().get('1'), new List<String>{'err1_1', 'err1_2'}));
		data.put(getId().get('2'), new LogData('message2', getId().get('2'), new Set<String>{'err2_1', 'err2_2'}));
		data.put(getId().get('3'), new LogData('message3', getId().get('3'), new Map<String, String>{'err3_1' => 'err', 'err3_2' => 'err'}));

		return data;
	}

	/**
	 * @date 20/01/2016
	 * @author Arkadiusz Jezierski
	 * @description getId - helper method - returns map of sample Ids
	 * @return Map<Id, LogData> data - map of ids
	 */
	private static Map<String, Id> getId() {
		Map<String, Id> tstId = new Map<String, Id>();
		tstId.put('0', '00516000005c5IIAAY');
		tstId.put('1', '005G0000001qwoRIAQ');
		tstId.put('2', '00516000006muNlAAI');
		tstId.put('3', '005G0000001rWIIIA2');

		return tstId;
	}
}