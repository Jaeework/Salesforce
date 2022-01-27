({
    myAction : function(cmp, event, helper) {
        cmp.set('v.isOpen', true);   
        console.log(cmp.getElements());
    },
    handleLoad : function(cmp, event, helper){
        var id  = cmp.get('v.recordId');
        var action = cmp.get('c.getProduct');
        action.setParams({recordId : id});
        action.setCallback(this, function(res){
            if(res.getState() === 'SUCCESS'){
                cmp.set('v.isEdit', true)
                cmp.set('v.product', res.getReturnValue());
            } else {
                //console.log(res.getError());
                cmp.set('v.isEdit', false);
            }
        });
        $A.enqueueAction(action);
    },
    handleSubmit : function(cmp, event, helper) {
        cmp.set('v.btnDisabled', true);
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    handleSuccess : function(cmp,event,helper) {
        var record = event.getParam("response");
        var apiName = record.apiName;
        var myRecordId = record.id;
        
        var navService = cmp.find("navService");        
        var pageReference = {
            "type": 'standard__recordPage',         
            "attributes": {              
                "recordId": myRecordId,
                "actionName": "view",               
                "objectApiName": apiName
            }        
        };
        
        cmp.set("v.pageReference", pageReference);
        
        var pageReference = cmp.get("v.pageReference");
        navService.navigate(pageReference);
        
    },
    handleError : function(cmp, event, helper){
        //console.log('got Error!!');
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        //alert('An error has occured. Check again or Contact Administrator.');
        cmp.set('v.btnDisabled', false);
    },
    close : function(cmp, event, helper){
        cmp.set('v.isOpen', false);
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "CustomProduct__c"
        });
        homeEvent.fire();
    }
    
})