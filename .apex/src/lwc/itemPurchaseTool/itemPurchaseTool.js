import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import createPurchaseWithLines from '@salesforce/apex/PurchaseController.createPurchaseWithLines';

const FIELDS = ['User.IsManager__c'];

export default class ItemPurchaseTool extends NavigationMixin(LightningElement) {
    isManager = false;

    accountId;
    accountName;
    accountNumber;
    accountIndustry;

    isModalOpen = false;

    cartItems = [];
    isCartModalOpen = false;

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            this.isManager = data.fields.IsManager__c.value;
        } else if (error) {
            console.error('Ошибка получения пользователя: ', error);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accountId = currentPageReference.state?.c__accountId;
            console.log(this.accountId);
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

    handleAddToCart(event) {
        const item = event.detail;
        console.log('Adding to cart:', item);
        if (!item.Id) {
            console.error('Item missing Id:', item);
            return;
        }
        const existing = this.cartItems.find(ci => ci.Id === item.Id);
        if (existing) {
            existing.quantity += 1;
            this.cartItems = [...this.cartItems];
        } else {
            this.cartItems = [...this.cartItems, { ...item, quantity: 1 }];
        }
    }

    openCartModal() {
        this.isCartModalOpen = true;
    }

    closeCartModal() {
        this.isCartModalOpen = false;
    }

    get cartItemsWithTotal() {
        return this.cartItems.map(item => {
            return {
                ...item,
                totalPrice: (item.Price__c || 0) * (item.quantity || 0)
            };
        });
    }

    get cartTotal() {
        return this.cartItemsWithTotal.reduce((sum, item) => sum + item.totalPrice, 0);
    }

    handleCheckout() {
        if (this.cartItems.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cart Empty',
                    message: 'Please add items to the cart before checkout.',
                    variant: 'warning'
                })
            );
            return;
        }

        const lines = this.cartItems.map(item => {
            return {
                itemId: item.Id,
                amount: item.quantity,
                unitCost: item.Price__c
            };
        });

        console.log('Creating purchase with:', this.accountId, JSON.stringify(lines));

        createPurchaseWithLines({
            clientId: this.accountId,
            lines: JSON.parse(JSON.stringify(lines))
        })
            .then(purchaseId => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Purchase created successfully',
                        variant: 'success'
                    })
                );
                this.cartItems = [];
                this.closeCartModal();

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: purchaseId,
                        objectApiName: 'Purchase__c',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                console.error('Checkout error:', JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating purchase',
                        message: error.body ? error.body.message : JSON.stringify(error),
                        variant: 'error'
                    })
                );
            });
    }
}
