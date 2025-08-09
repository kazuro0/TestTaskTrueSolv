import { LightningElement, wire, track, api } from 'lwc';
import getItems from '@salesforce/apex/ItemController.getItems';
import deleteItem from '@salesforce/apex/ItemController.deleteItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ItemsList extends LightningElement {
    @api isManager;
    @track items = [];
    @track searchKey = '';
    error;

    @wire(getItems)
    wiredItems({ data, error }) {
        if (data) {
            this.items = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.items = [];
        }
    }

    get filteredItems() {
        if (!this.searchKey) {
            return this.items;
        }
        const key = this.searchKey.toLowerCase();
        return this.items.filter(item =>
            (item.Name && item.Name.toLowerCase().includes(key)) ||
            (item.Description__c && item.Description__c.toLowerCase().includes(key))
        );
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    handleDelete(event) {
        const itemId = event.target.dataset.id;
        deleteItem({ itemId })
            .then(() => {
                this.items = this.items.filter(item => item.Id !== itemId);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Item deleted successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}