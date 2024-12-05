/**
 * @description Unit tests for JobOfferController class
 */
@isTest
private class JobOfferControllerTest {

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
        JobOfferInfo initialData = JobOfferController.getInitialData(jobApplication.Id);
        Test.stopTest();

        Organization currentOrganization = [SELECT Id, Name FROM Organization LIMIT 1];
        
        System.assertEquals(jobApplication.Id, initialData.jobApplicationId, 'initialData.jobApplicationId contains incorrect data');
        System.assertEquals(candidate.Id, initialData.candidateId, 'initialData.candidateId contains incorrect data');
        System.assertEquals(jobPosition.Name, initialData.jobTitle, 'initialData.jobTitle contains incorrect data');
        System.assertEquals(currentOrganization.Name, initialData.companyName, 'initialData.companyName contains incorrect data');
        System.assertEquals(Date.today().addDays(1), initialData.startDate, 'initialData.startDate contains incorrect data');
        System.assertEquals('', initialData.location, 'initialData.location contains incorrect data');
        System.assertEquals(0, initialData.salaryAmount, 'initialData.salaryAmount contains incorrect data');
        System.assertEquals('', initialData.bonusDetails, 'initialData.bonusDetails contains incorrect data');
        System.assertEquals(null, initialData.probationPeriod, 'initialData.probationPeriod contains incorrect data');
        System.assertEquals(UserInfo.getUserEmail(), initialData.hiringManagerEmail, 'initialData.hrEmail contains incorrect data');
        System.assertEquals(UserInfo.getName(), initialData.hiringManager, 'initialData.hiringManager contains incorrect data');
        System.assertEquals(candidate.Email, initialData.candidateEmail, 'initialData.candidateEmail contains incorrect data');
    }

    /**
     * @description Test method to test the generateOffer() method.
     *              It test that the offer is generated successfully and saved, but the email is not sent.
     */
    @IsTest
    static void testGenerateOffer1() {
        // Create a candidate record
        Contact candidate = TestDataFactory.createContacts(1)[0];
        insert candidate;

        // Create a job position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a job application record
        Job_Application__c jobApplication = TestDataFactory.createJobApplication(jobPosition.Id, candidate.Id);
        insert jobApplication;

        // Get initial data for the job offer
        JobOfferInfo initialData = JobOfferController.getInitialData(jobApplication.Id);

        Test.startTest();
        JobOfferController.generateOffer(initialData, false);

        System.assertEquals(0, Limits.getEmailInvocations(), 'The email should not be sent.');
        Test.stopTest();

        String documentTitle = 'Job offer for ' + initialData.candidateName;

        List<ContentVersion> offerContentVersions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title = :documentTitle
        ];

        List<ContentDocumentLink> offerContDocLinks = [
            SELECT Id, ContentDocumentId, Visibility, ShareType
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :initialData.jobApplicationId
        ];

        System.assertEquals(1, offerContentVersions.size(), 'The number of ContentVersion records with the title "' + documentTitle + '" does not equal to 1.');
        System.assertEquals(1, offerContDocLinks.size(), 'There should be only one ContentDocumentLink record.');
    }

    /**
     * @description Test method to test the generateOffer() method.
     *              It test that the offer is generated successfully, saved and the email is sent.
     */
    @IsTest
    static void testGenerateOffer2() {
        // Create a candidate record
        Contact candidate = TestDataFactory.createContacts(1)[0];
        insert candidate;

        // Create a job position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a job application record
        Job_Application__c jobApplication = TestDataFactory.createJobApplication(jobPosition.Id, candidate.Id);
        insert jobApplication;

        // Get initial data for the job offer
        JobOfferInfo initialData = JobOfferController.getInitialData(jobApplication.Id);

        Test.startTest();
        JobOfferController.generateOffer(initialData, true);

        System.assertEquals(1, Limits.getEmailInvocations(), 'The email should be sent.');
        Test.stopTest();

        String documentTitle = 'Job offer for ' + initialData.candidateName;

        List<ContentVersion> offerContentVersions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title = :documentTitle
        ];

        List<ContentDocumentLink> offerContDocLinks = [
            SELECT Id, ContentDocumentId, Visibility, ShareType
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :initialData.jobApplicationId
        ];

        System.assertEquals(
            1, 
            offerContentVersions.size(), 
            'The number of ContentVersion records with the title "' + documentTitle + '" does not equal to 1.'
        );

        System.assertEquals(1, offerContDocLinks.size(), 'There should be only one ContentDocumentLink record.');
    }

    /**
     * @description Test method to test the getRenderedEmail() method.
     */
    @isTest
    static void testGetRenderedEmail() {
        // Create a candidate record
        Contact candidate = TestDataFactory.createContacts(1)[0];
        insert candidate;

        // Create a job position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a job application record
        Job_Application__c jobApplication = TestDataFactory.createJobApplication(jobPosition.Id, candidate.Id);
        insert jobApplication;

        // Get initial data for the job offer
        JobOfferInfo initialData = JobOfferController.getInitialData(jobApplication.Id);

        Test.startTest();
        String renderedEmail = JobOfferController.getRenderedEmail(initialData);
        Test.stopTest();

        System.assert(renderedEmail.contains(initialData.candidateName), 'The rendered email should contain the candidate name.');
    }
}