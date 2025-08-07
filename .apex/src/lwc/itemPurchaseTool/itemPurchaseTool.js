import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const FIELDS = ['User.IsManager__c'];

export default class ItemPurchaseTool extends LightningElement {
    isManager = false;

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            this.isManager = data.fields.IsManager__c.value;
            console.log("Is manager: " + this.isManager);
        } else if (error) {
            console.error('Ошибка получения пользователя:', error);
        }
    }
}