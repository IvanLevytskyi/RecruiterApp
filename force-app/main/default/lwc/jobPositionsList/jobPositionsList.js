import { LightningElement, wire, track } from 'lwc';

import { reduceErrors } from 'c/ldsUtils';

// Apex methods
import getJobPositions from '@salesforce/apex/JobPositionsListController.getJobPositions';

// Constants
const ITEMS_PER_PAGE = 10; // number of job positions to display on each page

export default class JobPositionsList extends LightningElement {
    @track jobPositionsToDisplay; // list of filtered job positions to display
    @track jobPositionsOnPage; // list of job positions to display on the current page
    jobPositions; // list of all open job positions
    searchTerm; // search term to filter job positions
    showFilterPanel = false; // whether or not to show the filter panel. Also serves as a toggle for the corresponding stateful button

    salaryFromValue = 0; // salary from

    isRemoteValue = 'all'; // is remote filter value

    // is remote options
    isRemoteOptions = [
        { label: 'All', value: 'all' },
        { label: 'Remote', value: 'remote' }
    ];

    /**
     * Fetch job positions and process them.
     */
    @wire(getJobPositions)
    wiredJobPositions({ error, data }) {
        if (data) {
            let processedData = this.processJobPositions(data);
            this.jobPositions = processedData;
            this.jobPositionsToDisplay = processedData;
            this.jobPositionsOnPage = this.getItemsOnPage(processedData, 1);
        } else if (error) {
            console.error('Error occured while fetching job positions: ' + reduceErrors(error).join(', '));
            this.jobPositions = undefined;
        }
    }

    /**
     * CSS class for the right panel
     */
    get panelClass() {
        return 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-left slds-panel_drawer '
            + (this.showFilterPanel ? 'slds-is-open' : 'slds-hidden');
    }

    /**
     * Get number of pages to display.
     */
    get numberOfPages() {
        if (!this.jobPositionsToDisplay) {
            return 0;
        }
        return Math.ceil(this.jobPositionsToDisplay.length / ITEMS_PER_PAGE);
    }

    /**
     * Get number of job positions to display.
     */
    get numberOfJobPositions() {
        if (!this.jobPositionsToDisplay) {
            return 0;
        }
        return this.jobPositionsToDisplay.length;
    }

    /**
     * Determines whether to show notifications about missing records to meet the relevant criteria
     */
    get noRecordsMatchCriteria() {
        return this.numberOfJobPositions == 0;
    }

    /**
     * Process job positions.
     */
    processJobPositions(jobPositions) {
        let result = [];

        for (let jobPosition of jobPositions) {
            let tempJobPositon = {}
            tempJobPositon.id = jobPosition.Id;
            tempJobPositon.title = jobPosition.Name;
            tempJobPositon.numberOfApplications = this.getNumberOfApplicantsText(jobPosition.Number_of_job_applications__c);
            tempJobPositon.daysOpen = jobPosition.Days_Open__c;
            tempJobPositon.createdDate = jobPosition.CreatedDate;
            tempJobPositon.isRemote = jobPosition.Is_remote_allowed__c;
            tempJobPositon.description = jobPosition.Description__c;
            tempJobPositon.shortDescription = this.getShortenedText(jobPosition.Description__c);
            tempJobPositon.salaryFrom = jobPosition.Salary_from__c;
            tempJobPositon.salaryTo = jobPosition.Salary_to__c;
            result.push(tempJobPositon);
        }

        return result;
    }

    /**
     * Get number of applicants as text
     */
    getNumberOfApplicantsText(numberOfApplications) {
        return numberOfApplications + ' applicant' + (numberOfApplications == 1 ? '' : 's');
    }

    /**
     * Trim text to 200 characters
     */
    getShortenedText(text) {
        const maxLength = 200; // maximum text length
        const strippedText = text.replace(/<[^>]+>/g, ''); // remove HTML tags
        return strippedText.length > maxLength
            ? strippedText.substring(0, maxLength) + '...'
            : strippedText;
    }

    /**
     * Display of relevant job positions depending on the page opened
     */
    handlePageChanges(event) {
        const pageNumber = event.detail;
        this.jobPositionsOnPage = this.getItemsOnPage(this.jobPositionsToDisplay, pageNumber);
    }

    /**
     * Get relevant records on the appropriate page
     */
    getItemsOnPage(items, pageNumber) {
        return items.slice(
            (pageNumber - 1) * ITEMS_PER_PAGE,
            pageNumber * ITEMS_PER_PAGE
        );
    }

    /**
     * Handling changes to the search query
     */
    searchChangeHandler(event) {
        this.searchTerm = event.detail.value;
        this.jobPositionsToDisplay = this.search(this.jobPositions, this.searchTerm);
        this.jobPositionsOnPage = this.getItemsOnPage(this.jobPositionsToDisplay, 1);
    }

    /**
     * Filter job positions using a search query
     */
    search(items, searchTerm) {
        if (this.searchTerm) {
            return items.filter(item => item.title.toLowerCase().includes(searchTerm.toLowerCase()));
        } else {
            return items;
        }
    }

    /**
     * Reset filters
     */
    resetFilters() {
        // Set All for Is Remote

        const isRemoteRadio = this.template.querySelector(`[data-name="isRemoteRadio"]`);

        if (isRemoteRadio) {
            isRemoteRadio.value = 'all';
            this.isRemoteValue = 'all';
        }

        // Set 'Salary from' to 0
        this.salaryFromValue = 0;

        // Reinitialise job positions lists
        this.jobPositionsToDisplay = this.jobPositions.slice();
        this.jobPositionsToDisplay = this.search(this.jobPositionsToDisplay, this.searchTerm)
        this.jobPositionsOnPage = this.getItemsOnPage(this.jobPositionsToDisplay, 1);
    }

    /**
     * Apply the selected filters
     */
    applyFilters() {
        this.jobPositionsToDisplay = this.filterJobPositions();
        this.jobPositionsOnPage = this.getItemsOnPage(this.jobPositionsToDisplay, 1);
    }

    /**
     * Filter job positions depending on the selected filters
     */
    filterJobPositions() {
        let jobPositions = this.jobPositions.slice();

        if (this.isRemoteValue == 'remote') {
            jobPositions = jobPositions.filter(jobPosition => jobPosition.isRemote);
        }

        if (this.salaryFromValue) {
            jobPositions = jobPositions.filter(
                jobPosition => jobPosition.salaryFrom >= this.salaryFromValue || jobPosition.salaryTo >= this.salaryFromValue
            );
        }

        return jobPositions;
    }

    /**
     * Handle changes in the Is Remote
     */
    handleIsRemoteChange(event) {
        this.isRemoteValue = event.detail.value;
    }

    /**
     * Handle changes in the Salary From
     */
    handleSalaryFromChange(event) {
        this.salaryFromValue = event.detail.value;
    }

    /**
     * Handle filter buttons click
     */
    handleFilterButtonClick() {
        this.showFilterPanel = !this.showFilterPanel;
    }
}