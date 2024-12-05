import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';

// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";

// SObject fields
import USER_CONTACT_ID from "@salesforce/schema/User.ContactId";
import CANDIDATE_SKILL_OBJECT from "@salesforce/schema/Candidate_Skill__c";
import CANDIDATE_FIELD from "@salesforce/schema/Candidate_Skill__c.Candidate__c";
import SKILL_FIELD from "@salesforce/schema/Candidate_Skill__c.Skill__c";

import { reduceErrors } from 'c/ldsUtils';

// Apex methods
import getSkills from '@salesforce/apex/UserSkillSelectorController.getSkills';
import getCandidateSkills from '@salesforce/apex/UserSkillSelectorController.getCandidateSkills';

export default class UserSkillsSelector extends LightningElement {
    skills; // list of all skills
    candidateSkills; // list of candidate's skills
    skillsToDisplay; // list of skills to display filter by search term
    searchTerm; // search term to filter skills

    /**
     * Get the user record of the logged in user
     */
    @wire(getRecord, { recordId: USER_ID, fields: [USER_CONTACT_ID] })
    user;

    /**
     * Get the list of all skills
     */
    @wire(getSkills)
    wiredSkills({ error, data }) {
        if (data) {
            this.skills = data;
            this.checkDataReady();
        } else if (error) {
            console.error('Error occured while fetching skills: ' + reduceErrors(error).join(', '));
            this.skills = undefined;
        }
    }

    // the result of the wire used fot applying refreshApex
    wiredCandidateSkillsResult;

    /**
     * Get the list of candidate's skills
     */
    @wire(getCandidateSkills, { contactId: '$contactId' })
    wiredCandidateSkills(result) {
        this.wiredCandidateSkillsResult = result;
        if (result.data) {
            this.candidateSkills = result.data;
            this.checkDataReady();
        } else if (result.error) {
            console.error('Error occured while fetching candidate skills: ' + reduceErrors(result.error).join(', '));
            this.candidateSkills = undefined;
        }
    }

    /**
     * Get the contact id of the logged in user
     */
    get contactId() {
        return getFieldValue(this.user.data, USER_CONTACT_ID);
    }

    /**
     * Display skills filtered by the search term and that have not been selected
     */
    displaySkills() {
        // remove skills already selected
        const skillIds = this.candidateSkills.map(item => item.value.skillId);
        const uniqueSkillIds = new Set(skillIds);
        this.skillsToDisplay = this.skills.filter(item => !uniqueSkillIds.has(item.value));

        // filter skills by search term
        if (this.searchTerm) {
            this.skillsToDisplay = this.skillsToDisplay.filter(item => item.label.toLowerCase().includes(this.searchTerm.toLowerCase()));
        }
    }

    /**
     * Handle the remove candidate skill event
     */
    handleRemoveCandidateSkill(event) {
        const recordId = event.detail.value.candidateSkillId;

        deleteRecord(recordId)
            .then(() => {
                refreshApex(this.wiredCandidateSkillsResult).then(() => {
                    this.displaySkills();
                });
            })
            .catch(error => {
                console.error('Error occured while deleting candidate skill: ' + reduceErrors(error).join(', '));
            });
    }

    /**
     * Handle the add candidate skill event
     */
    handleClickedSkill(event) {
        const skillId = event.detail.value;

        const fields = {};

        fields[SKILL_FIELD.fieldApiName] = skillId;
        fields[CANDIDATE_FIELD.fieldApiName] = this.contactId;

        const recordInput = { apiName: CANDIDATE_SKILL_OBJECT.objectApiName, fields };

        createRecord(recordInput).then(() => {
            refreshApex(this.wiredCandidateSkillsResult).then(() => {
                this.displaySkills();
            });
        }).catch(error => {
            console.error('Error occured while creating candidate skill: ' + reduceErrors(error).join(', '));
        });
    }

    /**
     * Handle the search term changes
     */
    searchChangeHandler(event) {
        this.searchTerm = event.detail.value;
        this.displaySkills();
    }

    /**
     * Check if data is initialized and ready to be displayed
     */
    checkDataReady() {
        if (this.skills && this.candidateSkills) {
            this.displaySkills();
        }
    }
}