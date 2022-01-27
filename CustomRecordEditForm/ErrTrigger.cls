trigger ErrTrigger on CustomProduct__c (before insert) {
// A trigger causing an error while inserting a CustomProduct__c record

    /*
    //An error occurs when the name of submitted record equals 'test'

    List<CustomProduct__c> testProduct;
    
    for(CustomProduct__c p: Trigger.New){
        if(p.Name == 'test'){
            p.addError('Use another name');
        }
    }
	*/


    //An error occurs when the name of submitted record already exists in database
	List<String> duplicateName = new List<String>();
    
    for(CustomProduct__c cp : Trigger.New){
        duplicateName.add(cp.Name);
    }
    
    List<CustomProduct__c> duplicateChk = [SELECT Id, Name FROM CustomProduct__c WHERE Name IN :duplicateName];
    
    /*
    if(!duplicateChk.isEmpty()){
        CalloutException e = new CalloutException();
        e.setMessage('test');
        throw e;
    }
	*/
    
    List<String> chkName = new List<String>();
    for(CustomProduct__c cp: duplicateChk){
        chkName.add(cp.Name);
    }

    if(Trigger.isInsert){
        for(CustomProduct__c cp : Trigger.New){
            if(chkName.contains(cp.Name)){
                //cp.addError(System.label.CP_ErrorCode_001);
                cp.addError('Duplicated Name. Insert Another Name.');
            }
        }
    }
    
    if(Trigger.isUpdate){
        for(CustomProduct__c cp : Trigger.New){
            if(trigger.newMap.get(cp.Id).name != trigger.oldMap.get(cp.Id).name){
                if(chkName.contains(cp.Name)){
                    //cp.addError(System.label.CP_ErrorCode_001);
                    cp.addError('Duplicated Name. Insert Another Name.');
                }
            }
            
        }
    }
	
}