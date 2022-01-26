({
    doInit : function(cmp, event, helper) {
        helper.init(cmp);
    },
    insertCmt: function(cmp, event, helper){
        cmp.set('v.isOpen', true);
    },
    insert : function(cmp, event, helper) {
        var comment = cmp.get("v.comment");
        //console.log('comment : ' + comment);
        
		var id = cmp.get("v.recordId");
       //console.log('id : ' + id);
        
        var action = cmp.get('c.insertComment');
        action.setParams({recordId : id, commentBody : comment});
        action.setCallback(this, function(res){
            console.log('state : ' + res.getState());
            if(res.getState() === 'SUCCESS'){
                var myaction = cmp.get('c.fetchComments');
        		helper.setData(cmp, myaction);
                cmp.set('v.comment', '');
                cmp.set('v.isOpen', false);
            } else{
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
	},
    close : function(cmp, event, helper){
    	cmp.set('v.isOpen', false);
        cmp.set('v.isDelte', false);
    	cmp.set('v.comment', '');
	},
    handleSelect: function(cmp, event, helper){
        var selectedRows = event.getParam("selectedRows");
        cmp.set("v.selectedRows", selectedRows);
    },
    deleteCmts: function(cmp, event, helper){
      helper.deleteCmts(cmp);
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'edit':
                //alert('Showing Details: ' + JSON.stringify(row));
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id
                }); 
                editRecordEvent.fire();

                break;
            case 'delete':
                helper.deleteCmt(cmp, row);
                break;
        }
    },
    handleToast: function(cmp, event, helper){
        var toastMsg = event.getParams();
        var msg = toastMsg.message;
        console.log(msg + " : msg");
        // Comment "CI-0028" was saved.
        if(msg.includes('was saved')){
           var action = cmp.get('c.fetchComments');
            helper.setData(cmp, action);
        }
        //$A.get('e.force:refreshView').fire();
    }
})