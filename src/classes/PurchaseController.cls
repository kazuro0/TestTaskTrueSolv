public with sharing class PurchaseController {
	@AuraEnabled
	public static Id createPurchaseWithLines(Id clientId, List<PurchaseLineWrapper> lines) {
		if (clientId == null) {
			throw new AuraHandledException('Client ID cannot be null');
		}
		if (lines == null) {
			lines = new List<PurchaseLineWrapper>();
		}
		for (PurchaseLineWrapper line : lines) {
			if (line.amount < 0) {
				throw new AuraHandledException('Amount cannot be negative');
			}
			if (line.unitCost < 0) {
				throw new AuraHandledException('Unit cost cannot be negative');
			}
		}

		Purchase__c purchase = new Purchase__c(ClientId__c = clientId);
		insert purchase;

		List<PurchaseLine__c> purchaseLines = new List<PurchaseLine__c>();
		for (PurchaseLineWrapper line : lines) {
			purchaseLines.add(new PurchaseLine__c(
					PurchaseId__c = purchase.Id,
					ItemId__c = line.itemId,
					Amount__c = line.amount,
					UnitCost__c = line.unitCost
			));
		}
		insert purchaseLines;

		return purchase.Id;
	}

	public class PurchaseLineWrapper {
		@AuraEnabled public Id itemId {get; set;}
		@AuraEnabled public Integer amount {get; set;}
		@AuraEnabled public Decimal unitCost {get; set;}
	}
}
