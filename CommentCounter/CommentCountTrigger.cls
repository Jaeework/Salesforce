trigger CommentCountTrigger on Comment__c (after insert, before delete) {
//A trigger Updating CommentCounter Custom field in Account Object when inserting or deleting comments
	          
    List<Comment__c> loops = Trigger.isDelete ? Trigger.Old : Trigger.New;
   	Set<ID> idList = new Set<ID>();
    List<Account> acctsRes = new List<Account>();
    
    for(Comment__c c: loops){
            idList.add(c.Parent_ID__c);
    }
    
    List<Account> accts = [SELECT ID, CommentCounter__c,(SELECT Id FROM Comments__r WHERE Id IN :loops) FROM Account WHERE ID IN :idList];
    
    for(Account a : accts){
        if(a.CommentCounter__c == null){
            a.CommentCounter__c = 0;
        }
        
        Decimal cnt = Trigger.isDelete? (a.CommentCounter__c - a.Comments__r.size()) : (a.CommentCounter__c + a.Comments__r.size());
            //System.debug('cnt:' + cnt);
        a.Id = a.Id;
        a.CommentCounter__c = cnt;

        acctsRes.add(a);
    }
    
    update acctsRes;
}