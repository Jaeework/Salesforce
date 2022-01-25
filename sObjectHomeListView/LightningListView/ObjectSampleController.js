({
    doInit : function(cmp, event, helper) {
        helper.init(cmp);
    },
    combobox: function(cmp, event, helper) {
        // unrenders listView 
        cmp.set("v.bShowListView", false); 
        
        // get current selected listview Name 
        var lstViewName = event.getParam("value"); 
        
        // set new listName for listView
        cmp.set("v.currentListViewName", lstViewName);
        
        // rendere list view again with new listNew  
        cmp.set("v.bShowListView", true); 
    },
    
})