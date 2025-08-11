import { LightningElement, wire, track, api } from 'lwc';
import getItems from '@salesforce/apex/ItemController.getItems';
import deleteItem from '@salesforce/apex/ItemController.deleteItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const FIELDS = ['User.IsDev__c'];

export default class ItemsList extends LightningElement {
    @api isManager;
    @track items = [];
    @track filteredItems = [];

    isDev;

    searchKey = '';
    selectedTypes = [];
    selectedFamilies = [];
    error;

    @track wiredItemsResult;

    @track selectedItem = null;
    @track isDetailsModalOpen = false;

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            this.isDev = data.fields.IsDev__c.value;
        } else if (error) {
            console.error('IsDev error: ', error);
        }
    }

    handleDetailsClick(event) {
        const itemId = event.target.dataset.id;
        const item = this.filteredItems.find(i => i.Id === itemId);
        if (item) {
            this.selectedItem = item;
            this.isDetailsModalOpen = true;
        }
    }

    closeDetailsModal() {
        this.isDetailsModalOpen = false;
        this.selectedItem = null;
    }

    @wire(getItems)
    wiredItems(result) {
        this.wiredItemsResult = result;
        const { data, error } = result;
        if (data) {
            this.items = data;
            this.filteredItems = data;
        } else if (error) {
            console.error('Error loading items', error);
        }
    }

    @api
    async refreshItems() {
        await new Promise(resolve => setTimeout(resolve, 500));

        try {
            await refreshApex(this.wiredItemsResult);
            console.log('Items list refreshed successfully');
        } catch (error) {
            console.error('Error refreshing items', error);
            throw error;
        }
    }


    // handleItemCreated() {
    //     getItems()
    //         .then(data => {
    //             this.items = data;
    //             this.filteredItems = data;
    //             this.applyFilters();
    //         })
    //         .catch(error => {
    //             console.error('Error refreshing items', error);
    //         });
    // }

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

    handleAddClick(event) {
        const itemId = event.target.dataset.id;
        const item = this.filteredItems.find(i => i.Id === itemId);
        if (item) {
            this.dispatchEvent(new CustomEvent('addtocart', { detail: item }));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'The item has been added to the cart.',
                    variant: 'success'
                })
            );
        }
    }
}