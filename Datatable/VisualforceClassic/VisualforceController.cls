public with sharing class VisualforceController {

    List<Account> accounts;

    public VisualforceController(ApexPages.StandardSetController acon) { }
    
    public List<Account> getAccounts(){
        if(accounts == null){
        accounts = [SELECT name, industry, type, phone FROM account LIMIT 20];
        }
        return accounts;
    }    
}