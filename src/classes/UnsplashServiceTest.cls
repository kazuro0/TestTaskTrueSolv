@isTest
public class UnsplashServiceTest {
	public class MockHttpResponse implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest request) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"results":[{"urls":{"regular":"https://test.com/image.jpg"}}]}');
			res.setStatusCode(200);
			return res;
		}
	}

	@isTest
	static void testGetImageUrlByQuery() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

		Test.startTest();
		String imageUrl = UnsplashService.getImageUrlByQuery('test');
		Test.stopTest();

		System.assertEquals('https://test.com/image.jpg', imageUrl);
	}

	@isTest
	static void testUpdateItemImageAsync() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

		Item__c item = new Item__c(Name='Test Item');
		insert item;

		Test.startTest();
		UnsplashService.updateItemImageAsync(new Set<Id>{item.Id});
		Test.stopTest();

		Item__c updatedItem = [SELECT Image__c FROM Item__c WHERE Id = :item.Id];
		System.assertNotEquals(null, updatedItem.Image__c);
	}
}