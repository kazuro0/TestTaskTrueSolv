import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ITEM_OBJECT from '@salesforce/schema/Item__c';
import TYPE_FIELD from '@salesforce/schema/Item__c.Type__c';
import FAMILY_FIELD from '@salesforce/schema/Item__c.Family__c';

export default class FilterList extends LightningElement {
    @api itemsCount = 0;

    @track selectedTypes = [];
    @track selectedFamilies = [];
    @track typeOptions = [];
    @track familyOptions = [];

    @wire(getObjectInfo, { objectApiName: ITEM_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TYPE_FIELD
    })
    wiredTypeValues({ data }) {
        if (data) {
            this.typeOptions = data.values;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FAMILY_FIELD
    })
    wiredFamilyValues({ data }) {
        if (data) {
            this.familyOptions = data.values;
        }
    }

    handleTypeChange(event) {
        const { value, checked } = event.target;
        if (checked) {
            this.selectedTypes = [...this.selectedTypes, value];
        } else {
            this.selectedTypes = this.selectedTypes.filter(v => v !== value);
        }
        this.fireFilterEvent();
    }

    handleFamilyChange(event) {
        const { value, checked } = event.target;
        if (checked) {
            this.selectedFamilies = [...this.selectedFamilies, value];
        } else {
            this.selectedFamilies = this.selectedFamilies.filter(v => v !== value);
        }
        this.fireFilterEvent();
    }

    handleClear() {
        this.selectedTypes = [];
        this.selectedFamilies = [];
        this.template.querySelectorAll('lightning-input').forEach(input => input.checked = false);
        this.fireFilterEvent();
    }

    fireFilterEvent() {
        this.dispatchEvent(new CustomEvent('filterchange', {
            detail: {
                types: this.selectedTypes,
                families: this.selectedFamilies
            }
        }));
    }
}