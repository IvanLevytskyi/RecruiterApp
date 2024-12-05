/**
 * @description Unit tests for DocumentService class
 */
@isTest
private class DocumentServiceTest {

    /**
     * @description Test method to test the deleteDocumentById() method.
     *              The method should delete the ContentDocument record.
     */
    @isTest
    static void testDeleteDocumentById() {
        // Create ContentVersion
        ContentVersion contVersion = TestDataFactory.createContentVersion();
        insert contVersion;

        contVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contVersion.Id LIMIT 1
        ];

        // Test method
        Test.startTest();
        DocumentService.deleteDocumentById(contVersion.ContentDocumentId);
        Test.stopTest();

        System.assertEquals(
            0, 
            [SELECT COUNT() FROM ContentDocument WHERE Id = :contVersion.ContentDocumentId], 
            'The ContentDocument record should be deleted.'
        );
    }

    /**
     * @description Test method to test the deleteDocumentsByIds() method.
     *              The method should delete the ContentDocument records.
     */
    @isTest
    static void testDeleteDocumentsByIds() {
        // Create ContentVersion
        ContentVersion contVersion = TestDataFactory.createContentVersion();
        insert contVersion;

        contVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contVersion.Id LIMIT 1
        ];

        // Test method
        Test.startTest();
        DocumentService.deleteDocumentsByIds(new Set<Id> { contVersion.ContentDocumentId });
        Test.stopTest();

        System.assertEquals(
            0, 
            [SELECT COUNT() FROM ContentDocument WHERE Id = :contVersion.ContentDocumentId], 
            'The ContentDocument record should be deleted.'
        );
    }
}