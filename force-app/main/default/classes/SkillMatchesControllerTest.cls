/**
 * @description Unit tests for SkillMatchesController class
 */
@isTest
private class SkillMatchesControllerTest {

    /**
     * @description Test method to test the getJobSkills() method.
     *              The method should return the Job Skills for the specified Job Position.
     */
    @isTest
    static void testGetJobSkills() {
        // Create a Job Position record
        Job_Position__c jobPosition = TestDataFactory.createJobPositions(1)[0];
        insert jobPosition;

        // Create Job Skills
        insert TestDataFactory.createJobSkills(10, jobPosition.Id);

        Test.startTest();
        List<OptionItem> jobSkills = SkillMatchesController.getJobSkills(jobPosition.Id);
        Test.stopTest();

        System.assertEquals(10, jobSkills.size(), 'There should be 10 Job Skills');

        for (OptionItem optItem : jobSkills) {
            System.assert(optItem.label.startsWith('Skill'), 'The label should start with "Skill"');
        }
    }
}