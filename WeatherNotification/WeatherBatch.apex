global class DailyWeatherBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts  {
    String weatherApiKey;
    Datetime currentTime;
        
    global DailyWeatherBatch(){
        // OpenWeatherMap API keys
        weatherApiKey = 'your_api_key';
        currentTime = Datetime.now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        // Query all the contacts in the contact object
        String query = 'SELECT Id, Name, Email, Phone, Zipcode__c, MailingLatitude, MailingLongitude, MailingCity FROM Contact WHERE Zipcode__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> TargetList){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
            List<Contact> contactToUpdate = new List<Contact>();
            
            // Loop through each contact and add message and users to email list
            for (Contact contact : TargetList) {
                // Get the location of the contact
                Decimal lat = contact.MailingLatitude != null ? contact.MailingLatitude : null;
                Decimal lon = contact.MailingLongitude != null ? contact.MailingLongitude : null;
                String location = contact.MailingCity != null ? contact.MailingCity : '';
                
                Http http;
                HttpRequest request;    
                HttpResponse response;
                String message = contact.Name + '님, 좋은 아침입니다! ';
                // If there is no location information, get location from weather api and update
                if(lat == null || lon == null) {
                    if(contact.Zipcode__c == null){continue;}
                    String zipcode = contact.Zipcode__c;
                    
                    http = new Http();
                    request = new HttpRequest();
                    request.setEndpoint('https://api.openweathermap.org/geo/1.0/zip?zip=' + zipcode + ',KR&appid=' + weatherApiKey);
                    request.setMethod('GET');
                    response = http.send(request);
                    Integer resStatus = response.getStatusCode();
                    if(resStatus == 200) {
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                        lat = (Decimal)responseMap.get('lat');
                        lon = (Decimal)responseMap.get('lon');
                        location = !String.isEmpty(location) && location == (String)responseMap.get('name') ? location : (String)responseMap.get('name');
                        
                        // Add to Contact list to update
                        contact.MailingLatitude = lat;
                        contact.MailingLongitude = lon;
                        contact.MailingCity = location;
                        contactToUpdate.add(contact);
                    } else {
                        System.debug(contact.Name + ' zipcode call failed : ' + resStatus);
                        continue;
                    }
                }
                
                // Get the current weather and temperature
                http = new Http();
                request = new HttpRequest();
                request.setEndpoint('https://api.openweathermap.org/data/2.5/weather?lat=' + lat +'&lon=' + lon +'&appid=' + weatherApiKey + '&units=metric&lang=kr');
                request.setMethod('GET');
                response = http.send(request);
                
                String weatherMessage = '오늘의 기상 정보를 가져올 수 없습니다. ';
                if(response.getStatusCode() == 200) {
                    Map<String, Object> weatherResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> weather = (Map<String, Object>)((List<Object>)weatherResponse.get('weather'))[0];
                    Map<String, Object> main = (Map<String, Object>)weatherResponse.get('main');
                    String weatherDescription = (String)weather.get('description');
                    Double currTemp = (Double)main.get('temp');	// 현재 기온
                    location = !String.isEmpty(location) && location == (String)weatherResponse.get('name') ? location : (String)weatherResponse.get('name');
                    
                    weatherMessage = '오늘 ' + location + ' 기상 정보입니다. 날씨는 ' + weatherDescription + '(으)로 현재 기온은 ' + currTemp.format() + '도 입니다.\n';
                }
                
                // Get the current fine dust concentration level
                http = new Http();
                request = new HttpRequest();
                request.setEndpoint('https://api.openweathermap.org/data/2.5/air_pollution?lat=' + lat + '&lon=' + lon + '&appid=' + weatherApiKey);
                request.setMethod('GET');
                response = http.send(request);
                String fineDustMessage = '미세먼지 정보를 가져올 수 없습니다. ';
                
                if(response.getStatusCode() == 200) {
                    Map<String, Object> airPollutionResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    Map<Integer, String> airQualName = new Map<Integer, String>{1 => '좋음', 2 => '양호', 3 => '보통', 4 => '나쁨', 5 => '매우 나쁨'};
                        
                    Map<String, Object> finedustMap = (Map<String, Object>)((List<Object>)airPollutionResponse.get('list'))[0];
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
                email.setSubject('Daily Weather Alert - ' + currentTime.format('yyyy년 MM월 dd일'));
                email.setPlainTextBody(message);
                emails.add(email);
            }
            Messaging.sendEmail(emails);
            if(contactToUpdate.size() > 0) {
                update contactToUpdate;
            }
        
    }
    
    global void finish(Database.BatchableContext bc){
    }
	
}
