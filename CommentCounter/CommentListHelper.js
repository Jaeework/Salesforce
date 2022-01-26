({
    init : function(cmp) {
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ]
        
        cmp.set('v.columns', [
            { label: 'Name', fieldName: 'userName', type: 'text' },
            { label: 'Comment', fieldName: 'CommentBody__c', type: 'text' },
            { label: 'Date', fieldName : 'LastModifiedDate', type: 'Date'},
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        var action = cmp.get('c.fetchComments');
        this.setData(cmp, action);
    },
    setData: function(cmp, action){
        var id = cmp.get('v.recordId')
        action.setParams({recordId : id});
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                var resVal = res.getReturnValue();
                //console.log(resVal);
                resVal.forEach(function(row){
                    //console.log(row.CreatedBy.Name);
                    row.userName = row.CreatedBy.Name;
                });
                cmp.set('v.data', resVal);
                this.countItem(cmp);
            } 
        });
        $A.enqueueAction(action);
    },
    deleteCmts : function(cmp){
        var action = cmp.get('c.deleteComments');
        var ids = cmp.get('v.selectedRows');
        //console.log('rows' + cmp.get('v.selectedRows'));
        
        action.setParams({cmtIdList : ids});
        action.setCallback(this, function(res){
            if(res.getState() === 'SUCCESS'){
                var myaction = cmp.get('c.fetchComments');
                this.setData(cmp, myaction);
            } else{
                console.log(res.getError());
            } 
        });
        $A.enqueueAction(action);
    }, deleteCmt: function(cmp, selectedId){
        var ids = [];
        ids.push(selectedId);
        var action = cmp.get('c.deleteComments');
        action.setParams({cmtIdList : ids});
        action.setCallback(this, function(res){
            if(res.getState() === 'SUCCESS'){
                var myaction = cmp.get('c.fetchComments');
                this.setData(cmp, myaction);
            } else{
                console.log(res.getError());
            } 
        });
        $A.enqueueAction(action);
        
    },
    countItem: function(cmp){
        var action = cmp.get('c.commentCounter');
        action.setParams({recordId : cmp.get('v.recordId')});
        action.setCallback(this, function(res){
            if(res.getState() === 'SUCCESS'){
                var cnt = res.getReturnValue();
                cmp.set('v.countItem', cnt);
            } else{
                console.log('cntItem : ' + res.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
    
})