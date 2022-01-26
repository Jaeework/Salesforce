public class CommentService {
    
    @auraEnabled
    public static List<Comment__c> fetchComments(Id recordId){
        //System.debug('recordId : ' + recordId );
        List<Comment__c> cmts = [SELECT Id, CommentBody__c, CreatedBy.Name, CreatedDate, IsDeleted, Parent_ID__c, LastModifiedById, LastModifiedDate from Comment__c
                WHERE Parent_Id__c = :recordId and IsDeleted = false ORDER BY CreatedDate Desc];
        
        return cmts;
    }
    
    @auraEnabled
    public static void insertComment(String recordId, String commentBody){
        //System.debug('recordId : ' + recordId + 'commentBody : ' + commentBody);
        
        Comment__c cmt = new Comment__c(Parent_ID__c = recordId, CommentBody__c= commentBody);
        
        insert cmt;
    }
    
    @auraEnabled
    public static void deleteComments(List<Comment__c> cmtIdList){
        List<Comment__c> cmts = [SELECT Id FROM Comment__c WHERE Id IN :cmtIdList];
        
        delete cmts;
    }
    
    @auraEnabled
    public static Decimal commentCounter(Id recordId){
        Account acc = [SELECT Id, CommentCounter__c From Account WHERE Id = :recordId];
        if(acc.CommentCounter__c == null)
            acc.CommentCounter__c = 0;
        return acc.CommentCounter__c;
    }

}