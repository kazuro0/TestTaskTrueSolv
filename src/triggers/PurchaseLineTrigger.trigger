trigger PurchaseLineTrigger on PurchaseLine__c (after insert, after update, after delete, after undelete) {
	Set<Id> purchaseIds = new Set<Id>();

	if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
		for (PurchaseLine__c pl : Trigger.new) {
			if (pl.PurchaseId__c != null) {
				purchaseIds.add(pl.PurchaseId__c);
			}
		}
	}
	if (Trigger.isDelete) {
		for (PurchaseLine__c pl : Trigger.old) {
			if (pl.PurchaseId__c != null) {
				purchaseIds.add(pl.PurchaseId__c);
			}
		}
	}

	if (!purchaseIds.isEmpty()) {
		List<Purchase__c> purchasesToUpdate = new List<Purchase__c>();

		Map<Id, Decimal> totalAmounts = new Map<Id, Decimal>();
		for (AggregateResult ar : [
				SELECT PurchaseId__c, SUM(Amount__c) totalAmount
				FROM PurchaseLine__c
				WHERE PurchaseId__c IN :purchaseIds
				GROUP BY PurchaseId__c
		]) {
			totalAmounts.put((Id)ar.get('PurchaseId__c'), (Decimal)ar.get('totalAmount'));
		}

		List<PurchaseLine__c> lines = [
				SELECT PurchaseId__c, Amount__c, UnitCost__c
				FROM PurchaseLine__c
				WHERE PurchaseId__c IN :purchaseIds
		];

		Map<Id, Decimal> grandTotals = new Map<Id, Decimal>();
		for (PurchaseLine__c line : lines) {
			Decimal sum = grandTotals.containsKey(line.PurchaseId__c) ? grandTotals.get(line.PurchaseId__c) : 0;
			sum += (line.Amount__c != null ? line.Amount__c : 0) * (line.UnitCost__c != null ? line.UnitCost__c : 0);
			grandTotals.put(line.PurchaseId__c, sum);
		}

		for (Id purchaseId : purchaseIds) {
			purchasesToUpdate.add(new Purchase__c(
					Id = purchaseId,
					TotalItems__c = totalAmounts.containsKey(purchaseId) ? Integer.valueOf(totalAmounts.get(purchaseId)) : 0,
					GrandTotal__c = grandTotals.containsKey(purchaseId) ? grandTotals.get(purchaseId) : 0
			));
		}

		update purchasesToUpdate;
	}
}