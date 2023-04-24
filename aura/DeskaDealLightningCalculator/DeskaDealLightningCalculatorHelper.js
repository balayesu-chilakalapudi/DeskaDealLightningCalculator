({
    getEMI : function(component, detail) {
        if(detail =="EMI"){
            component.set('v.notSubmitted', true);
            
        }
        var loanAmt = component.find('loanAmt').get("v.value");
        var prevContractAmt=component.find('prevContractAmt').get("v.value");
        var ThirdPartyPmt=component.find('ThirdPartyPmt').get("v.value");

            //document.getElementById('loanAmt').value; //loan ammount total
        var months = component.find('months').get("v.value");
            //document.getElementById('months').value; //total number of months
        var rate = component.find('rate').get("v.value");
            //document.getElementById('rate').value; //rate of interest
        //var demi = document.getElementById('DEmi').value;//down pyment   months == null || months.length == 0
        if (loanAmt == null || loanAmt.length == 0 || rate == null || months == null || months.length == 0 || rate.length == 0) {
            document.getElementById("err").style.display = "block";            
        } else {
            document.getElementById("err").style.display = "none";                           
            var rate1 = (rate / 1200) + 1;
            var rate2 = rate / 1200;
            const fees = component.find("Fees").get("v.value")//17.50;
            //const fees =0;
            console.log(rate1);
            console.log((rate / 1200));
            
            let amtPlusfees =parseFloat(loanAmt)+parseFloat(fees);
            console.log('prevContractAmt:'+prevContractAmt);
            console.log('ThirdPartyPmt:'+ThirdPartyPmt);
            if(prevContractAmt!=null && prevContractAmt!=''){
                amtPlusfees+=parseFloat(prevContractAmt);
            }
            if(ThirdPartyPmt!=null && ThirdPartyPmt!=''){
                amtPlusfees+=parseFloat(ThirdPartyPmt);
            }
                component.set('v.financed', '$'+amtPlusfees.toFixed(2))
                
                var powerRate = parseFloat(Math.pow(rate1,months));
                console.log(powerRate);
                
                var emi1 = parseFloat(((amtPlusfees)*rate2*powerRate));
                var emi2 = parseFloat((powerRate - 1));
                var emi = emi1/emi2;
                emi = emi.toFixed(2);
                var ipaid =emi*months - amtPlusfees;
                ipaid = ipaid.toFixed(2);
                console.log(emi1 +'emi2'+ emi2);
                component.set('v.IPaid','$'+ ipaid);
                component.set('v.Emi', '$'+emi);
                component.set('v.ARP', rate +'%');
                component.set('v.Term', months);
                
           // }
        }
    },
    getDecimal:function(data){
    	let decimal_data=0;
        if(data.includes('$')){
            data=data.replace('$','');
        }
        if(data!=null){
            decimal_data=parseFloat(data);
        }
        return decimal_data;
	}
})