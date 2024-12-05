import { LightningElement, api, track } from 'lwc';

export default class Paginator extends LightningElement {
    _maxPageNumber; // private property for max page number

    @track pagesInfo = []; // list of pages to display
    @api currentPage = 1; // current page number
    // max page number - value used to render pages
    @api
    get maxPageNumber() {
        return this._maxPageNumber;
    }

    set maxPageNumber(value) {
        this._maxPageNumber = value;
        this.currentPage = 1;
        this.renderPages();
    }

    /**
     * Called when the element is added to the DOM.
     * In this method, we initialize the display of pages by calling the renderPages() method.
     */
    connectedCallback() {
        this.renderPages();
    }

    /**
     * Returns true if the Next button should be disabled.
     */
    get isNextDisabled() {
        return this.currentPage == this.maxPageNumber;
    }

    /**
     * Returns true if the Previous button should be disabled.
     */
    get isPreviousDisabled() {
        return this.currentPage == 1;
    }

    /**
     * Handle the Next button click event.
     */
    handleNext() {
        if (this.currentPage < this.maxPageNumber) {
            this.currentPage++;
            this.renderPages();
            this.dispatchChangeEvent(this.currentPage);
        }
    }

    /**
     * Handle the Previous button click event.
     */
    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.renderPages();
            this.dispatchChangeEvent(this.currentPage);
        }
    }

    /**
     * Handle the Page button click event.
     */
    handleClick(event) {
        if (event.target.name != this.currentPage) {
            this.currentPage = event.target.name;
            this.renderPages();
            this.dispatchChangeEvent(this.currentPage);
        }
    }

    /**
     * Render the pages to display.
     */
    renderPages() {
        let result = [];
        for (let i = 1; i <= this.maxPageNumber; i++) {
            result.push({
                number: i,
                isCurrent: i == this.currentPage,
                isDisabled: i == this.currentPage,
                variant: i == this.currentPage ? 'brand' : 'text'
            });
        }
        this.pagesInfo = result;
    }

    /**
     * Dispatch a change event with the page number.
     */
    dispatchChangeEvent(pageNumber) {
        this.dispatchEvent(new CustomEvent("change", {
            detail: pageNumber
        }));
    }
}