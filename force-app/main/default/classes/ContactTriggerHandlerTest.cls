/**
 * @description Unit tests for ContactTriggerHandler class
 */
@isTest
private class ContactTriggerHandlerTest {

    /**
     * @description Test method to test the afterUpdate() method.
     *              The method should delete old ContentDocuments on after update Contact trigger.
     */
    @isTest
    static void testAfterUpdate() {
        // Create first ContentVersion
        ContentVersion firstContentVersion = TestDataFactory.createContentVersion();
        insert firstContentVersion;

        firstContentVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :firstContentVersion.Id LIMIT 1
        ];

        // Create a new Contact
        Contact con = TestDataFactory.createContacts(1)[0];
        con.CV_DocumentId__c = firstContentVersion.ContentDocumentId;
        insert con;

        // Create second ContentVersion
        ContentVersion secondContentVersion = TestDataFactory.createContentVersion();
        insert secondContentVersion;

        secondContentVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :secondContentVersion.Id LIMIT 1
        ];

        // Update the Contact
        con.CV_DocumentId__c = secondContentVersion.ContentDocumentId;
        Test.startTest();
        update con;
        Test.stopTest();

        System.assertEquals(
            0, 
            [SELECT COUNT() FROM ContentDocument WHERE Id = :firstContentVersion.ContentDocumentId],
            'The old ContentDocument should be deleted.'
        );
    }
}