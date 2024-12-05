/**
 * @description UserSkillSelectorController is controller class for userSkillSelector LWC component
 */
public with sharing class UserSkillSelectorController {
    /**
     * @description Get the list of skills of the selected candidate
     * 
     * @param contactId Id of the Contact record
     * @return List<OptionItem> List of OptionItem records
     */
    @AuraEnabled(cacheable=true)
    public static List<OptionItem> getCandidateSkills(Id contactId){
        List<OptionItem> result = new List<OptionItem>();
        for (Candidate_Skill__c candidateSkill : SkillService.getCandidateSkillsByContactId(contactId)) {
            Map<String, String> valueMap = new Map<String, String> ();
            valueMap.put('skillId', candidateSkill.Skill__c);
            valueMap.put('candidateSkillId', candidateSkill.Id);
            result.add(
                new OptionItem(candidateSkill.Skill__r.Name, valueMap)
            );
        }
        return result;
    }

    /**
     * @description Get the list of all skills
     * 
     * @return List<OptionItem> List of OptionItem records
     */
    @AuraEnabled(cacheable=true)
    public static List<OptionItem> getSkills() {
        List<OptionItem> result = new List<OptionItem>();
        for (Skill__c skill : SkillService.getSkills()) {
            result.add(
                new OptionItem(skill.Name, skill.Id)
            );
        }
        return result;
    }
}