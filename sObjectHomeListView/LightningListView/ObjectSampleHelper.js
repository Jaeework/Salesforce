({
    init : function(cmp){
        var items = [];
        var action = cmp.get("c.listValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listViewResult = response.getReturnValue();
                if(listViewResult.length > 0){
                    listViewResult.forEach(function(listView){
                        var item = {
                            "label" : listView.label,
                            "value" : listView.developerName
                        };
                        items.push(item);
                    });
                    cmp.set("v.options", items);
                    var currentListView = listViewResult[0].developerName;
                    cmp.find('selectItem').set('v.value', currentListView);
                    
                    // set first value as default value
                    cmp.set("v.currentListViewName", currentListView);
                    // rendere list view on cmp
                    cmp.set("v.bShowListView", true);     
                }            
            }
        });
        $A.enqueueAction(action);
        
    }
    
    
})