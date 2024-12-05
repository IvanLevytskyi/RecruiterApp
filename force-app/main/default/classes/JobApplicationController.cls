/**
 * @description JobApplicationController is controller class for jobApplication LWC component
 */
public with sharing class JobApplicationController {
    // List of fields to check on User object
    private static final Set<String> USER_FIELDS_TO_CHECK = new Set<String>{
        'FirstName',
        'LastName',
        'Email',
        'Phone',
        'City',
        'Country'
    };

    
    /**
     * @description Method is used to validate user's application
     * 
     * @param Id jobPositionId Id of job position record
     * @return Map <String, Object> Map with validation result and messages in format:
     * {
     *   'isValid': true/false,
     *   'messages': [
     *       'message 1',
     *       'message 2'
     *   ]
     * }
     */
    @AuraEnabled(cacheable=true)
    public static Map <String, Object> validateBeforeApplication(Id jobPositionId){
        // Initialize response map
        Map <String, Object> response = new Map<String, Object>{
            'isValid' => true,
            'messages' => new List<String>()
        };

        // Get current user information
        User currentUser = [
            SELECT 
                Id, FirstName, LastName, Email, Phone, City, Country,
                ContactId, Contact.CV_DocumentId__c, Contact.Number_of_Skills__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ];

        // Check if the user is a community user
        if (String.isBlank(currentUser.ContactId)) {
            response.put('isValid', false);
            ((List<String>) response.get('messages')).add('This functionality is only for customer portal users!');
            return response;
        }

        // Check if user has already applied for this job
        Integer numberOfApplicationsForThisJob = [
            SELECT COUNT() 
            FROM Job_Application__c 
            WHERE Candidate__c = :currentUser.ContactId AND Job_Position__c = :jobPositionId
        ];

        if (numberOfApplicationsForThisJob >= 1) {
            response.put('isValid', false);
            ((List<String>) response.get('messages')).add('You have already applied for this job!');
            return response;
        }
        
        // Check if user has all the desired fields populated
        List<String> listOfMissingUserFields = new List<String>();
        for (String field: USER_FIELDS_TO_CHECK) {
            if (String.isBlank((String) currentUser.get(field))) {
                listOfMissingUserFields.add(field);
            }
        }

        if (!listOfMissingUserFields.isEmpty()) {
            response.put('isValid', false);
            ((List<String>) response.get('messages')).add('You forgot to populate the following information: ' + String.join(listOfMissingUserFields, ', '));
        }

        // Check if user has attached CV
        if (String.isBlank(currentUser.Contact.CV_DocumentId__c)) {
            response.put('isValid', false);
            ((List<String>) response.get('messages')).add('You have not attached your CV document');
        }

        // Check if user has selected at least one skill
        if (currentUser.Contact.Number_of_Skills__c == 0) {
            response.put('isValid', false);
            ((List<String>) response.get('messages')).add('You have not selected any skills');
        }

        return response;
    }

    /**
     * @description Method is used to apply for a job
     * 
     * @param Id jobPositionId Id of job position record
     * @param Id userContactId Id of contact record
     * @return Id Id of newly created job application record
     */
    @AuraEnabled
    public static Id applyForAJob(Id jobPositionId, Id userContactId) {
        // Create a savepoint in case a DML operation fails
        Savepoint sp = Database.setSavepoint();

        try {
            // Create a job application record
            Job_Application__c application = new Job_Application__c(
                Candidate__c = userContactId, 
                Job_Position__c = jobPositionId
            );
            insert application;
            
            // Create a follow-up task for application owner
            Task followUpTask = new Task(
                OwnerId = getJobOnwerId(jobPositionId),
                ActivityDate = getActivityDate(),
                Subject = 'Please review the provided job application',
                Status = 'Not Started',
                WhatId = application.Id,
                WhoId = userContactId,
                Priority = 'High');
            insert followUpTask;

            return application.Id;
        } catch (Exception e) {
            // Rollback all the changes in case of DML error
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method is used to get the date for the follow-up task
     * 
     * @return Date Date for follow-up task, returns next business day
     */
    private static Date getActivityDate() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        return BusinessHours.nextStartDate(bh.id,  Datetime.now()).date();
    }

    /**
     * @description Method is used to get the id of the user that owns the job position
     * 
     * @param Id jobId Id of job position record
     * @return Id Id of the user that owns the job position
     */
    private static Id getJobOnwerId(Id jobId) {
        return [SELECT Id, OwnerId FROM Job_Position__c WHERE Id = :jobId].OwnerId;
    }
}