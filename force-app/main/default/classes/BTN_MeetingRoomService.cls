public with sharing class BTN_MeetingRoomService {

	public BTN_MeetingRoomService() {

	}

	public static BTN_Meeting_Room__c fetchRecordById(Id recordId) {
		BTN_Meeting_Room__c result = null;

		List<BTN_Meeting_Room__c> resultList = [
			select Id, Name, Active__c, Priority__c, Location__c
			from BTN_Meeting_Room__c
			where Id = :recordId
			limit 1
		];

		if (resultList.isEmpty() == false) {
			result = resultList.get(0);
		}

		return result;
	}

	public static List<BTN_Meeting_Room__c> fetchRecordsByLocation(String location) {
		List<BTN_Meeting_Room__c> resultList = [
			select Id, Name, Active__c, Priority__c, Location__c
			from BTN_Meeting_Room__c
			where Location__c = :location
			order by Priority__c asc
		];

		return resultList;
	}

	public static String getFirstAvailableRoomCalendarIdForLocation(String chosenRoom, String location, Datetime eventStart, Datetime eventEnd) {
		Map<String, String> params = new Map<String, String>();
		if (eventStart != null) {
			params.put('timeMin', eventStart.format('yyyy-MM-dd\'T\'HH:mm:ssXXX'));
		}
		if (eventEnd != null) {
			params.put('timeMax', eventEnd.format('yyyy-MM-dd\'T\'HH:mm:ssXXX'));
		}

		String calendarId = null;

		List<BTN_Meeting_Room__c> locationRooms = BTN_MeetingRoomService.fetchRecordsByLocation(location); // priority order

		if(String.isNotBlank(chosenRoom)){
			locationRooms = reorderRoomsByChosenOne(chosenRoom, locationRooms);
		}

		for (BTN_Meeting_Room__c room : locationRooms) {
			if (calendarId != null) {
				break;
			}
			List<BTN_CalendarUtils.CalendarDTO> calendars = BTN_CalendarUtils.getMeetingRoomCalendars(BTN_Utils.getCurrentUser(), room.Name);
			for (BTN_CalendarUtils.CalendarDTO cal : calendars) {
				List<BTN_CalendarUtils.CalendarEventDTO> events = BTN_CalendarUtils.getEventsForCalendar(BTN_Utils.getCurrentUser(), cal.id, params);
				if (events == null || (events != null && events.isEmpty())) {
					calendarId = cal.id;
					break;
				}
			}
		}

		return calendarId;
	}

	private static List<BTN_Meeting_Room__c> reorderRoomsByChosenOne(String chosenRoom, List<BTN_Meeting_Room__c> rooms){
		List<BTN_Meeting_Room__c> returnList = new List<BTN_Meeting_Room__c>();

		for(integer i=0; i<rooms.size() ; i++){
			if(rooms[i].Name == chosenRoom){
				returnList.add(rooms[i]);
				rooms.remove(i);
			}
		}
		returnList.addAll(rooms);
		return returnList;
	}
}