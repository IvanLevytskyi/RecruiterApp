/**
 * @description Unit tests for JobPositionsListController class
 */
@isTest
private class JobPositionsListControllerTest {

    /**
     * @description Test method to test the getJobPositions() method.
     *              The method should return all open job positions.
     */
    @isTest
    static void testGetJobPositions() {
        // Create 10 job positions
        List<Job_Position__c> jobPositions = TestDataFactory.createJobPositions(10);
        // Set the status of the first to Closed
        jobPositions[0].Status__c = 'Closed';
        insert jobPositions;

        Test.startTest();
        List<Job_Position__c> returnedJobPositions = JobPositionsListController.getJobPositions();
        Test.stopTest();

        System.assertEquals(jobPositions.size() - 1, returnedJobPositions.size(), 'The method should return only open job positions');
    }
}