@isTest
public class ItemControllerTest {
	@testSetup
	static void setup() {
		List<Item__c> items = new List<Item__c>{
			// Electronics
			new Item__c(Name='Laptop', Type__c='Electronics', Family__c='Home', Price__c=1000),
			new Item__c(Name='Monitor', Type__c='Electronics', Family__c='Office', Price__c=500),
			new Item__c(Name='Drone', Type__c='Electronics', Family__c='Outdoor', Price__c=800),

			// Clothing
			new Item__c(Name='T-Shirt', Type__c='Clothing', Family__c='Home', Price__c=25),
			new Item__c(Name='Suit', Type__c='Clothing', Family__c='Office', Price__c=200),
			new Item__c(Name='Jacket', Type__c='Clothing', Family__c='Outdoor', Price__c=150),

			// Food
			new Item__c(Name='Microwave', Type__c='Food', Family__c='Home', Price__c=80),
			new Item__c(Name='Coffee', Type__c='Food', Family__c='Office', Price__c=15),
			new Item__c(Name='Grill', Type__c='Food', Family__c='Outdoor', Price__c=300)
			};
		insert items;
	}

	@isTest
	static void testGetItemsReturnsAllTypesAndFamilies() {
		Test.startTest();
		List<Item__c> items = ItemController.getItems();
		Test.stopTest();

		System.assertEquals(9, items.size(), 'Should return all 9 test items');

		Set<String> types = new Set<String>();
		Set<String> families = new Set<String>();
		for(Item__c item : items) {
			types.add(item.Type__c);
			families.add(item.Family__c);
		}

		System.assert(types.contains('Electronics'), 'Should contain Electronics');
		System.assert(types.contains('Clothing'), 'Should contain Clothing');
		System.assert(types.contains('Food'), 'Should contain Food');

		System.assert(families.contains('Home'), 'Should contain Home');
		System.assert(families.contains('Office'), 'Should contain Office');
		System.assert(families.contains('Outdoor'), 'Should contain Outdoor');
	}
}