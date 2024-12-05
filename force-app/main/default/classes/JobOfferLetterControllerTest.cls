/**
 * @description Unit tests for JobOfferLetterController class
 */
@isTest
private class JobOfferLetterControllerTest {
    /**
     * @description Test method to test the JobOfferLetterController() constructor
     */
    @isTest
    static void testJobOfferLetter() {
        // URL with parameters for JobOfferLetter page initialization 
        String pageUrl = '/apex/JobOfferLetter?companyName=SuperCompany&jobTitle=Salesforce+Trainee+Developer'
            + '&jobApplicationId=a02WU0000044J09YAE&hiringManager=Ivan+Levytskyi&probationPeriod=3'
            + '&candidateEmail=test1%40nomail.com&candidateName=John+Smith&salaryAmount=1000'
            + '&location=New+York&bonusDetails=13th+Salary&candidateId=003WU000006PAn7YAG'
            + '&hiringManagerEmail=test2%40nomail.com&startDate=2024-12-01';

        // Create page reference initialized with URL parameters
        PageReference jobOfferPageRef = new PageReference(pageUrl);

        Test.startTest();
        Test.setCurrentPage(jobOfferPageRef);
        JobOfferLetterController controller = new JobOfferLetterController();
        Test.stopTest();

        System.assertEquals('SuperCompany', controller.companyName, 'Company name should be SuperCompany');
        System.assertEquals('Salesforce Trainee Developer', controller.jobTitle, 'Job title should be Salesforce Trainee Developer');
        System.assertEquals('Ivan Levytskyi', controller.hiringManager, 'Hiring manager should be Ivan Levytskyi');
        System.assertEquals(3, controller.probationPeriod, 'Probation period should be 3 months');
        System.assertEquals('John Smith', controller.candidateName, 'Candidate name should be John Smith');
        System.assertEquals(1000, controller.salaryAmount, 'Salary amount should be 1000');
        System.assertEquals('New York', controller.location, 'Location should be New York');
        System.assertEquals('13th Salary', controller.bonusDetails, 'Bonus details should be 13th Salary');
        System.assertEquals('test2@nomail.com', controller.hiringManagerEmail, 'Hiring manager email should be test2@nomail.com');
        System.AssertEquals(Date.newInstance(2024, 12, 1), controller.startDate, 'Start date should be 2024-12-01');
    }
}