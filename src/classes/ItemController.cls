public with sharing class ItemController {
	@AuraEnabled(cacheable=true)
	public static List<Item__c> getItems() {
		return [
				SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c
				FROM Item__c
				ORDER BY CreatedDate DESC
		];
	}

	@AuraEnabled
	public static void deleteItem(Id itemId) {
		delete [
				SELECT Id
				FROM Item__c
				WHERE Id = :itemId
		];
	}
}