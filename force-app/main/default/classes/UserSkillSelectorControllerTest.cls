/**
 * @description Unit tests for UserSkillSelectorController class
 */
@isTest
private class UserSkillSelectorControllerTest {

    /**
     * @description Test method to test the getCandidateSkills() method.
     *              The method should return the candidate skills for the specified candidate.
     */
    @isTest
    static void testGetCandidateSkills() {
        // Create a candidate record
        Contact candidate = TestDataFactory.createContacts(1)[0];
        insert candidate;

        // Create candidate skills
        List<Candidate_Skill__c> candidateSkills = TestDataFactory.createCandidateSkills(3, candidate.Id);
        insert candidateSkills;

        Test.startTest();
        List<OptionItem> contactSkills = UserSkillSelectorController.getCandidateSkills(candidate.Id);
        Test.stopTest();

        System.Assert.areEqual(3, contactSkills.size(), 'There should be 3 candidate skills');

        for (OptionItem optItem : contactSkills) {
            System.assert(optItem.label.startsWith('Skill'), 'The label should start with "Skill"');
        }
    }

    /**
     * @description Test method to test the getSkills() method.
     *              The method should return all skills.
     */
    @isTest
    static void testGetSkills() {
        // Create skills
        List<Skill__c> skills = TestDataFactory.createSkills(10);
        insert skills;

        Test.startTest();
        List<OptionItem> skillsList = UserSkillSelectorController.getSkills();
        Test.stopTest();

        System.AssertEquals(10, skillsList.size(), 'There should be 10 skills');

        for (OptionItem skill : skillsList) {
            System.assert(skill.label.startsWith('Skill'), 'The label should start with "Skill"');
            System.assert(skill.value instanceof Id, 'The value should be an Id');
        }
    }
}