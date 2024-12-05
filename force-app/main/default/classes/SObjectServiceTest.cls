/**
 * @description Unit tests for SObjectService class
 */
@IsTest
private class SObjectServiceTest {
    @IsTest
    static void testGetSObjectNameById() {
        Test.startTest();
        String sObjName = SObjectService.getSObjectNameById(UserInfo.getUserId());
        Test.stopTest();
        System.assertEquals('User', sObjName, 'The SObject name should be User');
    }
}
