({
    init: function(cmp){
        this.setListView(cmp);
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' },
            { label: 'Change Owner', name: 'change_owner' }
        ]
        cmp.set("v.columns",[
            {label : "Account Name", fieldName: "accUrl" , type: "url", typeAttributes: {label : {fieldName : 'Name'}}, sortable:"true"},
            {label : "Account Site", fieldName: "Site" , type: "text", sortable:"true" },
            {label : "Phone", fieldName: "Phone" , type: "text", sortable:"true" },
            {label : "Account Owner Alias", fieldName: "AccOwner" , type: "text", sortable:"true" },
            {type : "action", typeAttributes: {rowActions: actions}}
        ]);
        
        var action = cmp.get("c.getAccounts");
        this.setData(cmp, action);
    },
    setData: function(cmp, action){
        
        var pageSize = cmp.get("v.pageSize").toString();
        var pageNumber = cmp.get("v.pageNumber").toString();
        // set the parameters to method  
        action.setParams({
            'pageSize' : pageSize,
            'pageNumber' : pageNumber
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state === 'SUCCESS' || state === 'DRAFT'){
                var resValue = res.getReturnValue();
                
                if(resValue.length < cmp.get("v.pageSize")){
                    cmp.set("v.isLastPage", true);
                } else{
                    cmp.set("v.isLastPage", false);
                }
                cmp.set("v.dataSize", resValue.length);
                resValue.forEach(function(acc){
                    //this.getChatterCnt(cmp, acc.Id);
                    acc.AccOwner = acc.Owner.Alias;
                    acc.accUrl = '/' + acc.Id;
                    acc.Name = acc.Name;
                });
                cmp.set('v.data', resValue);
                cmp.set('v.cntItem', resValue.length);
            }
        });
        
        $A.enqueueAction(action);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        //console.log(reverse);
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    setListView: function(cmp){
        var options = [
            {value: 'all_accounts', label:'All Accounts'},  
            {value: 'my_accounts', label:'My Accounts'},
            {value: 'new_last_week', label:'New Last Week'},
            {value: 'new_this_week', label:'New This Week'},
            {value: 'platinum_and_gold_sla_customers', label:'Platinum and Gold SLA Customers'},
            {value: 'recently_viewed', label:'Recently Viewed'},
        ];
            cmp.set('v.options', options);
    },
        
})