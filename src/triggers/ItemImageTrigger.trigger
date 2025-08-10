trigger ItemImageTrigger on Item__c (after insert) {
	Set<Id> newItemIds = new Set<Id>();

	for (Item__c item : Trigger.new) {
		if (String.isBlank(item.Image__c)) {
			newItemIds.add(item.Id);
		}
	}

	if (!newItemIds.isEmpty()) {
		UnsplashService.updateItemImageAsync(newItemIds);
	}
}
