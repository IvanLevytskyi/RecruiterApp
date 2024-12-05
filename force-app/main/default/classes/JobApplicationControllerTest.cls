/**
 * @description Unit tests for JobApplicationController class
 */
@isTest
private class JobApplicationControllerTest {
    /**
     * @description Test method to test the validation of the JobApplicationController.validateBeforeApplication() method.
     *               The validation includes:
     *               - Check that the current user is a community user
     */
    @isTest
    static void testValidateBeforeApplication1() {
        // Create a Job Position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a non-community user
        User nonCommUser = TestDataFactory.createUsers(1)[0];

        // Run code as the non-community user
        Map <String, Object> response;

        System.runAs(nonCommUser) {
            Test.startTest();
            response = JobApplicationController.validateBeforeApplication(jobPosition.Id);
            Test.stopTest();
        }

        System.assertEquals(
            false, 
            (Boolean) response.get('isValid'), 
            'The validation should be unsuccessful.'
        );

        System.assertEquals(
            1,
            ((List<String>) response.get('messages')).size(), 
            'There should be one message returned.'
        );

        System.assertEquals(
            'This functionality is only for customer portal users!',
            ((List<String>) response.get('messages'))[0],
            'The returned message should notify that the user is not a community user and not able to apply for a job.'
        );
    }

    /**
     * @description Test method to test the validation of the JobApplicationController.validateBeforeApplication() method.
     *               The validation includes:
     *               - Check that the current user is a community user
     *               - Check that the user has already applied for this job
     */
    @isTest
    static void testValidateBeforeApplication2() {
        // Create a Job Position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a community user
        User commUser = TestDataFactory.createCommunityUsers(1)[0];

        // Create a job application record
        Job_Application__c jobApplication = TestDataFactory.createJobApplication(jobPosition.Id, commUser.ContactId);
        insert jobApplication;

        // Run code as the community user
        Map <String, Object> response;

        System.runAs(commUser) {
            Test.startTest();
            response = JobApplicationController.validateBeforeApplication(jobPosition.Id);
            Test.stopTest();
        }

        System.assertEquals(
            false, 
            (Boolean) response.get('isValid'), 
            'The validation should be unsuccessful.'
        );

        System.assertEquals(
            1,
            ((List<String>) response.get('messages')).size(), 
            'There should be one message returned.'
        );

        System.assertEquals(
            'You have already applied for this job!',
            ((List<String>) response.get('messages'))[0],
            'The returned message should notify that the user has already applied for a job.'
        );
    }

    /**
     * @description Test method to test the validation of the JobApplicationController.validateBeforeApplication() method.
     *               The validation includes:
     *               - Check that the current user is a community user
     *               - Check that the user has not yet applied for this job
     *               - Check that the user has populated required information
     *               - Check that the user has selected some skills
     *               - Check that the user has attached a CV document
     */
    @IsTest
    static void testValidateBeforeApplication3() {
        // Create a Job Position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a community user
        User commUser = TestDataFactory.createCommunityUsers(1)[0];

        // Run code as the community user
        Map <String, Object> response;

        System.runAs(commUser) {
            Test.startTest();
            response = JobApplicationController.validateBeforeApplication(jobPosition.Id);
            Test.stopTest();
        }

        System.assertEquals(
            false, 
            (Boolean) response.get('isValid'), 
            'The validation should be unsuccessful.'
        );

        System.assertEquals(
            3,
            ((List<String>) response.get('messages')).size(), 
            'There should be one message returned.'
        );

        System.assert(
            ((List<String>) response.get('messages'))[0].contains('You forgot to populate the following information: '), 
            'The returned message should notify that the user has not populated some information.'
        );

        System.assertEquals(
            'You have not attached your CV document', 
            ((List<String>) response.get('messages'))[1], 
            'The returned message should notify that the user has not attached their CV document.'
        );

        System.AssertEquals(
            'You have not selected any skills', 
            ((List<String>) response.get('messages'))[2], 
            'The returned message should notify that the user has not selected any skills.'
        );
    }

    /**
     * @description Test method to test the validation of the JobApplicationController.validateBeforeApplication() method.
     *               The validation includes:
     *               - Check that the current user is a community user
     *               - Check that the user has not yet applied for this job
     *               - Check that the user has populated required information
     *               - Check that the user has selected some skills
     *               - Check that the user has attached a CV document
     */
    @IsTest
    static void testValidateBeforeApplication4() {
        // Create a Job Position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a community user
        User commUser = TestDataFactory.createCommunityUsers(1)[0];
        commUser.Phone = '123456789';
        commUser.City = 'New York';
        commUser.Country = 'USA';

        // Create CV document for the community user
        ContentVersion contVersion = TestDataFactory.createContentVersion();
        insert contVersion;

        Id contentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contVersion.Id 
            LIMIT 1
        ]?.ContentDocumentId;

        ContentDocumentLink contDocLink = TestDataFactory.createContentDocumentLink(contentDocumentId, commUser.ContactId);
        insert contDocLink;

        // Update CV_DocumentId__c field with the ContentDocumentId value
        update new Contact(
            Id = commUser.ContactId,
            CV_DocumentId__c = contentDocumentId
        );

        // Create skills for the candidate
        List<Candidate_Skill__c> skills = TestDataFactory.createCandidateSkills(3, commUser.ContactId);
        insert skills;

        // Run code as the community user
        Map <String, Object> response;

        System.runAs(commUser) {
            Test.startTest();
            response = JobApplicationController.validateBeforeApplication(jobPosition.Id);
            Test.stopTest();
        }

        System.debug(response);

        System.assert(
            (Boolean) response.get('isValid'),
            'The returned response should be valid.'
        );

        System.assertEquals(
            0, 
            ((List<String>) response.get('messages')).size(),
            'There should not be any messages'
        );
    }

    @isTest
    static void testApplyForAJob() {
        // Create a Job Position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create a community user
        User commUser = TestDataFactory.createCommunityUsers(1)[0];

        // Run code as the community user
        Id jobApplicationId;
        System.runAs(commUser) {
            Test.startTest();
            jobApplicationId = JobApplicationController.applyForAJob(jobPosition.Id, commUser.ContactId);
            Test.stopTest();
        }

        // Get the newly created Job Application record
        Job_Application__c jobApplication = [
            SELECT Id, Candidate__c, Job_Position__c 
            FROM Job_Application__c 
            WHERE Id = :jobApplicationId LIMIT 1
        ];

        System.assertEquals(jobPosition.Id, jobApplication.Job_Position__c, 'Job Application record should be associated with the Job Position');
        System.AssertEquals(commUser.ContactId, jobApplication.Candidate__c, 'Job Application record should be associated with the Contact record');
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :jobApplicationId], 'A task record should be created as a follow-up to the Job Application');
    }
}