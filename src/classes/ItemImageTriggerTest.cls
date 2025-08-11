@isTest
public class ItemImageTriggerTest {
	@isTest
	static void testTriggerWithMock() {
		Test.setMock(HttpCalloutMock.class, new UnsplashServiceTest.MockHttpResponse());

		Test.startTest();
		Item__c item = new Item__c(
				Name = 'Test Camera',
				Type__c = 'Electronics',
				Family__c = 'Home'
		);
		insert item;
		Test.stopTest();

		Item__c updatedItem = [SELECT Image__c FROM Item__c WHERE Id = :item.Id];
		System.assertEquals('https://test.com/image.jpg', updatedItem.Image__c);
	}
}