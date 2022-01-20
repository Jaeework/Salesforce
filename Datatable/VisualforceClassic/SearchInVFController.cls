public class SearchInVFController {
    
    public List<Account> acc {get;set;}
    public String searchKey {get;set;}
    public SearchInVFController(ApexPages.StandardSetController acon){}
    public void search(){
	String searchquery='select Name,industry, type, phone from account where name like \'%'+searchKey+'%\' Limit 10';
        acc = [SELECT Name, industry, type, phone FROM Account WHERE Name like :'%' + searchKey + '%' ORDER BY LastModifiedDate DESC LIMIT 10];
        
        //acc= Database.query(searchquery);
    }
    
    public void clear(){
        acc.clear();
    }

}