import { LightningElement, wire, track, api } from 'lwc';
import getItems from '@salesforce/apex/ItemController.getItems';
import deleteItem from '@salesforce/apex/ItemController.deleteItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ItemsList extends LightningElement {
    @api isManager;
    @track items = [];
    @track filteredItems = [];
    searchKey = '';
    selectedTypes = [];
    selectedFamilies = [];
    error;

    @wire(getItems)
    wiredItems({ data, error }) {
        if (data) {
            this.items = data;
            this.filteredItems = data;
        } else if (error) {
            this.error = error;
        }
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.applyFilters();
    }

    handleFilterChange(event) {
        this.selectedTypes = event.detail.types;
        this.selectedFamilies = event.detail.families;
        this.applyFilters();
    }

    applyFilters() {
        this.filteredItems = this.items.filter(item => {
            const matchesSearch =
                item.Name.toLowerCase().includes(this.searchKey) ||
                (item.Description__c && item.Description__c.toLowerCase().includes(this.searchKey));

            const matchesType =
                this.selectedTypes.length === 0 || this.selectedTypes.includes(item.Type__c);

            const matchesFamily =
                this.selectedFamilies.length === 0 || this.selectedFamilies.includes(item.Family__c);

            return matchesSearch && matchesType && matchesFamily;
        });
    }

    handleDelete(event) {
        const itemId = event.target.dataset.id;
        deleteItem({ itemId })
            .then(() => {
                this.items = this.items.filter(item => item.Id !== itemId);
                this.applyFilters();
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