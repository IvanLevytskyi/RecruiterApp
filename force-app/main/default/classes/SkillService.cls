/**
 * @description SkillService class is used to manage the Skill__c, Job_Skill__c, Candidate_Skill__c objects
 */
public with sharing class SkillService {
    /**
     * @description Get the list of skills for the selected candidate
     * 
     * @param Id contactId Id of the Contact record
     * @return List<Candidate_Skill__c> List of Candidate_Skill__c records
     */
    public static List<Candidate_Skill__c> getCandidateSkillsByContactId(Id contactId) {
        return [
            SELECT Id, Candidate__c, Skill__c, Skill__r.Name 
            FROM Candidate_Skill__c 
            WHERE Candidate__c = :contactId 
            ORDER BY Skill__r.Name ASC
        ];
    }

    /**
     * @description Get the list of skills for the selected job
     * 
     * @param Id jobId Id of the Job_Position__c record
     * @return List<Job_Skill__c> List of Job_Skill__c records
     */
    public static List<Job_Skill__c> getJobSkillByJobId(Id jobId) {
        return [
            SELECT Id, Job_Position__c, Skill__c, Skill__r.Name 
            FROM Job_Skill__c 
            WHERE Job_Position__c = :jobId 
            ORDER BY Skill__r.Name ASC
        ];
    }

    /**
     * @description Get the list of all skills
     * 
     * @return List<Skill__c> List of Skill__c records
     */
    public static List<Skill__c> getSkills() {
        return [
            SELECT Id, Name 
            FROM Skill__c 
            ORDER BY Name ASC
        ];
    }
}