import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HeaderAccountInfo extends LightningElement {
    @api isManager;
    accountName;
    accountNumber;
    accountIndustry;

    isModalOpen = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accountName = currentPageReference.state?.c__accountName;
            this.accountNumber = currentPageReference.state?.c__accountNumber;
            this.accountIndustry = currentPageReference.state?.c__accountIndustry;
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleSuccess(event) {
        this.closeModal();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Item created successfully',
                variant: 'success'
            })
        );
        this.dispatchEvent(
            new CustomEvent('itemcreated', {
                detail: { id: event.detail.id }
            })
        );
    }

    handleSubmit(event) {
        const allValid = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!allValid) {
            event.preventDefault(); // отмена сабмита
        }
    }
}