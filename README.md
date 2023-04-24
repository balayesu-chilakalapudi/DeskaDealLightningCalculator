# aura-checkbox-list

The function checkAll() is useful when you want to select multiple checkboxes at one time click, basically this is used to select the list of checkboxes present in a iteration list

```
function checkAll () {
  let inputs = document.querySelectorAll("input[type=checkbox]")
  inputs.forEach(item => {
    item.checked = true
  })
}
```


The function uncheckAll() is used for unchecking checkboxe present in a iteration list in a single click
```
function uncheckAll () {
  let inputs = document. querySelectorAll("input[type=checkbox]")
  inputs.forEach(item => {
    item.checked = false
  })
}
```


below code is the js part of the aura file and using uncheckAll() method as it using to clear other checkboxes when one of the checkbox selected. the function also handles when selected checkbox unchecked then it is puting zero value to the one of the textbox. 

```
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
    
```
   
   

below is the cmp part of the aura file which calling above javascript method
   
   
```
    <aura:if isTrue="{!v.previousContracts.length>0}">
        <br />
          <table class="slds-table slds-table_cell-buffer slds-table_bordered">
              <caption>Previous Contracts</caption>
              <thead>
              <tr class="slds-line-height_reset">                                            
                  <td scope="col">Firstname</td>
                  <td scope="col">Lastname</td>
                  <td scope="col">Phone</td>
              </tr>
          </thead>
          <tbody>
              <aura:iteration items="{!v.previousContracts}" var="prev_contract">
              <tr class="slds-hint-parent">
                  <td scope="col"><input type="checkbox" name="prev" id="{!prev_contract.Id}" onchange="{!c.prevcontractselected}" />&nbsp;
                  {!prev_contract.First_Name__c}</td>
                  <td scope="col">{!prev_contract.Last_Name__c}</td>
                  <td scope="col">                                                
                      {!prev_contract.Phone_Number__c}
                  </td>
              </tr>
              </aura:iteration>
              </tbody>
          </table>
      <aura:set attribute="else">
          <span style="font-size:15px;color:blue;text-align:center">No Previous Contracts available.</span>
      </aura:set>
      </aura:if>
    ```
