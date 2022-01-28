({
    invokeClass : function(cmp, apexAction, params){
        var p = new Promise($A.getCallback(this, function(resolve, reject){
            var action = cmp.get('c.' + apexAction + '');
            
            if(params) action.setParams(params);
            action.setCallback(this, function(res){
                if(res.getState() === 'SUCCESS'){
                    resolve(res.getReturnValue());
                }
                if(res.getState() === 'ERROR'){
                    console.log('erorr : ', res.getError());
                    reject(res.getError());
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
    },

    showToast : function(cmp, title, msg){
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title' : title,
            'message' : msg,
            'type' : title === 'success' ? 'success' : 'error'
        });
        
        toastEvent.fire();
    }
})