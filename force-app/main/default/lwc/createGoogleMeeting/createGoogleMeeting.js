import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { reduceErrors } from 'c/ldsUtils';

// Apex methods
import getInitialData from '@salesforce/apex/GoogleCalendarService.getInitialData';
import createGoogleMeetEvent from '@salesforce/apex/GoogleCalendarService.createGoogleMeetEvent';

export default class CreateGoogleMeeting extends LightningElement {
    @api recordId;
    meetInfo; // meeting information
    showSpinner = false; // to show or not to show the spinner

    /**
     * Get initial information about the meeting
     */
    @wire(getInitialData, { jobApplicationId: '$recordId' })
    wiredInitialization({ error, data }) {
        if (data) {
            this.meetInfo = { ...data };
        } else if (error) {
            console.error('Error while getting initial data: ' + reduceErrors(error).join(', '));
        }
    }

    /**
     * Handle changes in the input fields
     */
    handleFieldChange(event) {
        const fieldName = event.target.dataset.fieldname;
        const fieldValue = event.detail.value;

        this.meetInfo[fieldName] = fieldValue;
    }

    /**
     * Validate the input fields
     */
    validateInput() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;

        inputs.forEach(input => {
            if (!input.checkValidity()) {
                isValid = false;
                input.reportValidity();
            }
        });

        // If some data is invalid, show a toast of the error type
        if (!isValid) {
            this.showToast('error', 'Please check the fields with errors');
        }

        return isValid;
    }

    /**
     * Create the meeting
     */
    handleCreate() {
        this.showSpinner = true;

        if (!this.validateInput()) {
            this.showSpinner = false;
            return;
        }

        // Calling the Apex method that will create a Google meeting
        createGoogleMeetEvent({ meetInfo: this.meetInfo })
            .then(() => {
                this.showToast('success', 'The meeting has been successfully created!');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((error) => {
                let errorMessage = 'Something went wrong while creating the meeting: ' + reduceErrors(error).join(', ');
                this.showToast('error', errorMessage);
                console.error(errorMessage);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    // Handle the cancel button click that close quick action screen
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Show a toast of the specified type
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