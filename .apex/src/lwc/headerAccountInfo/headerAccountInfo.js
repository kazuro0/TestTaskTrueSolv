import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class HeaderAccountInfo extends LightningElement {
    accountName;
    accountNumber;
    accountIndustry

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accountName = currentPageReference.state?.c__accountName;
            this.accountNumber = currentPageReference.state?.c__accountNumber;
            this.accountIndustry = currentPageReference.state?.c__accountIndustry;
        }
    }
}