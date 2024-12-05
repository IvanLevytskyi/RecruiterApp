import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// SObject fields
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import CV_DOCUMENT_ID from "@salesforce/schema/Contact.CV_DocumentId__c";
import DOCUMENT_NAME from "@salesforce/schema/ContentDocument.Title";
import DOCUMENT_CREATED_DATE from '@salesforce/schema/ContentDocument.CreatedDate';

// this gets you the logged in user Id
import USER_ID from "@salesforce/user/Id";

import { reduceErrors } from 'c/ldsUtils';

export default class UploadUserCV extends LightningElement {
    acceptedFormats = [".pdf", ".docx"]; // accepted file formats for uploading
    ampm = false; // to show the time in AM/PM format

    /**
     * Get the user record of the logged in user
     */
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user;

    /**
     * Get the contact record of the logged in user
     */
    @wire(getRecord, { recordId: '$contactId', fields: [CV_DOCUMENT_ID] })
    contact;

    /**
     * Get the document name and created date by document Id
     */
    @wire(getRecord, { recordId: '$cvDocumentId', fields: [DOCUMENT_NAME, DOCUMENT_CREATED_DATE] })
    document;

    /**
     * Get the contact id of the logged in user
     */
    get contactId() {
        return getFieldValue(this.user.data, CONTACT_ID);
    }

    /**
     * Get the CV document Id of the logged in user
     */
    get cvDocumentId() {
        return getFieldValue(this.contact.data, CV_DOCUMENT_ID);
    }

    /**
     * Get the document name
     */
    get documentName() {
        return getFieldValue(this.document.data, DOCUMENT_NAME);
    }

    /**
     * Get the document created date
     */
    get documentCreatedDate() {
        return getFieldValue(this.document.data, DOCUMENT_CREATED_DATE);
    }

    /**
     * Handle onuploadfinished event to update CV Document Id on contact.
     */
    handleUploadFinished(event) {
        this.updateCVdocumentId(event.detail.files[0].documentId, event.detail.files[0].name);
    }

    /**
     * Update the CV document Id on contact record.
     */
    updateCVdocumentId(documentId, documentName) {
        // Create a record to update using LDS
        let contactToUpdate = {
            fields: {}
        }
        contactToUpdate.fields.Id = this.contactId;
        contactToUpdate.fields[CV_DOCUMENT_ID.fieldApiName] = documentId;

        updateRecord(contactToUpdate)
            .then(() => {
                refreshApex(this.contact);
                this.showToast('success',  'CV \'' + documentName + '\' has been successfuly uploaded');
            })
            .catch(error => {
                console.error(reduceErrors(error).join(', '));
                this.showToast('error', 'Something went wrong while uploading the file: ' + reduceErrors(error).join(', '));
            })
    }

    /**
     * Show a toast of the specified type
     */
    showToast(variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant.toUpperCase(),
                message: message,
                variant: variant,
                mode: 'dismissable'
            })
        );
    }
}