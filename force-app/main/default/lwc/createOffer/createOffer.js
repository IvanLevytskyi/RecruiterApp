import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import modal component for rendered email
import RenderedEmailModal from 'c/renderedEmailModal';

import { reduceErrors } from 'c/ldsUtils';

// Apex methods
import getInitialData from '@salesforce/apex/JobOfferController.getInitialData';
import generateOffer from '@salesforce/apex/JobOfferController.generateOffer';
import getRenderedEmail from '@salesforce/apex/JobOfferController.getRenderedEmail';

export default class CreateOffer extends LightningElement {
    @api recordId;

    offerInfo; // job offer information
    showSpinner = false; // to show or not to show the spinner

    /**
     * Get initial information about the job offer
     */
    @wire(getInitialData, { jobApplicationId: '$recordId' })
    wiredInitialization({ error, data }) {
        if (data) {
            this.offerInfo = { ...data };
        } else if (error) {
            console.error('Error while getting initial data: ' + reduceErrors(error).join(', '));
        }
    }

    /**
     * Get the current date and format as string
     */
    get today() {
        return new Date().toISOString().slice(0, 10);
    }

    /**
     * Get the header title
     */
    get headerTitle() {
        return 'Create a job offer for ' + this.offerInfo?.candidateName;
    }

    /**
     * Get the card title
     */
    get cardTitle() {
        return 'Job Offer Information - ' + this.offerInfo?.jobTitle;
    }

    /**
     * Handle the cancel action that close quick action screen
     */
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /**
     * Handle changes in the input fields
     */
    handleFieldChange(event) {
        const fieldName = event.target.dataset.fieldname;
        const fieldValue = event.detail.value;

        this.offerInfo[fieldName] = fieldValue;
    }

    /**
     * Call Apex method that render the email template and display it in a modal
     */
    handlePreviewEmail() {
        getRenderedEmail({ offerInfo: this.offerInfo })
            .then(renderedEmail => {
                RenderedEmailModal.open({
                    size: 'medium',
                    description: 'Rendered email template for sending offers',
                    content: renderedEmail,
                });
            })
            .catch(error => {
                let errorMessage = 'Something went wrong while rendering the email template: ' + reduceErrors(error).join(', ');
                this.showToast('error', errorMessage);
                console.error(errorMessage);
            });
    }

    /**
     * Render an offer as PDF file and open in a new tab
     */
    handlePreviewOffer() {
        window.open(this.getOfferUrl(), '_blank');
    }

    /**
     * Get the offer PDF file URL
     */
    getOfferUrl() {
        const queryParams = Object.entries(this.offerInfo)
            .filter(([key, value]) => value !== '' && value !== null && value !== undefined)  // Filtering out empty values
            .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)  // Create parameters
            .join('&');  // Combine into a string

        return '/apex/JobOfferLetter?' + queryParams;
    }

    /**
     * Generate, save and send the offer as an email
     */
    handleSendEmail() {
        this.showSpinner = true;

        if (!this.validateInput()) {
            this.showSpinner = false;
            return;
        }

        generateOffer({ offerInfo: this.offerInfo, sendEmail: true })
            .then(() => {
                this.showToast('success', 'The offer has been successfully generated, saved and sent by email!');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((error) => {
                let errorMessage = 'Something went wrong while generating the offer: ' + reduceErrors(error).join(', ');
                this.showToast('error', errorMessage);
                console.error(errorMessage);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    /**
     * Generate the offer as a PDF file and save it in the Documents
     */
    handleGenerate() {
        this.showSpinner = true;

        if (!this.validateInput()) {
            this.showSpinner = false;
            return;
        }

        generateOffer({ offerInfo: this.offerInfo, sendEmail: false })
            .then(() => {
                this.showToast('success', 'The offer has been successfully generated and saved!');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((error) => {
                let errorMessage = 'Something went wrong while generating the offer: ' + reduceErrors(error).join(', ');
                this.showToast('error', errorMessage);
                console.error(errorMessage);
            })
            .finally(() => {
                this.showSpinner = false;
            });
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