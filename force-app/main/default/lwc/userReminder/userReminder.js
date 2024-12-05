import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import basePath from "@salesforce/community/basePath";

// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";

// User fields
import USER_CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_FIRSTNAME from "@salesforce/schema/User.FirstName";
import USER_LASTNAME from "@salesforce/schema/User.LastName";
import USER_EMAIL from "@salesforce/schema/User.Email";
import USER_PHONE from "@salesforce/schema/User.Phone";
import USER_CITY from "@salesforce/schema/User.City";
import USER_COUNTRY from "@salesforce/schema/User.Country";

// Contact fields
import CONTACT_NUMBER_OF_SKILLS from "@salesforce/schema/Contact.Number_of_Skills__c";
import CONTACT_CV_DOCUMENT_ID from "@salesforce/schema/Contact.CV_DocumentId__c";

export default class UserReminder extends LightningElement {
    USER_FIELDS_TO_CHECK = [USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_CITY, USER_COUNTRY]; // fields to check if the user has all the required information
    CONTACT_FIELDS_TO_CHECK = [CONTACT_NUMBER_OF_SKILLS, CONTACT_CV_DOCUMENT_ID]; // fields to check if the contact has all the required information

    /**
     * Get the user record of the logged in user
     */
    @wire(getRecord, { recordId: USER_ID, fields: [USER_CONTACT_ID, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_CITY, USER_COUNTRY] })
    user;

    /**
     * Get the contact record of the logged in user
     */
    @wire(getRecord, { recordId: '$contactId', fields: [CONTACT_NUMBER_OF_SKILLS, CONTACT_CV_DOCUMENT_ID] })
    contact;

    /**
     * Get the link to the user profile page
     */
    get profileLink() {
        const before_ = `${basePath}`.substring(0, `${basePath}`.indexOf('/s') + 2);
        return `https://${location.host}${before_}` + '/profile/home';
    }

    /**
     * Get list of fields to populate
     */
    get fieldsToPopulate() {
        return this.checkUserFields().fieldsToPopulate;
    }

    /**
     * Returns true if there are fields to populate
     */
    get areMissingFields() {
        return Array.isArray(this.fieldsToPopulate) && this.fieldsToPopulate.length > 0;
    }

    /**
     * Returns the message to display for missing fields
     */
    get missingFieldsMessage() {
        return 'Fill in the fields on your profile (' + this.fieldsToPopulate.join(', ') + ')';
    }

    /**
     * Returns true wether the user hasn't uploaded the CV
     */
    get isMissingCV() {
        return !this.cvDocumentId;
    }

    /**
     * Returns true if user hasn't selected any skills on his profile page
     */
    get areMissingSkills() {
        return this.numberOfSkills == 0;
    }

    /**
     * Returns true if there is any information to display
     */
    get showMessage() {
        return this.contactId && (this.fieldsToPopulate.length > 0 || this.isMissingCV || this.areMissingSkills);
    }

    /**
     * Get the contact id of the logged in user
     */
    get contactId() {
        return getFieldValue(this.user.data, USER_CONTACT_ID);
    }

    /**
     * Get the user first name
     */
    get firstName() {
        return getFieldValue(this.user.data, USER_FIRSTNAME);
    }

    /**
     * Get the user last name
     */
    get lastName() {
        return getFieldValue(this.user.data, USER_LASTNAME);
    }

    /**
     * Get the user email
     */
    get email() {
        return getFieldValue(this.user.data, USER_EMAIL);
    }

    /**
     * Get the user phone
     */
    get phone() {
        return getFieldValue(this.user.data, USER_PHONE);
    }

    /**
     * Get the user city
     */
    get city() {
        return getFieldValue(this.user.data, USER_CITY);
    }

    /**
     * Get the user country
     */
    get country() {
        return getFieldValue(this.user.data, USER_COUNTRY);
    }

    /**
     * Get the number of skills of the logged in user
     */
    get numberOfSkills() {
        return getFieldValue(this.contact.data, CONTACT_NUMBER_OF_SKILLS);
    }

    /**
     * Get the CV document Id of the logged in user
     */
    get cvDocumentId() {
        return getFieldValue(this.contact.data, CONTACT_CV_DOCUMENT_ID);
    }

    /**
     * Check if the user has all the required fields populated
     */
    checkUserFields() {
        let isValid = true;
        let listOfFieldsToPopulate = []

        for (let field of this.USER_FIELDS_TO_CHECK) {
            if (!getFieldValue(this.user.data, field)) {
                isValid = false;
                listOfFieldsToPopulate.push(field.fieldApiName);
            }
        }

        return {
            isValid: isValid,
            fieldsToPopulate: listOfFieldsToPopulate
        }
    }
}