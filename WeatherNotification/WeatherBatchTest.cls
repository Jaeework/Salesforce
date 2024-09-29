@isTest
class WeatherBatchTest {
    
    @testSetup
    static void setupTestData() {
        // test Contacts
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Test', LastName = 'Contact01', Email = 'test01@example.com', MailingPostalCode = '12345'),
            new Contact(FirstName = 'Test', LastName = 'Contact02', Email = 'test02@example.com', MailingPostalCode = '54321')
    	};
    	insert contacts;
        
        // Setup Custom Settings with API keys and endpoints
        WeatherApiSettings__c settings = new WeatherApiSettings__c();
        settings.Name = 'test';
        settings.API_Key__c = 'test-api-key';
        settings.Geo_Endpoint__c = 'https://api.openweathermap.org/geo/1.0/zip?zip={!postalCode}&appid={!API_Key__c}';
        settings.Weather_Endpoint__c = 'https://api.openweathermap.org/data/2.5/weather?lat={!lat}&lon={!lon}&appid={!API_Key__c}';
        settings.AirPollution_Endpoint__c = 'https://api.openweathermap.org/data/2.5/air_pollution?lat={!lat}&lon={!lon}&appid={!API_Key__c}';
        insert settings;
    }
    
    @isTest
    static void testContactGeoDataUpdate() {
        // Validate that Contacts are updated with geo data
        
        Test.startTest();
        
        // Mock response for Geo API
        Test.setMock(HttpCalloutMock.class, new WeatherBatchHttpMock());
        
        // Run batch
        WeatherBatch batch = new WeatherBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        // Validate that Contacts are updated with geo data
        List<Contact> updatedContacts = [SELECT MailingLatitude, MailingLongitude, MailingCity FROM Contact WHERE MailingPostalCode != null];
        System.assert(updatedContacts.size() > 0, 'All contacts should be updated');
        for (Contact c : updatedContacts) {
            System.assertNotEquals(null, c.MailingLatitude, 'Latitude should not be null.');
            System.assertNotEquals(null, c.MailingLongitude, 'Longitude should not be null.');
            System.assertNotEquals(null, c.MailingCity, 'City should be updated.');
        }
    }
    
    @isTest
    static void testEmailSending() {
        // Test if emails are sent correctly
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new WeatherBatchHttpMock());
        
        // Run Batch
        WeatherBatch batch = new WeatherBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        // Validate that two emails were sent
        List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage];
        System.assertEquals(2, sentEmails.size(), 'Two emails should have been sent.');
    }
    
    // Set Mock HTTP responses
    private class WeatherBatchHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            if (req.getEndpoint().contains('geo/1.0/zip')) {
                // Mock response for Geo API
                res.setBody('{"lat": 37.5665, "lon": 126.9780, "name": "Seoul"}');
            } else if (req.getEndpoint().contains('data/2.5/weather')) {
                // Mock response for Weather API
                res.setBody('{"weather": [{"description": "clear sky"}], "main": {"temp": 20.0}, "name": "Seoul"}');
            } else if (req.getEndpoint().contains('data/2.5/air_pollution')) {
                // Mock response for Air Pollution API
                res.setBody('{"list": [{"main": {"aqi": 1}, "components": {"pm10": 10.0}}]}');
            }
            
            return res;
        }
    }
    
}
