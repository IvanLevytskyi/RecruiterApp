import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";

// User fields
import USER_CONTACT_ID from "@salesforce/schema/User.ContactId";

import { reduceErrors } from 'c/ldsUtils';

// Apex methods
import validateBeforeApplication from "@salesforce/apex/JobApplicationController.validateBeforeApplication";
import applyForAJob from '@salesforce/apex/JobApplicationController.applyForAJob';

export default class JobApplication extends NavigationMixin(LightningElement) {
    @api recordId;
    isValid; // to check if the application is valid
    messages = []; // list of messages to display
    showSpinner = true; // to show or not to show the spinner

    /**
     * Get the user record of the logged in user
     */
    @wire(getRecord, { recordId: USER_ID, fields: [USER_CONTACT_ID] })
    user;

    /**
     * Validate the application before creating
     */
    @wire(validateBeforeApplication, { jobPositionId: '$recordId' })
    wiredValidation({ error, data }) {
        if (data) {
            this.isValid = data.isValid;
            this.messages = data.messages;
        } else if (error) {
            let errorMessage = 'Error occured while validation check: ' + reduceErrors(error).join(', ');
            console.error(errorMessage);
            this.isValid = false;
            this.messages = reduceErrors(error);
        }

        this.showSpinner = false;
    }

    /**
     * Check if the apply button can be pressed
     */
    get disableApplyButton() {
        return !this.isValid;
    }

    /**
     * Get the contact id of the logged in user
     */
    get contactId() {
        return getFieldValue(this.user.data, USER_CONTACT_ID);
    }

    /**
     *
     */
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /**
     * Handle the cancel action that close quick action screen
     */
    handleApply() {
        this.showSpinner = true;
        applyForAJob({ jobPositionId: this.recordId, userContactId: this.contactId })
            .then((applicationId) => {
                this.showToast('success', 'You have successfully applied for a job');
                this.openApplicationRecord(applicationId);
            })
            .catch(error => {
                let errorMessage = 'Error occured while applying for a job: ' + reduceErrors(error).join(', ');
                console.error(errorMessage);
                this.showToast('error', errorMessage);
            })
            .finally(() => {
                this.showSpinner = false;
            });
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

    /**
     * Open the application record
     */
    openApplicationRecord(applicationId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: applicationId,
                actionName: "view",
            },
        });
    }
}