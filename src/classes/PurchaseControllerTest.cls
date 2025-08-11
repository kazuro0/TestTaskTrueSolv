@isTest
public class PurchaseControllerTest {
	@testSetup
	static void setup() {
		Account acc = new Account(Name='Test Account');
		insert acc;

		List<Item__c> items = new List<Item__c>{
				new Item__c(Name='Laptop', Type__c='Electronics', Price__c=1000),
				new Item__c(Name='T-Shirt', Type__c='Clothing', Price__c=25),
				new Item__c(Name='Coffee', Type__c='Food', Price__c=15)
				};
		insert items;
	}

	@isTest
	static void testCreatePurchaseWithAllItemTypes() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		List<Item__c> items = [SELECT Id, Type__c, Price__c FROM Item__c];

		List<PurchaseController.PurchaseLineWrapper> lines = new List<PurchaseController.PurchaseLineWrapper>();
		for(Item__c item : items) {
			PurchaseController.PurchaseLineWrapper line = new PurchaseController.PurchaseLineWrapper();
			line.itemId = item.Id;
			line.amount = 1;
			line.unitCost = item.Price__c;
			lines.add(line);
		}

		Test.startTest();
		Id purchaseId = PurchaseController.createPurchaseWithLines(acc.Id, lines);
		Test.stopTest();

		Purchase__c createdPurchase = [SELECT Id, ClientId__c FROM Purchase__c WHERE Id = :purchaseId];
		System.assertEquals(acc.Id, createdPurchase.ClientId__c, 'Wrong client in purchase');

		List<PurchaseLine__c> createdLines = [
				SELECT Id, ItemId__r.Type__c, Amount__c, UnitCost__c
				FROM PurchaseLine__c
				WHERE PurchaseId__c = :purchaseId
		];

		System.assertEquals(3, createdLines.size(), 'Sould be 3 purhcase lines');

		for(PurchaseLine__c line : createdLines) {
			System.assertEquals(1, line.Amount__c, 'Amount should be 1');
			System.assertNotEquals(null, line.UnitCost__c, 'Cost must be not null');
		}
	}

	@isTest
	static void testCreatePurchaseWithNoLines() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		List<PurchaseController.PurchaseLineWrapper> lines = new List<PurchaseController.PurchaseLineWrapper>();

		Test.startTest();
		Id purchaseId = PurchaseController.createPurchaseWithLines(acc.Id, lines);
		Test.stopTest();

		List<PurchaseLine__c> createdLines = [
				SELECT Id
				FROM PurchaseLine__c
				WHERE PurchaseId__c = :purchaseId
		];

		System.assertEquals(0, createdLines.size(), 'Purchase should not exist');
	}

	@isTest
	static void testCreatePurchaseWithNullClientId() {
		Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

		PurchaseController.PurchaseLineWrapper line = new PurchaseController.PurchaseLineWrapper();
		line.itemId = item.Id;
		line.amount = 1;
		line.unitCost = item.Price__c;

		Test.startTest();
		try {
			Id purchaseId = PurchaseController.createPurchaseWithLines(null, new List<PurchaseController.PurchaseLineWrapper>{line});
			System.assert(false, 'Expected exception for null clientId');
		} catch (Exception e) {
			System.assert(e.getMessage().contains('Script-thrown exception'), 'Wrong error message: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void testPurchaseLineWrapper() {
		PurchaseController.PurchaseLineWrapper wrapper = new PurchaseController.PurchaseLineWrapper();
		wrapper.itemId = '001000000000001';
		wrapper.amount = 5;
		wrapper.unitCost = 99.99;

		System.assertEquals('001000000000001', wrapper.itemId, 'Wrong itemId');
		System.assertEquals(5, wrapper.amount, 'Wrong amount');
		System.assertEquals(99.99, wrapper.unitCost, 'Wrong cost');
	}

	@isTest
	static void testNegativeAmount() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

		PurchaseController.PurchaseLineWrapper line = new PurchaseController.PurchaseLineWrapper();
		line.itemId = item.Id;
		line.amount = -1;
		line.unitCost = item.Price__c;

		Test.startTest();
		try {
			Id purchaseId = PurchaseController.createPurchaseWithLines(acc.Id, new List<PurchaseController.PurchaseLineWrapper>{line});
			System.assert(false, 'Expected exception for negative amount');
		} catch (Exception e) {
			System.assert(e.getMessage().contains('Script-thrown exception'), 'Wrong error message: ' + e.getMessage());
		}
		Test.stopTest();
	}
}