/**
 * @description DocumentService class is used to manage the ContentDocument object.
 */
public with sharing class DocumentService {
    /**
     * @description Deletes a document by its Id.
     * 
     * @param Id documentId - Id of the document to delete.
     */
    public static void deleteDocumentById(Id documentId) {
        delete new ContentDocument(Id = documentId);
    }

    /**
     * @description Deletes a list of documents by their Ids.
     * 
     * @param Set<Id> documentIds - Set of Ids of the documents to delete.
     */
    public static void deleteDocumentsByIds(Set<Id> documentIds) {
        List<ContentDocument> documentsToDelete = new List<ContentDocument>();
        for (Id documentId : documentIds) {
            documentsToDelete.add(new ContentDocument(Id = documentId));
        }
        delete documentsToDelete;
    }
}