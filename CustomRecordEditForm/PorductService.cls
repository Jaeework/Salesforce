public class ProductService {

	@auraEnabled
    public static CustomProduct__c getProduct(Id recordId){
        return [SELECT Id, Name FROM CustomProduct__c WHERE Id = :recordId];
    }
    
    @auraEnabled
    public static List<CustomProduct__c> duplicateChk(String recordName){
                
        return [SELECT Id, Name FROM CustomProduct__c WHERE Name LIKE :recordName];
    }
    
}