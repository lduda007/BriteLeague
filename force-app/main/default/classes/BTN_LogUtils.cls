/**
* @author Arkadiusz Jezierski
* @date 20/01/2016
* @description UTL_Log4sfdc Logging class which inserts errors and dubug logs to database.
*/
public with sharing class BTN_LogUtils {
	// LOG LEVELS
	public static final String ERROR  = 'Error';
	public static final String WARN   = 'Warn';
	public static final String INFO   = 'Info';
	public static final String DEBUG  = 'Debug';

	// ERROR CODES
	private static final String CODE_DEFAULT  = '000';

	private String className;

	/**
	* @author Arkadiusz Jezierski
	* @date 20/01/2016
	* @description Default Constructor using class className
	* @param String className
	*/
	public BTN_LogUtils(String className) {
		this.className = className;
	}

	/**
	* @author Arkadiusz Jezierski
	* @date 20/01/2016
	* @description log method to insert the message to db
	* @param String level
	* @param String message
	* @param Id parentId
	*/
	private void log(String level, String message, Id parentId) {
		insert (new List<Log__c>{getLog(level, message, parentId, null)});
	}

	/**
	* @author Arkadiusz Jezierski
	* @date 20/01/2016
	* @description log method to insert the message to db adding multiple error log
	* @param String level
	* @param String message
	* @param Id parentId
	* @param List<String> errors
	*/
	private void log(String level, String message, Id parentId, List<String> errors) {
		List<Log__c> debugLog = new List<Log__c>();

		for (String e: errors) {
			debugLog.add(getLog(level, message, parentId, e));
		}

		insert debugLog;
	}

	private void log(String level, String message, Id parentId, Set<String> errors) {
		log(level, message, parentId, new List<String>(errors));
	}

	private void log(String level, String message, Id parentId, Map<String, String> errors) {
		log(level, message, parentId, errors.keySet());
	}

	/**
	* @author Arkadiusz Jezierski
	* @date 20/01/2016
	* @description getLog method - returns a new HCP_Log__c record based on the parameters
	* @param String level - log level
	* @param String message - log message
	* @param Id parentId - Id of parent record
	* @param String error - error message
	*/
	private Log__c getLog(String level, String message, Id parentId, String errorMessage) {
		message = className + ': ' + message;
		if (errorMessage != null) {
			message += ' | ' + errorMessage;
		}

		return new Log__c(
			Level__c = level,
			Message__c = message,
			ParentId__c = parentId,
			Error_Code__c = CODE_DEFAULT
		);
	}

	/**
	* ERROR
	*/
	public void error(String message, Id parentId) {
		log(ERROR, message, parentId);
	}
	public void error(String message, Id parentId, List<String> errors) {
		log(ERROR, message, parentId, errors);
	}
	public void error(String message, Id parentId, Set<String> errors) {
		log(ERROR, message, parentId, errors);
	}
	public void error(String message, Id parentId, Map<String, String> errors) {
		log(ERROR, message, parentId, errors);
	}


	/**
	* WARNING
	*/
	public void warning(String message, Id parentId) {
		log(WARN, message, parentId);
	}
	public void warning(String message, Id parentId, List<String> errors) {
		log(WARN, message, parentId, errors);
	}
	public void warning(String message, Id parentId, Set<String> errors) {
		log(WARN, message, parentId, errors);
	}
	public void warning(String message, Id parentId, Map<String, String> errors) {
		log(WARN, message, parentId, errors);
	}

	/**
	* INFO
	*/
	public void info(String message, Id parentId) {
		log(INFO, message, parentId);
	}
	public void info(String message, Id parentId, List<String> errors) {
		log(INFO, message, parentId, errors);
	}
	public void info(String message, Id parentId, Set<String> errors) {
		log(INFO, message, parentId, errors);
	}
	public void info(String message, Id parentId, Map<String, String> errors) {
		log(INFO, message, parentId, errors);
	}

	/**
	* DEBUG
	*/
	public void debug(String message, Id parentId) {
		log(DEBUG, message, parentId);
	}
	public void debug(String message, Id parentId, List<String> errors) {
		log(DEBUG, message, parentId, errors);
	}
	public void debug(String message, Id parentId, Set<String> errors) {
		log(DEBUG, message, parentId, errors);
	}
	public void debug(String message, Id parentId, Map<String, String> errors) {
		log(DEBUG, message, parentId, errors);
	}
}