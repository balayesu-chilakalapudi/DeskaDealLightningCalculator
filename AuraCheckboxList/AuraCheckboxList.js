({
    doinit: function (component, event, helper) {
        component.set("v.cardTitle", 'Client Search');
        component.set("v.cardIcon", 'standard:search');
        console.log('doinit');
        // $A.util.toggleClass(component.find("calculator"), "slds-hide");

        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

    },
    clientSearch: function (component, event, helper) {
        component.set("v.searchResult", '');
        console.log('clientSearch');
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        var action = component.get("c.doClientSearch");
        action.setParams({
            'firstname': component.get("v.searchFirstName"),
            'lastname': component.get("v.searchLastName"),
            'phone': component.get("v.searchPhone")
        });
        action.setCallback(this, function (a) {

            var response = JSON.parse(a.getReturnValue());
            console.log('response:' + JSON.stringify(response));
            component.set("v.searchResult", response.html);
            component.set("v.foundLeadID", response.leadID);
            component.set("v.leadCount", response.leadCount);
            component.set("v.accCount", response.accCount);
            component.set("v.previousContracts", response.previousContracts);
            component.set("v.accountObj.Id", response.accID);

            if (response.firstName != null) {
                component.set('v.searchFirstName', component.get("v.searchFirstName"));
            }
            if (response.firstName != null) {
                component.set('v.searchLastName', component.get("v.searchLastName"));
            }
            if (response.accCount != 0) {
                component.set("v.approvalRequired", true);
            }

            component.set("v.showCalc", true);
            component.set("v.showSearch", false);

            component.set("v.calcForm", true);

            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
        //        $A.util.toggleClass(component.find("searchclient"), "slds-hide");
        $A.util.removeClass(component.find("calculator"), "slds-hide");

        component.set("v.cardTitle", 'Desk a Deal');
        component.set("v.cardIcon", 'standard:budget');



    },

    prevcontractselected: function (component, event, helper) {        
       // let prev_contract_id = document.querySelector('input[name="prev"]:checked').id;
        let ischecked=event.target.checked;
        let prevId=event.target.id;
      //  console.log('prev_contract_id:' + prev_contract_id);
        console.log('prevId:'+prevId);
        console.log('ischecked:'+ischecked);
        let prev_contract = {};
        let prevcontractlist = component.get("v.previousContracts");
        if (prevId != undefined && ischecked) {
            for (let x of prevcontractlist) {
                if (x.Id == prevId) {
                    prev_contract = x;
                    break;
                }
            }
            component.find("prevContractAmt").set("v.value", prev_contract.Remaining_Balance__c);
                    let inputs = document.querySelectorAll("input[type=checkbox]")
            inputs.forEach(item => {
                if(item.id!=prevId){
            item.checked = false
                }
            });
        } else {
            component.find("prevContractAmt").set("v.value", 0);
        }
    },
    getEMIDetail: function (component, event, helper) {
        let duedate = component.find('duedate').get("v.value");
        console.log('duedate:' + duedate);
        if (duedate != null && duedate != undefined && duedate != '') {
            helper.getEMI(component, "EMI");
            if (component.get("v.leadCount") != 0) {
                component.set("v.showStart", false);
                component.set("v.showEdit", true);

            } else {
                component.set("v.showStart", true);
                component.set("v.showEdit", false);
            }

            component.set("v.showCalc", false);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Due Date Missing!",
                "message": "Please Select Due Date",
                "type": "warning"
            });
            toastEvent.fire();
        }
    },
    reset: function (component, event, helper) {
        $A.util.removeClass(component.find("searchclient"), "slds-hide");
        component.set("v.searchResult", '');
        component.set("v.searchFirstName", '');
        component.set("v.searchLastName", '');
        component.set("v.searchPhone", '');
        component.set('v.notSubmitted', false);
        component.set("v.showCalc", true);
        component.set("v.showSearch", true);
        component.set("v.calcForm", false);
        component.set("v.showStart", false);
        component.set("v.approvalRequired", false);
        component.set("v.isInPermissionSet", false);
        var frequency = component.get("v.frequency");

        component.find("loanAmt").set("v.value", "");
        component.find("months").set("v.value", "");
        component.find("rate").set("v.value", "");

        /* document.getElementById('loanAmt').value="";
        document.getElementById('months').value="";
        document.getElementById('rate').value="";*/
        document.getElementById('DPyment').value = "";


    },
    back: function (component, event, helper) {
        component.set('v.notSubmitted', false);
        component.set("v.showCalc", true);
        component.set("v.showSearch", true);
        //component.set("v.calcForm", false );
        component.set("v.showStart", false);
        component.set("v.showEdit", false);
        component.set("v.approvalRequired", false);
        var frequency = component.get("v.frequency");
        document.getElementById('loanAmt').value = "";
        document.getElementById('months').value = "";
        document.getElementById('rate').value = "";
        document.getElementById('DPyment').value = "";
    },
    dealStart: function (component, event, helper) {
        var evt = $A.get("e.force:createRecord");
        evt.setParams({
            'entityApiName': 'Lead',
            'recordTypeId': component.get("v.lead_bonanza_recordtype_Id"),
            'defaultFieldValues': {
                'FirstName': component.get('v.searchFirstName'),
                'LastName': component.get('v.searchLastName'),
                'Email': component.get('v.searchEmail'),
                'Term__c': component.get('v.Term'),
                'APR__c': component.get('v.ARP'),
                'Total_Amount_Financed__c': component.get('v.financed'),
                'Interest_Amount__c': component.get('v.IPaid'),
                'EMI__c': component.get('v.Emi'),
                'Payment_Frequency__c': component.find('frequency').get("v.value"),
                'Approval_Required__c': component.get('v.approvalRequired'),
                'recordTypeId': component.get("v.lead_bonanza_recordtype_Id")
            }
        });
        // evt.fire();
        // $A.get("e.force:closeQuickAction").fire();
        // $A.enqueueAction(action);
        component.set("v.showStoreQuestion", true);
    },
    closeModal: function (component, event, helper) {
        component.set("v.showStoreQuestion", false);
        component.set("v.hideFooter", false);
        component.set("v.showEditPage", false);
        component.set("v.showOpportunityTab", false);
        if (component.get("v.searchMsg") != "Are we in store") {
            component.set("v.searchMsg", "Are we in store");
            $A.util.removeClass(component.find("searchclient"), "slds-hide");
            component.set("v.searchResult", '');
            component.set("v.searchFirstName", '');
            component.set("v.searchLastName", '');
            component.set("v.searchPhone", '');
            component.set('v.notSubmitted', false);
            component.set("v.showCalc", true);
            component.set("v.showSearch", true);
            component.set("v.calcForm", false);
            component.set("v.showStart", false);
            component.set("v.approvalRequired", false);
            component.set("v.isInPermissionSet", false);
            var frequency = component.get("v.frequency");
            document.getElementById('loanAmt').value = "";
            document.getElementById('months').value = "";
            document.getElementById('rate').value = "";
            document.getElementById('DPyment').value = "";
        }
    },
    dealEdit: function (component, event, helper) {

        var action = component.get("c.updateLead");
        action.setParams({
            'leadID': component.get("v.foundLeadID"),
            'loanAmount': document.getElementById('loanAmt').value,
            'term': document.getElementById('months').value,
            'totalInterest': component.get("v.IPaid"),
            'APR': component.get("v.ARP"),
            'monthlyEMI': component.get("v.Emi"),
        });
        action.setCallback(this, function (a) {

            var response = JSON.parse(a.getReturnValue());

            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");

        });
        $A.enqueueAction(action);

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + component.get("v.foundLeadID")
        });
        urlEvent.fire();

    },
    searchStore: function (component, event, helper) {
        console.log('duedate:' + component.find('duedate').get("v.value"));
        if (component.find('duedate').get("v.value") != null) {
            console.log('searchStore Running');
            console.log('v.Ipaid' + component.get("v.IPaid"));
            console.log('v.Emi:' + component.get("v.Emi"));
            try {
                var spinner = component.find("modelSpinner");
                $A.util.toggleClass(spinner, "slds-hide");

                //this is the action, creating account and opportunity
                let params = {
                    'isInPermissionSet': component.get("v.isInPermissionSet"),
                    'firstname': component.get("v.searchFirstName"),
                    'lastname': component.get("v.searchLastName"),
                    'phone': component.get("v.searchPhone"),
                    'frequency': component.find('frequency').get("v.value"),
                    'loanAmt': component.find('loanAmt').get("v.value"),
                    'Fees': component.find('Fees').get("v.value"),
                    'months': component.find('months').get("v.value"),
                    'rate': component.find('rate').get("v.value"),
                    'IPaid': component.get("v.IPaid"),
                    'Emi': component.get("v.Emi"),
                    'duedate': component.find('duedate').get("v.value"),
                    'prevContractAmt': component.find('prevContractAmt').get("v.value"),
                    'ThirdPartyPmt': component.find('ThirdPartyPmt').get("v.value")
                };
                console.log('params:' + JSON.stringify(params));

                let accountObj = component.get("v.accountObj");
                accountObj.Name = params.firstname + ' ' + params.lastname;
                accountObj.Phone = params.phone;
                component.set("v.accountObj", accountObj);

                let opportunityObj = component.get("v.opportunityObj");
                opportunityObj.Previous_Contract_Amount__c = params.prevContractAmt;
                opportunityObj.Third_Party_Payment__c = params.ThirdPartyPmt;
                opportunityObj.First_Name__c = params.firstname;
                opportunityObj.Last_Name__c = params.lastname;
                opportunityObj.Name = params.firstname + ' ' + params.lastname;
                //'Deal Desk Opportunity For '+accountObj.Name;
                opportunityObj.Payment_Frequency__c = params.frequency;
                opportunityObj.Monthly_Payment__c = params.frequency;
                opportunityObj.Laon_Amount_Requested__c = params.loanAmt;
                opportunityObj.Fees__c = params.Fees;
                opportunityObj.Loan_Tenure_Months__c = params.months;
                opportunityObj.Interest_Rate__c = params.rate;
                opportunityObj.Due_Date__c = params.duedate;
                let emi_val = params.Emi;
                if (emi_val.includes('$')) {
                    emi_val = emi_val.replace('$', '');
                }
                opportunityObj.EMI_Amount__c = emi_val;
                let ipaid_val = params.IPaid;
                if (ipaid_val.includes('$')) {
                    ipaid_val = ipaid_val.replace('$', '');
                }
                opportunityObj.Interest_Paid__c = 0;
                opportunityObj.Total_Due__c = parseFloat(emi_val) * parseInt(params.months);
                opportunityObj.Phone_Number__c = params.phone;
                console.log('opportunityObj:' + JSON.stringify(opportunityObj));
                console.log('accountObj:' + JSON.stringify(accountObj));
                component.set("v.opportunityObj", opportunityObj);
                component.set("v.showEditPage", true);
                component.set("v.hideFooter", true);
                component.set("v.isError", false);


                //var action = component.get("c.searchStoreLead");
                /*action.setParams(
                    let params={
                    'isInPermissionSet': component.get("v.isInPermissionSet"),
                    'firstname': component.get("v.searchFirstName"),
                    'lastname': component.get("v.searchLastName"),
                    'phone': component.get("v.searchPhone"),
                    'frequency':component.find('frequency').get("v.value"),
                    'loanAmt':component.find('loanAmt').get("v.value"),
                    'Fees':component.find('Fees').get("v.value"),
                    'months':component.find('months').get("v.value"),
                    'rate':component.find('rate').get("v.value"),
                    'IPaid':component.get("v.IPaid"),
                    'Emi':component.get("v.Emi"),
                    'duedate':component.find('duedate').get("v.value")
                };*/
                //);
                /* action.setCallback(this, function(a) {
                     
                     var response = a.getReturnValue();
                     component.set("v.showEditPage",true);
                     component.set("v.searchResultObject",response);
                     component.set("v.hideFooter", true );
                     component.set("v.searchMsg", response.msg );
                     component.set("v.accountMode", response.accountMode );
                     component.set("v.opportunityMode", response.opportunityMode );
                     component.set("v.isInPermissionSet", response.isInPermissionSet );
             
                     if(response.msg != null){
                         component.set("v.isError", true );
                         //component.set("v.accountMode", "readonly" );
                         //component.set("v.opportunityMode", "readonly" );
                     }else{
                         component.set("v.isError", false );
                     }
                     var spinner = component.find("modelSpinner");
                     $A.util.toggleClass(spinner, "slds-hide");
                 });
                 $A.enqueueAction(action);*/
            } catch (err) {
                console.log(err.stack);
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Due Date Missing!",
                "message": "Please Select Due Date",
                "type": "warning"
            });
            toastEvent.fire();
        }
    },
    handleSuccess: function (component, event, helper) {
        component.set("v.showOpportunityTab", true);
        component.find("tabs").set("v.selectedTabId", "two");
    },
    searchStoreNo: function (component, event, helper) {
        console.log('IPaid:' + helper.getDecimal(component.get('v.IPaid')));
        console.log('Emi:' + helper.getDecimal(component.get('v.Emi')));
        console.log('Total Due:' + (helper.getDecimal(component.find('loanAmt').get("v.value")) + helper.getDecimal(component.get('v.IPaid'))));

        if (component.get("v.leadCount") != 0) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/" + component.get("v.foundLeadID")
            });
            urlEvent.fire();
        } else {
            var evt = $A.get("e.force:createRecord");
            evt.setParams({
                'entityApiName': 'Lead',
                'recordTypeId': component.get("v.lead_bonanza_recordtype_Id"),
                'defaultFieldValues': {
                    'FirstName': component.get('v.searchFirstName'),
                    'LastName': component.get('v.searchLastName'),
                    'Email': component.get('v.searchEmail'),
                    'Term__c': component.get('v.Term'),
                    'APR__c': component.get('v.ARP'),
                    'Total_Amount_Financed__c': component.get('v.financed'),
                    'Interest_Amount__c': component.get('v.IPaid'),
                    'EMI__c': component.get('v.Emi'),
                    'Payment_Frequency__c': component.find('frequency').get("v.value"),
                    'Approval_Required__c': component.get('v.approvalRequired'),
                    'Loan_Amount_Requested__c': helper.getDecimal(component.find('loanAmt').get("v.value")),
                    'Fees__c': helper.getDecimal(component.find('Fees').get("v.value")),
                    'Loan_Tenure_Months__c': helper.getDecimal(component.find('months').get("v.value")),
                    'Interest_Rate__c': helper.getDecimal(component.find('rate').get("v.value")),
                    'Total_Due__c': helper.getDecimal(component.find('loanAmt').get("v.value")) + helper.getDecimal(component.get('v.IPaid')),
                    'EMI_Amount__c': helper.getDecimal(component.get('v.Emi')),
                    'Interest_Paid__c': helper.getDecimal(component.get('v.IPaid')),
                    'recordTypeId': component.get("v.lead_bonanza_recordtype_Id"),
                    'Account__c':component.get("v.accountObj").Id
                }
            });
            evt.fire();
        }
    },
    saveAccountOpportunityEventHandler: function (component, event, helper) {
        console.log('saveAccountOpportunityEventHandler');
        component.set("v.showSpinner", true);
        try {
            let save_or_cancel = event.getParam('save_or_cancel');
            let accountObj = event.getParam('accountObj');
            let opportunityObj = event.getParam('opportunityObj');
            console.log('save_or_cancel:' + save_or_cancel);
            console.log('accountObj:' + JSON.stringify(accountObj));
            console.log('opportunityObj:' + JSON.stringify(opportunityObj));
            if (save_or_cancel === 'save') {
                var action = component.get("c.saveAccountOpportunityPopupData");
                action.setParams({
                    'accountObj': component.get("v.accountObj"),
                    'opportunityObj': component.get("v.opportunityObj")
                });
                action.setCallback(this, function (response) {
                    try {
                        var state = response.getState();
                        console.log('state:' + state);
                        if (state === "SUCCESS") {
                            let retval = response.getReturnValue();
                            console.log('retval:' + retval);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Success',
                                type: 'success',
                                message: 'Data has been saved successfully'
                            });
                            toastEvent.fire();
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/" + retval
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
                        component.set("v.showSpinner", false);
                    } catch (err) {
                        console.log(err.stack);
                    }
                });
                $A.enqueueAction(action);
            } else {
                //show home page on cancel button
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://zivoinsurance--torqueinfo.sandbox.lightning.force.com/lightning/page/home"
                });
                urlEvent.fire();
            }
        } catch (err) {
            console.log(err.stack);
        }
    }
    /* saveReference:function(component,event,helper){        
        var action = component.get("c.saveOpportunityReferences");
        action.setParams({            
            'phone': component.get("v.searchPhone")
            'Reference1':JSON.stringify(Reference1),
            'Reference2':JSON.stringify(Reference2),
            'Reference3':JSON.stringify(Reference3)
        });
        action.setCallback(this, function(a) {            
            var response = a.getReturnValue();
        });
            $A.enqueueAction(action);
    }*/
})