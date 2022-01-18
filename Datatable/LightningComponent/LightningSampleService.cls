public with sharing class LightningSampleService {
    @AuraEnabled
    public static List<Account> fetchAccount(){
        return [SELECT Id, Name, Rating, Industry, Phone FROM Account ORDER BY Id DESC LIMIT 20];
    }
    
    @AuraEnabled
    public static void insertAccount(String accName, String phone){
        try{
            Account acct = new Account(Name=accName, Phone=phone);        
            insert acct;
                
            ID acctId = acct.Id;
            System.debug('Inserted Account ID = ' + acctId);
            

        } catch (DmlException e) {
    		System.debug('A DML exception has occurred: ' + e.getMessage());

		}
    }

}