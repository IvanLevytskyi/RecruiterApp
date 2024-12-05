import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class JobPositionCard extends NavigationMixin(LightningElement) {
    @api jobPosition; // job position record

    /**
     * Opens the job position record
     */
    openJobPosition(event) {
        const jobPositionId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: jobPositionId,
                actionName: "view"
            }
        });
    }
}
