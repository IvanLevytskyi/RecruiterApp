/**
 * @description GoogleCalendarService class is used to manage the Google Calendar API
 */
public with sharing class GoogleCalendarService {
    // relative URL to access the Google Calendar API
    private static final String CALENDAR_EVENT_ENDPOINT = '/calendars/primary/events';

    /**
     * @description Get the initial data to create a Google Calendar Event
     * 
     * @param jobApplicationId Id of the Job_Application__c record
     * @return GoogleMeetInfo object containing the information for creation of the Google Calendar Event
     */
    @AuraEnabled(cacheable=true)
    public static GoogleMeetInfo getInitialData(Id jobApplicationId){
        // Get job application by id
        Job_Application__c jobApp = [
            SELECT Id, Candidate__c, Candidate__r.Email, Candidate__r.Name
            FROM Job_Application__c
            WHERE Id = :jobApplicationId
        ];

        // Populate initialData with default values
        GoogleMeetInfo initialData = new GoogleMeetInfo();
        initialData.jobApplicationId = jobApplicationId; // Job_Application__c Id
        initialData.candidateId = jobApp.Candidate__c; // Contact Id of the candidate record
        initialData.startDatetime = Datetime.now().addHours(1); // Start time of the meeting
        initialData.endDatetime = Datetime.now().addHours(2); // End time of the meeting
        initialData.title = ''; // Meeting title
        initialData.description = ''; // Meeting description

        // Add meeting attendees
        initialData.participants = new List<GoogleMeetInfo.Participant>();

        // Add current user as the first participant
        GoogleMeetInfo.Participant tempParticipant = new GoogleMeetInfo.Participant();
        tempParticipant.email = UserInfo.getUserEmail();
        tempParticipant.displayName = UserInfo.getName();
        initialData.participants.add(tempParticipant);

        // Add the candidate as the second participant
        tempParticipant = new GoogleMeetInfo.Participant();
        tempParticipant.email = jobApp.Candidate__r.Email;
        tempParticipant.displayName = jobApp.Candidate__r.Name;
        initialData.participants.add(tempParticipant);

        return initialData;
    }

    /**
     * @description Create a Google Calendar Event
     * 
     * @param meetInfo GoogleMeetInfo object containing the information for creation of the Google Calendar Event
     */
    @AuraEnabled
    public static void createGoogleMeetEvent(GoogleMeetInfo meetInfo){
        // Create a http request with prepopulated endpoint, headers and generated request body
        HttpRequest request = createHttpRequest(meetInfo, createRequestBody(meetInfo));

        Http http = new Http();
        HttpResponse response = http.send(request);

        // Response processing
        if (response.getStatusCode() == 200) {
            // Parse the response body and get the meeting URL
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String meetingUrl = (String) responseBody.get('hangoutLink');

            // Create an event record in Salesforce populated with the meeting information
            insert createEvent(meetInfo, meetingUrl);
        } else {
            throw new AuraHandledException(
                'An error occurred when creating an event in Google Calendar. Error message: ' + response.getBody()
            );
        }
    }

    /**
     * @description Get the time zone offset from GMT for a specific time zone
     * 
     * @param timeZoneId Time zone identifier
     * 
     * @return Time zone offset from GMT in string format '-hh:mm', for example: '+02:00'
     */
    private static String getTimeZoneOffset(String timeZoneId) {
        // Get a time zone object using its identifier
        TimeZone tz = TimeZone.getTimeZone(timeZoneId);

        // Getting the offset in milliseconds
        Long offsetMillis = tz.getOffset(Datetime.now());

        // Convert milliseconds to hours and minutes
        Integer offsetHours = (Integer) (offsetMillis / (1000 * 60 * 60));
        Integer offsetMinutes = (Integer) Math.mod((offsetMillis / (1000 * 60)), 60);

        // Format the result as '-hh:mm'

        String formattedOffset = (offsetHours < 0 ? '-' : '+') + getFormattedInteger(Math.abs(offsetHours)) + ':' + getFormattedInteger(Math.abs(offsetMinutes));

        return formattedOffset;
    }

    /**
     * @description Format an integer to a string with leading zeros
     * 
     * @param intValue Integer value to be formatted
     * 
     * @return Formatted string in format '00', for example: '02'
     */
    private static String getFormattedInteger(Integer intValue) {
        if (intValue < 10) {
            return '0' + String.valueOf(intValue);
        }
        return String.valueOf(intValue);
    }

    /**
     * @description Get the formatted datetime in string format 'yyyy-MM-dd\'T\'HH:mm:ss' + timezone offset
     * 
     * @param dt Datetime value to be formatted
     * 
     * @return Formatted string in format 'yyyy-MM-dd\'T\'HH:mm:ss' + timezone offset
     */
    private static String getFormattedDatetime(Datetime dt) {
        return dt.format('yyyy-MM-dd\'T\'HH:mm:ss') + getTimeZoneOffset(UserInfo.getTimeZone().getID());
    }

    /**
     * @description Create an event record in Salesforce populated with the meeting information
     * 
     * @param meetInfo GoogleMeetInfo object containing the information for creation of the Google Calendar Event
     * 
     * @return Salesforce Event record
     */
    private static Event createEvent(GoogleMeetInfo meetInfo, String eventLink) {
        Event newEvent = new Event();
        newEvent.StartDateTime = meetInfo.startDatetime;
        newEvent.EndDateTime = meetInfo.endDatetime;
        newEvent.Subject = meetInfo.title;
        newEvent.Description = meetInfo.description;
        newEvent.OwnerId = UserInfo.getUserId(); // Assigned To
        newEvent.WhatId = meetInfo.jobApplicationId; // Related To
        newEvent.WhoId = meetInfo.candidateId; // Related contact record
        newEvent.Event_Link__c = eventLink; // Google Meet conference link

        return newEvent;
    }

    /**
     * @description Create an HttpRequest object for creating a Google Calendar event
     * 
     * @param meetInfo GoogleMeetInfo object containing the information for creation of the Google Calendar Event
     * 
     * @return HttpRequest object for creating a Google Calendar event
     */
    private static HttpRequest createHttpRequest(GoogleMeetInfo meetInfo, Map<String, Object> requestBody) {
        HttpRequest req = new HttpRequest();

        // List of URL parameters to be appended to the endpoint
        // 'sendUpdates=all' - Notifications are sent to all guests
        // 'conferenceDataVersion=1' - Indicates that Google need to create a Google Meet conference
        List<String> urlParameters = new List<String> {
            'sendUpdates=all',
            'conferenceDataVersion=1'
        };

        req.setEndpoint('callout:GoogleNamedCredential' + CALENDAR_EVENT_ENDPOINT + '?' + String.join(urlParameters, '&'));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));

        return req;
    }

    /**
     * @description Create a request body for creating a Google Calendar event
     * 
     * @param meetInfo GoogleMeetInfo object containing the information for creation of the Google Calendar Event
     * 
     * @return Request body for creating a Google Calendar event
     */
    private static Map<String, Object> createRequestBody(GoogleMeetInfo meetInfo){
        Map<String, Object> requestBody = new Map<String, Object>();

        // Setting the title and description of the event
        requestBody.put('summary', meetInfo.title);
        if (String.isNotBlank(meetInfo.description)) {
            requestBody.put('description', meetInfo.description);
        }

        // Setting the time (start and end) of the event
        Map<String, Object> startTime = new Map<String, Object>();
        startTime.put('dateTime', getFormattedDatetime(meetInfo.startDatetime));

        Map<String, Object> endTime = new Map<String, Object>();
        endTime.put('dateTime', getFormattedDatetime(meetInfo.endDatetime));

        requestBody.put('start', startTime);
        requestBody.put('end', endTime);

        // Adding participants
        if (!meetInfo.participants.isEmpty()) {
            List<Object> attendees = new List<Object>();

            for (GoogleMeetInfo.Participant participant : meetInfo.participants) {
                Map<String, Object> newParticipant = new Map<String, Object>();
                newParticipant.put('email', participant.email);
                newParticipant.put('displayName', participant.displayName);
                attendees.add(newParticipant);
            }

            requestBody.put('attendees', attendees);
        }
        
        // Creating Google Meet event
        Map<String, Object> conferenceData = new Map<String, Object>();
        Map<String, Object> createRequest = new Map<String, Object>();
        createRequest.put('requestId', UUID.randomUUID().toString());
        createRequest.put('conferenceSolutionKey', new Map<String, Object>{'type' => 'hangoutsMeet'});
        conferenceData.put('createRequest', createRequest);
        requestBody.put('conferenceData', conferenceData);

        return requestBody;
    }
}