/**
 * @description SkillMatchesController is controller class for skillMatches LWC component
 */
public with sharing class SkillMatchesController {
    /**
     * @description Get the list of matching skills for the selected job
     * 
     * @param jobId Id of the Job_Position__c record
     * @return List<OptionItem> List of OptionItem records
     */
    @AuraEnabled(cacheable=true)
    public static List<OptionItem> getJobSkills(Id jobId){
        List<OptionItem> result = new List<OptionItem>();
        for (Job_Skill__c jobSkill : SkillService.getJobSkillByJobId(jobId)) {
            result.add(
                new OptionItem(jobSkill.Skill__r.Name, jobSkill.Skill__c)
            );
        }
        return result;
    }
}