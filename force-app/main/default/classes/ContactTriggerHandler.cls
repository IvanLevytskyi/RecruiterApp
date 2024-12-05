/**
 * @description Implementation of trigger handler for Contact object. Class extends TriggerHandler class.
 */
public with sharing class ContactTriggerHandler extends TriggerHandler {
    /**
     * @description Overriden afterUpdate method for Contact trigger
     * 
     * @param List<sObject> newList - List of Contact records that were updated.
     * @param Map<Id, sObject> newMap - Map of Contact records that were updated.
     * @param List<sObject> oldList - List of Contact records before they were updated.
     * @param Map<Id, sObject> oldMap - Map of Contact records before they were updated.
     */
    public override void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        deleteOldCVs((List<Contact>) newList, (Map<Id, Contact>) oldMap);
    }

    /**
     * @description This method is responsible for deleting old versions of the contact's CV document.
     * 
     * @param List<Contact> newList - List of Contact records that were updated.
     * @param Map<Id, Contact> oldMap -  Map of Contact records before they were updated.
     */
    private void deleteOldCVs(List<Contact> newList, Map<Id, Contact> oldMap) {
        // Set of Ids of the old versions of the CV documents
        Set<Id> documentIdsToDelete = new Set<Id>();

        for (Contact con : newList) {
            // Add the old CV document id to the set only if the new CV document id is not the same as the old one
            if (con.CV_DocumentId__c != oldMap.get(con.Id).CV_DocumentId__c
                && String.isNotBlank(oldMap.get(con.Id).CV_DocumentId__c)) {
                documentIdsToDelete.add(oldMap.get(con.Id).CV_DocumentId__c);
            }
        }

        // Delete the old CV documents
        DocumentService.deleteDocumentsByIds(documentIdsToDelete);
    }
}