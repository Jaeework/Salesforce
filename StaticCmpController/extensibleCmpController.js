({
    load : function(cmp, event, helper){
        var id = cmp.get('v.recordId');

        helper.invokeClass(cmp, 'editRecord', {
            recordId : id
        }).then(function(r){
            console.log('state : ', r);
            cmp.set('v.isEdit', true);
            helper.showToast(cmp, 'success', 'record Edit Form');
            var data = r;
            cmp.set('v.data', data);
        }).catch(function(e){
            console.log('error : ', e);
            cmp.set('v.isEdit', false);
            helper.showToast(cmp, 'error', 'record Create Form');
        });
    }

})