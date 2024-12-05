import { LightningElement, api, wire } from 'lwc';

import USER_ID from "@salesforce/user/Id";

import { CurrentPageReference } from 'lightning/navigation';

export default class UserProfileContainer extends LightningElement {
    @api recordId;

    show = false; // to show or not to show the component

    /**
     * Workaround to determine whether to display the contents of the container. 
     * Displayed only when the component is placed on a page that displays information about the current user
     */
    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        this.show = pageRef?.attributes?.recordId == USER_ID.slice(0, 15);
    }
}