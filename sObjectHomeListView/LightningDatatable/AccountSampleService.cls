public class AccountSampleService {
    
    @auraEnabled
    public static List<Account> getAccounts(String pageSize, String pageNumber){
        Integer psize = Integer.valueOf(pageSize);
        Integer pnumber = Integer.valueOf(pageNumber)-1;
        
        return [SELECT Id, Name, Site, Phone, owner.Alias
                                  FROM Account ORDER BY Name Asc LIMIT :Integer.valueOf(psize) OFFSET :(psize*pnumber)];
    }
    
    @auraEnabled
    public static List<Account> getAllAccounts(){
        
        return [SELECT Id, Name, Site, Phone, owner.Alias FROM Account ORDER BY Name Asc];
    }
    
    @auraEnabled
    public static List<Account> getMyAccounts(){
        Id ownerId = UserInfo.getUserId();
        return [SELECT Id, Name, Site, Phone, owner.Alias FROM Account WHERE owner.Id = :ownerId ORDER BY Name Asc];
    }
    
    @auraEnabled
    public static List<Account> getLastWeekAccounts(){
        
        return [SELECT Id, Name, Site, Phone, owner.Alias FROM Account WHERE CreatedDate = LAST_WEEK ORDER BY Name Asc];
    }
    
    @auraEnabled
    public static List<Account> getThisWeekAccounts(){
        
        return [SELECT Id, Name, Site, Phone, owner.Alias FROM Account WHERE CreatedDate = THIS_WEEK ORDER BY Name Asc];
    }
    
    @auraEnabled
    public static List<Account> getSlaAccounts(){
        
        return [SELECT Id, Name, Site, Phone, SLA__c, owner.Alias FROM Account WHERE SLA__c IN ('Gold', 'Platinum') ORDER BY Name Asc];
    }
    
    
    @auraEnabled
    public static Account getAccount(String recordId){
        
        return [SELECT Id, Name, Site, Phone, owner.Alias FROM Account WHERE Id = :recordId ];
    }
    
    @auraEnabled
    public static void deleteAccounts(List<Account> seqs){
        List<Account> accts = [SELECT Id FROM Account WHERE Id IN :seqs];

        delete accts;
    }
    
    @auraEnabled
    public static void deleteAccount(String recordId){
        List<Account> accts = [SELECT Id FROM Account WHERE Id = :recordId];

        delete accts;
    }
    
    @auraEnabled
    public static List<Account> searchAccount(String searchKey){
        return [SELECT Id, Name, Site, Phone, owner.Alias FROM Account WHERE Name LIKE :'%' + searchKey + '%' ORDER BY Name Asc];
    }

}