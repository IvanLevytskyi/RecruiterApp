/**
 * @description Test class for GoogleCalendarService class
 */
@isTest
private class GoogleCalendarServiceTest {

    /**
     * @description Test method to test the getInitialData() method.
     */
    @isTest
    static void testGetInitialData() {
        // Create a candidate record
        Contact candidate = TestDataFactory.createContacts(1)[0];
        insert candidate;

        // Create a job position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a job application record
        Job_Application__c jobApplication = TestDataFactory.createJobApplication(jobPosition.Id, candidate.Id);
        insert jobApplication;

        Test.startTest();
        GoogleMeetInfo meetInfo = GoogleCalendarService.getInitialData(jobApplication.Id);
        Test.stopTest();

        System.assertEquals(jobApplication.Id, meetInfo.jobApplicationId, 'Job Application Id should match');
        System.assertEquals(jobApplication.Candidate__c, meetInfo.candidateId, 'Candidate Id should match');
        System.assertEquals('', meetInfo.title, 'Job Title should be empty');
        System.assertEquals('', meetInfo.description, 'Description should be empty');
        System.assertEquals(Datetime.now().addHours(1), meetInfo.startDatetime, 'Start Date should match');
        System.assertEquals(Datetime.now().addHours(2), meetInfo.endDatetime, 'End Date should match');
        System.assertEquals(2, meetInfo.participants.size(), 'There should be two participants');
    }

    /**
     * @description Test method to test the createGoogleMeetEvent() method.
     *              The method should create the event
     */
    @isTest
    static void testCreateGoogleMeetEvent() {
        // Create a candidate record
        Contact candidate = TestDataFactory.createContacts(1)[0];
        insert candidate;

        // Create a job position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a job application record
        Job_Application__c jobApplication = TestDataFactory.createJobApplication(jobPosition.Id, candidate.Id);
        insert jobApplication;

        // Create GoogleMeetInfo object with meeting information
        GoogleMeetInfo meetInfo = new GoogleMeetInfo();
        meetInfo.jobApplicationId = jobApplication.Id;
        meetInfo.candidateId = jobApplication.Candidate__c;
        meetInfo.startDatetime = Datetime.now().addHours(1);
        meetInfo.endDatetime = Datetime.now().addHours(2);
        meetInfo.title = 'Test Title';
        meetInfo.description = 'Test Description';

        // Add meeting attendees
        meetInfo.participants = new List<GoogleMeetInfo.Participant>();

        // Add current user as the first participant
        GoogleMeetInfo.Participant tempParticipant = new GoogleMeetInfo.Participant();
        tempParticipant.email = UserInfo.getUserEmail();
        tempParticipant.displayName = UserInfo.getName();
        meetInfo.participants.add(tempParticipant);

        // Add the candidate as the second participant
        tempParticipant = new GoogleMeetInfo.Participant();
        tempParticipant.email = candidate.Email;
        tempParticipant.displayName = candidate.FirstName + ' ' + candidate.LastName;
        meetInfo.participants.add(tempParticipant);

        // Set up mock response
        HttpCalloutMockClass.statusCode = 200;
        HttpCalloutMockClass.status = 'OK';
        HttpCalloutMockClass.body = '{"kind": "calendar#event", "id": "lvkjfsbgbe283gt98tfi8b8gdk",'
        + ' "status": "confirmed", "summary": "Test Title", "description": "Test Description", "hangoutLink": "https://meet.google.com/cks-vykj-qgs"}';

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockClass());

        Test.startTest();
        GoogleCalendarService.createGoogleMeetEvent(meetInfo);
        Test.stopTest();

        List<Event> events = [
            SELECT Id, Subject, Description, Event_Link__c, OwnerId, WhatId, WhoId, StartDateTime, EndDateTime
            FROM Event
            WHERE WhatId = :meetInfo.jobApplicationId
        ];

        System.assertEquals(1, events.size(), 'There should be one Event record created');
        System.assertEquals(meetInfo.startDatetime, events[0].StartDateTime, 'The start time should match');
        System.assertEquals(meetInfo.endDatetime, events[0].EndDateTime, 'The end time should match');
        System.assertEquals(meetInfo.title, events[0].Subject, 'The title should match');
        System.assertEquals(meetInfo.description, events[0].Description, 'The description should match');
        System.assertEquals(UserInfo.getUserId(), events[0].OwnerId, 'The Assigned To field should match');
        System.assertEquals(meetInfo.candidateId, events[0].WhoId, 'The related contact record should match');
        System.assert(String.isNotBlank(events[0].Event_Link__c), 'The Event Link should not be empty');   
    }
}