global class WeatherBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts  {
    String weatherApiKey;
    String weatherEndpoint;
    String geoEndpoint;
    String airPollutionEndpoint;
    Datetime currentTime;
    Map<String, Map<String, Object>> cachedGeoData = new Map<String, Map<String, Object>>();
    Map<String, Map<String, Object>> cachedWeatherData = new Map<String, Map<String, Object>>();
    Map<String, Map<String, Object>> cachedAirData = new Map<String, Map<String, Object>>();
        

    global WeatherBatch() {
        WeatherApiSettings__c settings = WeatherApiSettings__c.getOrgDefaults();
        weatherApiKey = settings.API_Key__c;
        weatherEndpoint = settings.Weather_Endpoint__c;
        geoEndpoint = settings.Geo_Endpoint__c;
        airPollutionEndpoint = settings.AirPollution_Endpoint__c;
        currentTime = Datetime.now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        // Query all the contacts in the contact object
        String query = 'SELECT Id, Name, Email, Phone, MailingPostalCode, MailingLatitude, '
                     + ' MailingLongitude, MailingCity FROM Contact WHERE MailingPostalCode != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> TargetList){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        List<Contact> contactToUpdate = new List<Contact>();
            
        // Loop through each contact and add message and users to email list
        for (Contact contact : TargetList) {
            // Get the location of the contact
            String zipcode = contact.MailingPostalCode;
            
            Decimal lat = contact.MailingLatitude != null ? contact.MailingLatitude : null;
            Decimal lon = contact.MailingLongitude != null ? contact.MailingLongitude : null;
            String location = contact.MailingCity != null ? contact.MailingCity : '';
                
            
            // If there is no location information, get location from weather api and update
            if(lat == null || lon == null) {
                if(zipcode == null){continue;}

                Map<String, Object> geoData = getGeoData(zipcode);
                if(geoData == null) {continue;}

                lat = (Decimal)geoData.get('lat');
                lon = (Decimal)geoData.get('lon');
                location = (String)geoData.get('name');

                contact.MailingLatitude = lat;
                contact.MailingLongitude = lon;
                contact.MailingCity = location;

                contactToUpdate.add(contact);
            }

            Map<String, Object> weatherData = getWeatherData(zipcode, lat, lon);
            Map<String, Object> airData = getAirData(zipcode, lat, lon);

            sendWeatherEmail(contact, weatherData, airData, emails);
        }

        Messaging.sendEmail(emails);
        if(contactToUpdate.size() > 0) {
            update contactToUpdate;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
    }


    private Map<String, Object> getGeoData(String zipcode) {
        if(cachedGeoData.containsKey(zipcode)) {return cachedGeoData.get(zipcode);}

        HttpRequest request = new HttpRequest();
        request.setEndpoint(geoEndpoint.replace('{!postalCode}', zipcode).replace('{!API_Key__c}', weatherApiKey));
        request.setMethod('GET');
        HttpResponse response = new Http().send(request);
        Integer resStatus = response.getStatusCode();

        if(resStatus == 200) {
            Map<String, Object> geoResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            cachedGeoData.put(zipcode, geoResponse);

            return geoResponse;
        } else if(resStatus == 404) {
            System.debug('Location data not found for zipcode: ' + zipcode);
            return null; 
        } else {
            System.debug('zipcode call failed : ' + resStatus);
        }

        return null;
    }

    private Map<String, Object> getWeatherData(String zipcode, Decimal lat, Decimal lon) {
        if(cachedWeatherData.containsKey(zipcode)) {return cachedWeatherData.get(zipcode);}
        // Get the current weather and temperature
        HttpRequest request = new HttpRequest();
        request.setEndpoint(weatherEndpoint.replace('{!lat}', String.valueOf(lat)).replace('{!lon}', String.valueOf(lon)).replace('{!API_Key__c}', weatherApiKey));
        request.setMethod('GET');
        HttpResponse response = new Http().send(request);
        Integer resStatus = response.getStatusCode();

        if(resStatus == 200) {
            Map<String, Object> weatherResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            cachedWeatherData.put(zipcode, weatherResponse);
            return weatherResponse;
        } else {
            System.debug('weather call failed : ' + resStatus);
        }

        return null;
    }

    private Map<String, Object> getAirData(String zipcode, Decimal lat, Decimal lon) {
        if(cachedAirData.containsKey(zipcode)) {return cachedAirData.get(zipcode);}

            HttpRequest request = new HttpRequest();
            request.setEndpoint(airPollutionEndpoint.replace('{!lat}', String.valueOf(lat)).replace('{!lon}', String.valueOf(lon)).replace('{!API_Key__c}', weatherApiKey));
            request.setMethod('GET');
            HttpResponse response = new Http().send(request);
            Integer resStatus = response.getStatusCode();

            if(resStatus == 200) {
                Map<String, Object> airPollutionResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                cachedAirData.put(zipcode, airPollutionResponse);
                return airPollutionResponse;
            } else {
            System.debug('airPollution call failed : ' + resStatus);
        }

        return null;
    }

	private void sendWeatherEmail(Contact contact, Map<String,Object> weatherData, Map<String,Object> airData, List<Messaging.SingleEmailMessage> emails){
        String message = contact.Name + '님, 좋은 아침입니다! ';
        
        String weatherMessage = '오늘의 기상 정보를 가져올 수 없습니다. ';
        if(weatherData != null) {
            Map<String, Object> weather = (Map<String, Object>)((List<Object>)weatherData.get('weather'))[0];
            Map<String, Object> main = (Map<String, Object>)weatherData.get('main');
            String weatherDescription = (String)weather.get('description');
            Double currTemp = (Double)main.get('temp');
            String location = (String)weatherData.get('name');
                        
            weatherMessage = '오늘 ' + location + ' 기상 정보입니다. 날씨는 ' + weatherDescription + '(으)로 현재 기온은 ' 
                           + currTemp.format() + '도 입니다.\n';
        }        
        
        String fineDustMessage = '미세먼지 정보를 가져올 수 없습니다. ';
        if(airData != null) {
            Map<Integer, String> airQualName = new Map<Integer, String>{1 => '좋음', 2 => '양호', 3 => '보통', 4 => '나쁨', 5 => '매우 나쁨'};
                            
            Map<String, Object> finedustMap = (Map<String, Object>)((List<Object>)airData.get('list'))[0];
            Map<String, Object> finedustmain = (Map<String, Object>)finedustMap.get('main');
            Integer finedustIdx = (Integer)finedustmain.get('aqi');
            String airQuality = airQualName.get(finedustIdx);
                        
            Map<String, Object> finedustComp = (Map<String, Object>)finedustMap.get('components');
            Decimal fineDust = (Decimal)finedustComp.get('pm10');
                        
            fineDustMessage = '미세먼지 농도는 ' + fineDust + ' µg/m³으로 ' + airQuality + '입니다.';
        }        
                
        // Send Email to user
        message += weatherMessage + fineDustMessage;
                
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{contact.Email});
        email.setSubject('Daily Weather Notification - ' + currentTime.format('yyyy년 MM월 dd일'));
        email.setPlainTextBody(message);
        emails.add(email);
	} 
}
