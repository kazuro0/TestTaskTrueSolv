@isTest
public class PurchaseLineTriggerTest {
	@testSetup
	static void setup() {
		Account acc = new Account(Name='Test Account');
		insert acc;

		Item__c item = new Item__c(Name='Laptop', Price__c=1000);
		insert item;

		Purchase__c purchase = new Purchase__c(ClientId__c=acc.Id);
		insert purchase;
	}

	@isTest
	static void testTriggerUpdatesPurchaseTotals() {
		Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];
		Purchase__c purchase = [SELECT Id FROM Purchase__c LIMIT 1];

		Test.startTest();
		PurchaseLine__c line = new PurchaseLine__c(
				PurchaseId__c = purchase.Id,
				ItemId__c = item.Id,
				Amount__c = 2,
				UnitCost__c = item.Price__c
		);
		insert line;
		Test.stopTest();

		Purchase__c updatedPurchase = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :purchase.Id];
		System.assertEquals(2, updatedPurchase.TotalItems__c, '2 items required');
		System.assertEquals(2000, updatedPurchase.GrandTotal__c, 'grand total must be 2000');
	}
}