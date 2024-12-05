import { LightningElement, api } from "lwc";

export default class CustomPill extends LightningElement {
    @api iconName; // icon to be displayed in the pill
    @api label; // label to be displayed in the pill
    @api showRemoveButton; // boolean to show or not to show the remove button
    @api value; // value to be passed to the parent component

    /**
     * Handles the click on the pill.
     * Dispatches a 'clicked' event with the label and value of the pill.
     */
    onClickHandler(event) {
        // Prevents the anchor element from navigating to a URL.
        event.preventDefault();

        // Creates the event with the label & value data.
        const selectedEvent = new CustomEvent("clicked", {
            detail: {
                label: this.label,
                value: this.value
            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    /**
     * Handles the click on the remove button.
     * Dispatches a 'remove' event with the label and value of the pill.
     */
    onRemoveHandler() {
        this.dispatchEvent(new CustomEvent("remove", {
            detail: {
                label: this.label,
                value: this.value
            }
        }));
    }
}
