import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class RenderedEmailModal extends LightningModal {
    @api content; // email content

    /**
     * Closes the rendered email modal.
     */
    handleClose() {
        this.close('closed');
    }
}