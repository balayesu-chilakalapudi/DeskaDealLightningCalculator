({
    myAction: function (component, event, helper) {

    },
    handleSectionToggle: function (cmp, event) {

    },
    saveDealHandler: function (component, event, helper) {
        try{
        let saveevent=component.getEvent("saveAccountOpportunityEvent");
        saveevent.setParams({'accountObj':component.get("v.accountObj"),
        'opportunityObj':component.get("v.opportunityObj"),
        'save_or_cancel':'save'
    });
        saveevent.fire();
        }catch(err){
            console.log(err.stack);
        }
       /* var action = component.get("c.saveAccountOpportunityPopupData");
        action.setParams({
            'accountObj': JSON.stringify(component.get("v.accountObj")),
            'opportunityObj': JSON.stringify(component.get("v.opportunityObj"))
        });
        action.setCallback(this, function (a) {
            var state = response.getState();
            console.log('state:' + state);
            if (state === "SUCCESS") {
                let retval = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    type: 'success',
                    message: 'Data has been saved successfully'
                });
                toastEvent.fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/"+retval
                });
                urlEvent.fire();
            } else {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    message: errorMsg
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);*/
    },
    cancelDealHandler:function(component,event,helper){
        try{
            let saveevent=component.getEvent("saveAccountOpportunityEvent");
            saveevent.setParams({'accountObj':component.get("v.accountObj"),
            'opportunityObj':component.get("v.opportunityObj"),
            'save_or_cancel':'cancel'
        });
            saveevent.fire();
            }catch(err){
                console.log(err.stack);
            }
    }
})