/**
 * @description BTN_CalendarUtils provides Utility methods for Google Calendar API v3 sync.
*/
public class BTN_CalendarUtils {

    public static List<CalendarDTO> getCalendarsForUser(User calendarUser) {
        String json = BTN_GoogleCalendarHandler.getCalendarsForUser(calendarUser);
        CalendarListDTO dto = parseCalendarList(json);
        return dto.items;
    }

    public static List<CalendarEventDTO> getEventsForCalendar(User calendarUser, String calendarId) {
        String json = BTN_GoogleCalendarHandler.getEvents(calendarUser, calendarId);
        CalendarEventListDTO dto = parseCalendarEventList(json);
        return dto.items;
    }

    public static List<CalendarEventDTO> getEventsForCalendar(User calendarUser, String calendarId, Map<String, String> params) {
        String json = BTN_GoogleCalendarHandler.getEvents(calendarUser, calendarId, params);
        CalendarEventListDTO dto = parseCalendarEventList(json);
        return dto.items;
    }

    public static List<CalendarDTO> getMeetingRoomCalendars(User calendarUser, String roomName) {
        List<CalendarDTO> resultList = new List<CalendarDTO>();

        String json = BTN_GoogleCalendarHandler.getCalendarsForUser(calendarUser);
        CalendarListDTO dto = parseCalendarList(json);
        if (dto != null && dto.items != null) {
            for (CalendarDTO cal : dto.items) {
                if (cal.summary.contains(roomName)) {
                    resultList.add(cal);
                }
            }
        }

        return resultList;
    }

    // parsers

    public static CalendarListDTO parseCalendarList(String jsonString) {
        return (CalendarListDTO) JSON.deserialize(fixReservedKeywordsInJson(jsonString), CalendarListDTO.class);
    }

    public static CalendarDTO parseCalendar(String jsonString) {
        return (CalendarDTO) JSON.deserialize(fixReservedKeywordsInJson(jsonString), CalendarDTO.class);
    }

    public static CalendarEventListDTO parseCalendarEventList(String jsonString) {
        return (CalendarEventListDTO) JSON.deserialize(fixReservedKeywordsInJson(jsonString), CalendarEventListDTO.class);
    }

    public static CalendarEventDTO parseCalendarEvent(String jsonString) {
        return (CalendarEventDTO) JSON.deserialize(fixReservedKeywordsInJson(jsonString), CalendarEventDTO.class);
    }

    public static String fixReservedKeywordsInJson(String jsonString) {
        return jsonString.replace('"start"', '"startDate"').replace('"end"', '"endDate"').replace('"date"', '"dateValue"').replace('"dateTime"', '"dateTimeValue"');
    }

    // DTO definitions

    public class CalendarListDTO {
        public List<CalendarDTO> items;
    }

    public class CalendarDTO {
        public String id;
        public String summary;
        public String description;
        public String location;
        public String timeZone;
        public Boolean hidden;
        public Boolean selected;
        public Boolean primary;
        public Boolean deleted;
    }

    public class CalendarEventListDTO {
        public String summary;
        public String description;
        public String accessRole;
        public List<CalendarEventDTO> items;
    }

    public class CalendarEventDTO {
        public String id;
        public String summary;
        public DateTime created;
        public DateTime updated;
        public String location;
        public String status;
        public CalendarEventDateDTO startDate;
        public CalendarEventDateDTO endDate;
        public List<CalendarEventAttendeeDTO> attendees;
    }

    public class CalendarEventAttendeeDTO {
        public String id;
        public String email;
        public String displayName;
        public Boolean optional;
    }

    public class CalendarEventDateDTO {
        public Date dateValue;
        public DateTime dateTimeValue;
        public String timeZone;
    }

}