({
    init: function(cmp, event, helper) {
      cmp.set("v.columns", [
        { label: "Account name", fieldName: "Name", type: "text" },
        { label: "Industry", fieldName: "Industry", type: "text" },
        { label: "Type", fieldName: "Rating", type: "text" },
        { label: "Phone", fieldName: "Phone", type: "phone" }
      ]);
  
      var action = cmp.get("c.fetchAccount");
      action.setCallback(this, function(res) {
        var state = res.getState();
        //alert(state);
        if (state === "SUCCESS") {
          var responseValue = res.getReturnValue();
          cmp.set("v.data", responseValue);
        }
      });
  
      $A.enqueueAction(action);
    },
    handleClick: function(cmp, event, helper) {
      //alert("you clicked!");
      var accName = cmp.get("v.AccName");
      var phone = cmp.get("v.Phone");
  
      var action = cmp.get("c.insertAccount");
      action.setParams({
        accName: accName,
        phone: phone
      });
      action.setCallback(this, function(res) {
        var state = res.getState();
        console.log('insert '+state);
        if (state === "SUCCESS") {
          //$A.get("e.force:refreshView").fire();
          var myaction = cmp.get("c.init");
          $A.enqueueAction(myaction);
  
        }
      });
      $A.enqueueAction(action);
    }
  });