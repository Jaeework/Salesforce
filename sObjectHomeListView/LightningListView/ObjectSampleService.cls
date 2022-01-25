public class ObjectSampleService {
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT id, Name, DeveloperName FROM ListView
                           WHERE sObjectType = 'Account' ORDER By Name ASC];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    @AuraEnabled
    public static ListView getListView() {
        ListView listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Account' and Name='All Accounts'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    /*apex method to fetch wrapper of list view*/ 
    @AuraEnabled
    public static list<listViewWrapper> listValues(){

        list<listViewWrapper> oListViewWrapper = new list<listViewWrapper>();

        for(ListView lv : [SELECT id, Name, DeveloperName FROM ListView
                           WHERE sObjectType = 'Account' ORDER By Name ASC]){ 
            listViewWrapper oWrapper = new listViewWrapper();
            oWrapper.label = lv.Name;
            oWrapper.developerName = lv.DeveloperName;
            oListViewWrapper.add(oWrapper);
        }
        
        return oListViewWrapper; 
    }

    /*wrapper class to store listView details*/ 
    public class listViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;} 
    }
}