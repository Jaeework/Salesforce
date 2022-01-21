({
    
    doInit : function(cmp, event, helper) {
        helper.init(cmp);
    },
    handleNext : function(cmp, event, helper) { 
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber+1);
        
        var action = cmp.get("c.getAccounts");
        helper.setData(cmp, action);
    },
    handlePrev : function(cmp, event, helper) {        
        var pageNumber = cmp.get("v.pageNumber");
        cmp.set("v.pageNumber", pageNumber-1);
        
        var action = cmp.get("c.getAccounts");
        helper.setData(cmp, action);
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        cmp.set('v.recordId', row.Id);
        //alert('recordId : ' + cmp.get('v.recordId') );
        switch (action.name) {
            case 'edit':
                //alert('Edit: ' + JSON.stringify(row));
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id
                }); 
                editRecordEvent.fire();
                break;
            case 'delete':
                cmp.set('v.isDelete', true);
                break;
        }
    },
    createRecord : function (cmp, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Account"
        });
        createRecordEvent.fire();
    },
    handleCancel : function(cmp, event, helper){
        cmp.set("v.isDelete", false);
        cmp.set("v.isFields", false);
    },
    handleSelect : function(cmp, event, helpler) {
        var selectedRows = event.getParam("selectedRows");
        cmp.set("v.selectedAccs", selectedRows);
    },
    deleteAcc : function(cmp, event, helper) {
        var selectedAccs = cmp.get("v.selectedAccs");
        if(selectedAccs.length == 0){
            cmp.find('notifLib').showToast({
                "variant": "info",
                "title": "No Account Selected",
                "message": "Select Accounts to Delete"
            });
        } else {
            var action = cmp.get("c.deleteAccounts");
            action.setParams({seqs : selectedAccs});
            action.setCallback(this, function(res){
                $A.get("e.force:refreshView").fire();
                cmp.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Account Deleted",
                    "message": selectedAccs.length + " Accounts are deleted"
                });
            });
            $A.enqueueAction(action);
        }
        
    },
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        
        cmp.set("v.sortedBy", fieldName);
        if(fieldName === 'accUrl'){
            fieldName = 'Name';
        }
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    searchAccs : function(cmp, event, helper){
        var accName = cmp.get("v.accName");
        var action = cmp.get("c.searchAccount");
        action.setParams({
            searchKey : accName
        });
        helper.setData(cmp, action);
    },
    handleDelete : function(cmp, event, helper){
        //var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.deleteAccount");
        action.setParams({recordId : cmp.get("v.recordId")});
        action.setCallback(this, function(res){
            $A.get("e.force:refreshView").fire();
            cmp.find('notifLib').showToast({
                "variant": "success",
                "title": "Account Deleted",
                "message": cmp.get("v.recordId") + "Accounts are deleted"
            });
        });
        $A.enqueueAction(action);
    },
    handleChange: function(cmp, event, helper){
        var selectedOptionValue = event.getParam("value");
        var action;
        switch(selectedOptionValue){
            case "all_accounts":
                action = cmp.get("c.getAccounts");
                break;
            case "my_accounts":
                action = cmp.get("c.getMyAccounts");
                break;
            case "new_last_week":
                action = cmp.get("c.getLastWeekAccounts");
                break;
            case "new_this_week":
                action = cmp.get("c.getThisWeekAccounts");
                break;
            case "platinum_and_gold_sla_customers":
                action = cmp.get("c.getSlaAccounts");
                break;
            case "recently_viewed":
                action = cmp.get("c.getAllAccounts");
                break;                
        }
        helper.setData(cmp, action);
        
    }
    
})