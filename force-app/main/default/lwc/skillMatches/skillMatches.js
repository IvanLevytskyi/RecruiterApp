import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USER_CONTACT_ID from "@salesforce/schema/User.ContactId";
// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";

import { reduceErrors } from 'c/ldsUtils';

// Apex methods
import getCandidateSkills from '@salesforce/apex/UserSkillSelectorController.getCandidateSkills';
import getJobSkills from '@salesforce/apex/SkillMatchesController.getJobSkills';
import getSObjectNameById from '@salesforce/apex/SObjectService.getSObjectNameById';

export default class SkillMatches extends LightningElement {
    @api recordId;

    candidateSkills; // list of candidate's skills
    jobSkills; // list of skills required for the vacancy

    matchedSkills; // a list of skills required by the vacancy and which the candidate has
    missedSkills; // a list of skills that are required by the vacancy but the candidate does not have them

    show = false; // to show or not to show the component

    /**
     * Workaround to show the component only on the Job Positions pages 
     */
    @wire(getSObjectNameById, { recordId: '$recordId' })
    wiredSObjectName({ error, data }) {
        if (data) {
            this.show = data == 'Job_Position__c';
        } else if (error) {
            console.error('Error occured while fetching sobject name: ' + reduceErrors(error).join(', '));
        }
    }

    /**
     * Get the user record of the logged in user
     */
    @wire(getRecord, { recordId: USER_ID, fields: [USER_CONTACT_ID] })
    user;

    /**
     * Get skills of the logged in user
     */
    @wire(getCandidateSkills, { contactId: '$contactId' })
    wiredCandidateSkills({ error, data }) {
        if (data) {
            this.candidateSkills = data;
            this.processSkills();
        } else if (error) {
            console.error('Error occured while fetching candidate skills: ' + reduceErrors(error).join(', '));
            this.candidateSkills = undefined;
        }
    }

    /**
     * Get skills of the job position
     */
    @wire(getJobSkills, { jobId: '$recordId' })
    wiredJobSkills({ error, data }) {
        if (data) {
            this.jobSkills = data;
            this.processSkills();
        } else if (error) {
            console.error('Error occured while fetching job skills ' + reduceErrors(error).join(', '));
            this.jobSkills = undefined;
        }
    }

    /**
     * Get the contact id of the logged in user
     */
    get contactId() {
        return getFieldValue(this.user.data, USER_CONTACT_ID);
    }

    /**
     * Returns true if the job does not have a skill requirement
     */
    get noRequiredSkills() {
        return this.jobSkills === undefined || this.jobSkills.length === 0;
    }

    /**
     * Returns true if the candidate has all the skills required by the job
     */
    get allSkillsMatched() {
        return this.noRequiredSkills || this.matchedSkills.length === this.jobSkills.length;
    }

    /**
     * Returns true if the candidate does not have any of the skills required by the job
     */
    get noMatchedSkills() {
        return !this.noRequiredSkills && (this.matchedSkills === undefined || this.matchedSkills.length === 0);
    }

    /**
     * Returns true if the candidate has all the skills required by the job
     */
    get allSkillsMatched() {
        return !this.noRequiredSkills && this.matchedSkills && this.jobSkills.length === this.matchedSkills.length;
    }

    /**
     * Returns true if there are skills that the candidate does not have. Used to indicate whether to show or hide the corresponding section
     */
    get showMissedSection() {
        return this.missedSkills && this.missedSkills.length > 0;
    }

    /**
     * Process skills and create a list of matched skills and a list of missed skills
     */
    processSkills() {
        if (this.candidateSkills && this.jobSkills) {
            const candidateSkillIds = new Set(this.candidateSkills.map(skill => skill.value.skillId));

            // Filter matchedSkills and missedSkills
            this.matchedSkills = this.jobSkills.filter(jobSkill => candidateSkillIds.has(jobSkill.value));
            this.missedSkills = this.jobSkills.filter(jobSkill => !candidateSkillIds.has(jobSkill.value));
        }
    }
}