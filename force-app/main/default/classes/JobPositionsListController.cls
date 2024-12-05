/**
 * @description JobPositionsListController is controller class for jobPositionsList LWC component
 */
public with sharing class JobPositionsListController {
    // Contstant that stores the Open status name for the Status__c field of the Job_Position__c object
    private static final String OPEN_STATUS = 'Open';

    /**
     * @description Get the list of open job positions
     * 
     * @return List<Job_Position__c> List of Job_Position__c records
     */
    @AuraEnabled (cacheable=true)
    public static List<Job_Position__c> getJobPositions(){
        return [
            SELECT 
                Id, CreatedDate, Days_Open__c, Description__c, Is_remote_allowed__c, 
                Name, Number_of_job_applications__c, Salary_from__c, Salary_to__c 
            FROM Job_Position__c 
            WHERE Status__c = :OPEN_STATUS 
            ORDER BY CreatedDate DESC
        ];
    }
}