public with sharing class UnsplashService {
	private static final String ACCESS_KEY = 'zrlrHXXEEM89xZPtQ_7hO0loP1pofkKRPYXtHzvQh_k';
	private static final String API_URL = 'https://api.unsplash.com/search/photos?page=1&per_page=1&query=';
	private static final Integer TIMEOUT_MS = 10000;

	@future(callout=true)
	public static void updateItemImageAsync(Set<Id> itemIds) {
		List<Item__c> itemsToUpdate = new List<Item__c>();

		for (Item__c item : [SELECT Id, Name, Image__c FROM Item__c WHERE Id IN :itemIds]) {
			if (String.isBlank(item.Image__c)) {
				String imageUrl = getImageUrlByQuery(item.Name);
				if (imageUrl != null) {
					item.Image__c = imageUrl;
					itemsToUpdate.add(item);
				}
			}
		}

		if (!itemsToUpdate.isEmpty()) {
			update itemsToUpdate;
		}
	}

	public static String getImageUrlByQuery(String query) {
		if (String.isBlank(query)) {
			System.debug('Query cannot be empty');
			return null;
		}

		try {
			HttpRequest request = new HttpRequest();
			request.setEndpoint(API_URL + EncodingUtil.urlEncode(query, 'UTF-8'));
			request.setMethod('GET');
			request.setHeader('Authorization', 'Client-ID ' + ACCESS_KEY);
			request.setTimeout(TIMEOUT_MS);

			HttpResponse response = new Http().send(request);
			System.debug('API Response Status: ' + response.getStatusCode());

			if (response.getStatusCode() == 200) {
				Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

				if (responseMap.containsKey('results') && responseMap.get('results') instanceof List<Object>) {
					List<Object> results = (List<Object>) responseMap.get('results');

					if (!results.isEmpty() && results.get(0) instanceof Map<String, Object>) {
						Map<String, Object> firstResult = (Map<String, Object>) results.get(0);

						if (firstResult.containsKey('urls') && firstResult.get('urls') instanceof Map<String, Object>) {
							Map<String, Object> urls = (Map<String, Object>) firstResult.get('urls');

							if (urls.containsKey('regular')) {
								String imageUrl = (String) urls.get('regular');
								System.debug('Found image URL: ' + imageUrl);
								return imageUrl;
							}
						}
					}
				}
			} else {
				System.debug('API request failed with status: ' + response.getStatusCode());
			}
		} catch (Exception e) {
			System.debug('Error in UnsplashService: ' + e.getMessage());
		}
		return null;
	}
}
