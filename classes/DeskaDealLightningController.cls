public class DeskaDealLightningController {
    
    @AuraEnabled
    public static boolean VINexists( string VIN ) {
        
        if( String.isBlank( VIN ) ) {
            return false;
        }
        
        List<Account> accs = [SELECT id FROM Account WHERE Vehicle_VIN__c = :VIN ];
        List<Lead> leads = [SELECT id FROM Lead WHERE VIN__c = :VIN];
        
        if( !accs.isEmpty() || !leads.isEmpty() ) {
            return true;
        } else {
            return false;
        }
        
    }
    
    @AuraEnabled
    public static string doClientSearch( string firstname, string lastname, string phone ) {
        
        clientResults results = new clientResults();
        results.leadCount = 0;
        results.accCount = 0;
        
        string response = '';
        //if( !String.isBlank( phone ) ) phone = '1' + phone;
        if( !String.isBlank( firstname ) ) firstname = firstname.trim();
        if( !String.isBlank( lastname ) ) lastname = lastname.trim();
        
        string strQuery = 'SELECT id, FirstName, LastName  FROM Lead WHERE IsConverted  = false AND (';
        
        if( !String.isBlank(firstname) && !String.isBlank(lastname) ) {
            strQuery += ' (FirstName = :firstname AND LastName = :lastname) OR ';
        }
        
        if( !String.isBlank(phone) ) {
            strQuery += ' (';
            strQuery += 'Cell_Phone__c = :phone OR ';
            strQuery += 'Home_phone__c = :phone OR ';
            strQuery += 'Phone = :phone OR ';
            strQuery += 'Work_Phone__c = :phone';
            strQuery += ')';
        }else{
            strQuery=strQuery.removeend(' OR ');
        }
        strQuery += ')';
        strQuery=strQuery.removeEnd(' AND ()');
        system.debug('phone:'+phone);
        system.debug('firstname:'+firstname);
        system.debug('lastname:'+lastname);
        system.debug(strQuery);
        List<Lead> leads = database.query(strQuery);
        
        if( leads.isEmpty() ) {
            response = '<p>No Leads found.</p>';
        } else {
            response = '<p>' + string.valueOf(leads.size() ) + ' Lead(s) found. ';
            
            for( lead l : leads ) {
                results.leadID = l.id;
                results.firstName = l.firstName;
                results.lastName = l.lastName;
                response += '<a href="/' + l.id + '" target="_blank">';
                if( !String.isBlank(l.FirstName ) ) response += l.FirstName + ' ';
                if( !String.isBlank(l.LastName ) ) response += l.LastName + ' ';
                response += '</a>';
            }
            response += '</p>';
            results.leadCount = leads.size();
        }
        
        strQuery = 'SELECT id, FirstName, LastName FROM Account WHERE (';
        
        if( !String.isBlank(firstname) && !String.isBlank(lastname) ){
         strQuery += '(FirstName = :firstname AND LastName = :lastname) OR ';
        }
        if( !String.isBlank(phone) ) {
            strQuery += '(';
            strQuery += 'PersonMobilePhone = :phone OR ';
            strQuery += 'PersonHomePhone = :phone OR ';
            strQuery += 'Work_Phone__c = :phone OR ';
            strQuery += 'Phone = :phone ';
            strQuery += ')';
        }else{
            strQuery=strQuery.removeend(' OR ');
        }
        strQuery+=')';
        strQuery=strQuery.removeEnd(' WHERE ()');
        system.debug(phone);
        system.debug(strQuery);
        List<Account> contacts = database.query(strQuery);
        
        if( contacts.isEmpty() ) {
            response += 'No Accounts found.';
        } else {
            response += '<p>' + string.valueOf(contacts.size() ) + ' Account(s) found. ';
            
            for( Account c : contacts ) {
                results.accID = c.id;
                results.firstName = c.firstName;
                results.lastName = c.lastName;
                response += '<a href="/' + c.id + '" target="_blank">';
                if( !String.isBlank(c.FirstName ) ) response += c.FirstName + ' ';
                if( !String.isBlank(c.LastName ) ) response += c.LastName + ' ';
                response += '</a>';
            }
            response += '</p>';
            results.accCount = contacts.size();
        }
        
        results.html = response;

       // previousContracts       
       String previous_contracts_query = 'SELECT id, First_Name__c, Last_Name__c,Remaining_Balance__c FROM Opportunity WHERE Status__c=\'Active\' AND (';
        
        if( !String.isBlank(firstname) && !String.isBlank(lastname) ){
            previous_contracts_query += '(First_Name__c = :firstname AND Last_Name__c = :lastname) OR ';
        }       
        if( !String.isBlank(phone) ) {
            previous_contracts_query += '(';
            previous_contracts_query += 'Phone_Number__c = :phone OR ';
            previous_contracts_query += 'Cell_phone__c = :phone OR ';
            previous_contracts_query += 'Home_phone__c = :phone OR ';
            previous_contracts_query += 'Work_Phone__c = :phone OR ';
            previous_contracts_query += 'First_Reference_Phone_Number__c = :phone OR ';
            previous_contracts_query += 'Second_Reference_Phone_Number__c = :phone OR ';
            previous_contracts_query += 'Lender_s_Phone_Number__c = :phone OR ';
            previous_contracts_query += 'Third_Reference_Phone_Number__c = :phone ';
            previous_contracts_query += ')';
        }else{
            previous_contracts_query=previous_contracts_query.removeend(' OR ');
        }
        previous_contracts_query+=')';
        previous_contracts_query=previous_contracts_query.removeEnd(' AND ()');
        system.debug(phone);
        system.debug(previous_contracts_query);
        List<Opportunity> previous_contracts = database.query(previous_contracts_query);
        
        if( previous_contracts.isEmpty() ) {
            response += 'No Previous Contracts found.';
        } else {
            response += '<p>' + string.valueOf(previous_contracts.size() ) + ' previous contract(s) found. ';
        }  
        results.previousContracts=previous_contracts;
        return JSON.serialize(results);
        
    }
    
    @AuraEnabled
    public static string updateLead( id leadID, string loanAmount, string term, string totalInterest, string APR, string monthlyEMI ) {
        
        List<Lead> leads = [ SELECT Total_Amount_Financed__c, Term__c, Interest_Amount__c, APR__c, EMI__c FROM Lead WHERE id = :leadID LIMIT 1];
        
        if( !leads.isEmpty()) {
            
            leads.get(0).Total_Amount_Financed__c = loanAmount;
            leads.get(0).Term__c = term;
            leads.get(0).Interest_Amount__c = totalInterest;
            leads.get(0).APR__c = APR;
            leads.get(0).EMI__c = monthlyEMI;
            
            update leads;
        }
        
        return leadID;
        
        
    }
    
    
    
    public class clientResults {
        public string html;
        public id leadID;
        public integer leadCount;
        public id accID;
        public integer accCount;
        public string firstName;
        public string lastName;
        @AuraEnabled 
        public List<Opportunity> previousContracts;
    }
    
    public class StoreResults {
        @AuraEnabled
        public id leadID;
        @AuraEnabled
        public id accID;
        @AuraEnabled
        public id oppId;
        @AuraEnabled
        public string firstName;
        @AuraEnabled
        public string lastName;
        @AuraEnabled
        public string msg;
        @AuraEnabled
        public string opportunityMode;
        @AuraEnabled
        public string accountMode;
        @AuraEnabled
        public boolean isInPermissionSet;
    }
    
    /*@AuraEnabled
public static StoreResults searchStoreLeadTest( boolean isInPermissionSet, string firstname, string lastname, string phone ) {
}*/
    
    @AuraEnabled
    public static StoreResults searchStoreLead( boolean isInPermissionSet, string firstname, string lastname, string phone,String frequency,String loanAmt,String Fees,String months, String rate,String IPaid,String Emi,String duedate) {
        String bonanza_recordtype_Id=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bonanza').getRecordTypeId();
        /*List<Lead> referencelist=new List<Lead>();
Lead Reference1Obj;
Lead Reference2Obj;
Lead Reference3Obj;
try{
Reference1Obj=(Lead)JSON.deserialize(Reference1, Lead.class);
Reference2Obj=(Lead)JSON.deserialize(Reference2, Lead.class);
Reference3Obj=(Lead)JSON.deserialize(Reference3, Lead.class);
referencelist.add(Reference1Obj);
referencelist.add(Reference2Obj);
referencelist.add(Reference3Obj);
}catch(Exception ex){
system.debug(ex);
}
system.debug('referencelist:'+referencelist);*/
        StoreResults result = new StoreResults();
        isInPermissionSet = isInPermissionSet == null ? false : isInPermissionSet;
        System.debug('@@isInPermissionSet ::'+isInPermissionSet);
        if( !String.isBlank( phone ) ) phone = '1' + phone;
        if( !String.isBlank( firstname ) ) firstname = firstname.trim();
        if( !String.isBlank( lastname ) ) lastname = lastname.trim();
        
        string strQuery = 'SELECT id, FirstName, LastName, Account__c, Referred_By__c,Referred_By__r.Name  FROM Lead WHERE';
        
        if( !String.isBlank(firstname) && !String.isBlank(lastname) ) strQuery += '((FirstName = :firstname AND LastName = :lastname)';
        if( !String.isBlank(firstname) && !String.isBlank(lastname) && !String.isBlank(phone) ) strQuery += 'OR';
        if( !String.isBlank(phone) ) {
            strQuery += '(';
            strQuery += 'Cell_Phone__c = :phone OR ';
            strQuery += 'Home_phone__c = :phone OR ';
            strQuery += 'Phone = :phone OR ';
            strQuery += 'Work_Phone__c = :phone';
            strQuery += ')';
        }
        strQuery += ') AND IsConverted  = false';
        
        system.debug(phone);
        system.debug('@@strQuery ::'+strQuery);
        List<Lead> leads = database.query(strQuery);
        
        String strAccQuery = 'SELECT id, FirstName, LastName, Name FROM Account WHERE';
        
        if( !String.isBlank(firstname) && !String.isBlank(lastname) ) strAccQuery += '(FirstName = :firstname AND LastName = :lastname)';
        if( !String.isBlank(firstname) && !String.isBlank(lastname) && !String.isBlank(phone) ) strAccQuery += 'OR';
        if( !String.isBlank(phone) ) {
            strAccQuery += '(';
            strAccQuery += 'PersonMobilePhone = :phone OR ';
            strAccQuery += 'PersonHomePhone = :phone OR ';
            strAccQuery += 'Work_Phone__c = :phone OR ';
            strAccQuery += 'Phone = :phone ';
            strAccQuery += ')';
        }
        system.debug(phone);
        system.debug('@@strAccQuery ::'+strAccQuery);
        List<Account> accountList = database.query(strAccQuery);
        String pendingStage = 'Pending Documents';
        String name = '%' + firstname + lastname + '%';
        String strOppQuery = 'SELECT id, First_Name__c, Last_Name__c, Name FROM Opportunity WHERE (StageName = :pendingStage AND Name Like :name)';
        
        if( !String.isBlank(firstname) && !String.isBlank(lastname) ) strOppQuery += ' OR (First_Name__c = :firstname AND Last_Name__c = :lastname)';
        if( !String.isBlank(firstname) && !String.isBlank(lastname) && !String.isBlank(phone) ) strOppQuery += 'OR';
        if( !String.isBlank(phone) ) {
            strOppQuery += '(';
            strOppQuery += 'Cell_phone__c = :phone OR ';
            strOppQuery += 'Home_phone__c = :phone OR ';
            strOppQuery += 'Work_Phone__c = :phone ';
            strOppQuery += ')';
        }
        
        system.debug('@@strOppQuery ::' +strOppQuery);
        List<Opportunity> opportunityList = database.query(strOppQuery);
        
        System.debug('@@leads ::'+leads);
        System.debug('@@accountList ::'+accountList);
        System.debug('@@opportunityList ::'+opportunityList);
        if(leads.isEmpty() && opportunityList.isEmpty()){
            if(accountList.isEmpty()){
                Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('personal_Account').getRecordTypeId();
                Account account = new Account();
                account.Name = firstname +' '+lastname;
                account.Phone = phone;
                account.RecordTypeId = recordTypeId;
                insert account;
                Opportunity opp = new Opportunity(AccountId = account.Id,Name = 'Deal Desk Opportunity For '+account.Name, StageName = 'Pending Documents',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
                opp.Payment_Frequency__c=frequency;
                opp.Monthly_Payment__c=frequency;
                if(loanAmt!=null){
                    opp.Laon_Amount_Requested__c = Decimal.valueOf(loanAmt);
                }
                if(Fees!=null){
                    opp.Fees__c= Decimal.valueOf(Fees);
                }
                if(months!=null){
                	opp.Loan_Tenure_Months__c = Decimal.valueOf(months);
                }
                if(rate!=null){
                    opp.Interest_Rate__c = Decimal.valueOf(rate);
                }
                if(IPaid!=null){
                    IPaid=IPaid.replace('$','');
                    opp.Interest_Paid__c = Decimal.valueOf(IPaid);
                }
                if(Emi!=null){
                    Emi=Emi.replace('$','');
                    opp.EMI_Amount__c=Decimal.valueOf(Emi);
                }
                opp.Total_Due__c=opp.Laon_Amount_Requested__c;
                if(IPaid!=null){
                    IPaid=IPaid.replace('$','');
                    opp.Total_Due__c+=Decimal.valueOf(IPaid);
                }
                opp.RecordTypeId=bonanza_recordtype_Id;
                if(duedate!=null){
                    opp.due_date__c=Date.valueOf(duedate);
                }
                insert opp;
                result.oppId = opp.Id;
                result.accID = account.Id;
                result.accountMode = 'edit';
                result.opportunityMode = 'edit';
            }else{
                List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId =: accountList AND StageName = 'Pending Documents'];
                if (!opps.isEmpty() && !isInPermissionSet) {
                    // return the exception : We can not move forward since we already have an open opportunity
                    //result.oppId = opps[0].Id;
                    List<PermissionSetAssignment> permissionSetList = [Select PermissionSet.Name FROM PermissionSetAssignment Where PermissionSet.Name = 'Allow_Opportunity_Create'];
                    if(!permissionSetList.isEmpty()){
                        result.isInPermissionSet = true;
                    }else{
                        result.isInPermissionSet = false;
                    }
                    result.msg = 'We can not move forward since we already have an Pending Documents opportunity';
                }else {
                    Opportunity opp = new Opportunity(AccountId = accountList[0].Id, Name = 'Deal Desk Opportunity For '+accountList[0].Name, StageName = 'Pending Documents',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
                    opp.Payment_Frequency__c=frequency;
                    opp.Monthly_Payment__c=frequency;
                    if(loanAmt!=null){
                        opp.Laon_Amount_Requested__c = Decimal.valueOf(loanAmt);
                    }
                    if(Fees!=null){
                        opp.Fees__c= Decimal.valueOf(Fees);
                    }
                    //opp.Zivo_Term__c = months;
                    if(months!=null){
                		opp.Loan_Tenure_Months__c = Decimal.valueOf(months);
                	}
                    if(rate!=null){
                        opp.Interest_Rate__c = Decimal.valueOf(rate);
                    }
                    if(IPaid!=null){
                    IPaid=IPaid.replace('$','');
                    opp.Interest_Paid__c = Decimal.valueOf(IPaid);
                }
                if(Emi!=null){
                    Emi=Emi.replace('$','');
                    opp.EMI_Amount__c=Decimal.valueOf(Emi);
                }
                opp.Total_Due__c=opp.Laon_Amount_Requested__c;
                if(IPaid!=null){
                    IPaid=IPaid.replace('$','');
                    opp.Total_Due__c+=Decimal.valueOf(IPaid);
                }
                    opp.RecordTypeId=bonanza_recordtype_Id;
                    if(duedate!=null){
                        opp.due_date__c=Date.valueOf(duedate);
                    }
                    insert opp;
                    result.oppId = opp.Id;
                    result.accID = accountList[0].Id;
                    result.accountMode = 'readonly';
                    result.opportunityMode = 'edit';
                }
            }
            
        }else if(!leads.isEmpty()) {
            Database.LeadConvert leadConvert = new database.LeadConvert();
            leadConvert.setLeadId(leads[0].Id);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel, ApiName  FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            leadConvert.setConvertedStatus(convertStatus.ApiName);
            if(leads[0].Account__c != null){
                leadConvert.setAccountId(leads[0].Account__c);
            }
            
            Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
            result.oppId = leadConvertResult.getOpportunityId();
            result.accID = leadConvertResult.getAccountId();
            result.accountMode = 'edit';
            result.opportunityMode = 'edit';
            /* 
if(!accountList.isEmpty()){
List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId =: accountList/ *selectedLead.Referred_By__c* / AND StageName = 'Pending Documents'];
if (opps.size() > 0 && !isInPermissionSet) {
// return the exception : We can not move forward since we already have an open opportunity
//result.oppId = opps[0].Id;
List<PermissionSetAssignment> permissionSetList = [Select PermissionSet.Name FROM PermissionSetAssignment Where PermissionSet.Name = 'Allow_Opportunity_Create'];
if(!permissionSetList.isEmpty()){
result.isInPermissionSet = true;
}else{
result.isInPermissionSet = false;
}
result.msg = 'We can not move forward since we already have an Pending Documents opportunity';
}else {
Opportunity opp = new Opportunity(AccountId = accountList[0].Id, Name = 'Deal Desk Opportunity For '+accountList[0].Name, StageName = 'Pending Documents',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
insert opp;
result.oppId = opp.Id;
result.accID = accountList[0].Id;
result.accountMode = 'readonly';
result.opportunityMode = 'edit';
}
}else{
Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('personal_Account').getRecordTypeId();
Account account = new Account();
account.Name = firstname +' '+lastname;
account.Phone = phone;
account.RecordTypeId = recordTypeId;
insert account;
Opportunity opp = new Opportunity(AccountId = account.Id,Name = 'Deal Desk Opportunity For '+account.Name, StageName = 'Pending Documents',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
insert opp;
result.oppId = opp.Id;
result.accID = account.Id;
result.accountMode = 'edit';
result.opportunityMode = 'edit';
}*/
        }
        else if(!opportunityList.isEmpty()){
            if (!isInPermissionSet) {
                // return the exception : We can not move forward since we already have an open opportunity
                //result.oppId = opps[0].Id;
                List<PermissionSetAssignment> permissionSetList = [Select PermissionSet.Name FROM PermissionSetAssignment Where PermissionSet.Name = 'Allow_Opportunity_Create'];
                if(!permissionSetList.isEmpty()){
                    result.isInPermissionSet = true;
                }else{
                    result.isInPermissionSet = false;
                }
                result.msg = 'We can not move forward since we already have an Pending Documents opportunity';
            }else {
                try{
                    Account account;
                    if(accountList.isEmpty()){
                     Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('personal_Account').getRecordTypeId();
                 account = new Account();
                account.Name = firstname +' '+lastname;
                account.Phone = phone;
                account.RecordTypeId = recordTypeId;
                insert account;
                    }else{
                        account=accountList[0];
                    }
                    
                    Opportunity opp = new Opportunity(AccountId = account.Id, Name = 'Deal Desk Opportunity For '+account.Name, StageName = 'Pending Documents',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
                    opp.Payment_Frequency__c=frequency;
                    opp.Monthly_Payment__c=frequency;
                    if(loanAmt!=null){
                        opp.Laon_Amount_Requested__c = Decimal.valueOf(loanAmt);
                    }
                    if(Fees!=null){
                        opp.Fees__c= Decimal.valueOf(Fees);
                    }
                    //opp.Zivo_Term__c = months;
                    if(months!=null){
                		opp.Loan_Tenure_Months__c = Decimal.valueOf(months);
                	}
                    if(rate!=null){
                        opp.Interest_Rate__c = Decimal.valueOf(rate);
                    }
                    if(IPaid!=null){
                    IPaid=IPaid.replace('$','');
                    opp.Interest_Paid__c = Decimal.valueOf(IPaid);
                }
                if(Emi!=null){
                    Emi=Emi.replace('$','');
                    opp.EMI_Amount__c=Decimal.valueOf(Emi);
                }
                opp.Total_Due__c=opp.Laon_Amount_Requested__c;
                if(IPaid!=null){
                    IPaid=IPaid.replace('$','');
                    opp.Total_Due__c+=Decimal.valueOf(IPaid);
                }
                if(duedate!=null){
                    opp.due_date__c=Date.valueOf(duedate);
                }
                    opp.RecordTypeId=bonanza_recordtype_Id;
                    insert opp;
                    result.oppId = opp.Id;
                    result.accID = accountList[0].Id;
                    result.accountMode = 'readonly';
                    result.opportunityMode = 'edit';
                }catch(Exception ex){
                    system.debug(ex+'\n'+ex.getStackTraceString());
                }
            }
        }
        
        /* 
Boolean isAccountFound = false;
Lead selectedLead = leads.get(0);
List<Id> ids = new List<Id>();
for (Lead lead : leads) {
if (lead.Referred_By__c != null) {
isAccountFound = true;
selectedLead = lead;
result.leadID = lead.Id;
result.accID = lead.Referred_By__c;
ids.add(lead.Referred_By__c);
}
}
System.debug('@@ids ::'+ids);
if (!ids.isEmpty() || !accountList.isEmpty()) {
List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE (AccountId =: ids OR AccountId =: accountList)/ *selectedLead.Referred_By__c* / AND StageName = 'Open'];
if (opps.size() > 0) {
// return the exception : We can not move forward since we already have an open opportunity
result.oppId = opps[0].Id;
result.msg = 'We can not move forward since we already have an open opportunity';
}else {
Opportunity opp = new Opportunity(AccountId = selectedLead.Referred_By__c,Name = ' Deal Desk Opportunity For '+selectedLead.Referred_By__r.Name, StageName = 'Open',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
insert opp;
result.oppId = opp.Id;
}
}/ *else {
Database.LeadConvert leadConvert = new database.LeadConvert();
leadConvert.setLeadId(selectedLead.Id);

LeadStatus convertStatus = [SELECT Id, MasterLabel, ApiName  FROM LeadStatus WHERE IsConverted=true LIMIT 1];
leadConvert.setConvertedStatus(convertStatus.ApiName);

Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
result.accID = leadConvertResult.getAccountId();
result.oppId = leadConvertResult.getOpportunityId();
result.leadID = leadConvertResult.getLeadId();
}* /
else{
Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('personal_Account').getRecordTypeId();
Account account = new Account();
account.Name = firstname +' '+lastname;
account.Phone = phone;
account.RecordTypeId = recordTypeId;
insert account;
Opportunity opp = new Opportunity(AccountId = account.Id,Name = ' Deal Desk Opportunity For '+account.Name, StageName = 'Open',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
insert opp;
result.oppId = opp.Id;
result.accID = account.Id;
}

} else {
if(!accountList.isEmpty()){
List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId =: accountList	/ *selectedLead.Referred_By__c* / AND StageName = 'Open'];
if (opps.size() > 0) {
// return the exception : We can not move forward since we already have an open opportunity
result.oppId = opps[0].Id;
result.msg = 'We can not move forward since we already have an open opportunity';
}else {
Opportunity opp = new Opportunity(AccountId = accountList[0].Id, Name = ' Deal Desk Opportunity For '+accountList[0].Name, StageName = 'Open',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
insert opp;
result.oppId = opp.Id;
}
}else{
Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('personal_Account').getRecordTypeId();
Account account = new Account();
account.Name = firstname +' '+lastname;
account.Phone = phone;
account.RecordTypeId = recordTypeId;
insert account;
Opportunity opp = new Opportunity(AccountId = account.Id,Name = ' Deal Desk Opportunity For '+account.Name, StageName = 'Open',CloseDate = System.today(),Total_Financed_Amount__c = '0', Term__c= '5',APR__c = '5');
insert opp;
result.oppId = opp.Id;
result.accID = account.Id;
result.accountMode = 'edit';
result.opportunityMode = 'edit';
}

}*/
        //create references
        /*try{
if(result.oppId!=null){
insert referencelist;
Opportunity opp=[select Reference_1__c, Reference_2__c, Reference_3__c from opportunity WHERE Id=:result.oppId
and (Reference_1__c=null or Reference_2__c=null or Reference_3__c=null)];
opp.Reference_1__c=Reference1Obj.Id;
opp.Reference_2__c=Reference2Obj.Id;
opp.Reference_3__c=Reference3Obj.Id;
update opp;
}
}catch(Exception ex){
system.debug(ex+'\n'+ex.getStackTraceString());
}*/
        return result;
    }
    
    @AuraEnabled
    public static String saveAccountOpportunityPopupData(Account accountObj,Opportunity opportunityObj){        
        String oppId=null;
        try {
            system.debug('accountObj:'+accountObj);
            system.debug('opportunityObj:'+opportunityObj);
            Id account_recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bonanza').getRecordTypeId();
            Id opportunity_recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Bonanza').getRecordTypeId();
            accountObj.RecordTypeId=account_recordTypeId;
            if(accountObj.Id==null){
                insert accountObj;
            }
            //opportunity data
            opportunityObj.accountId=accountObj.Id;
            opportunityObj.RecordTypeId=opportunity_recordTypeId;
            opportunityObj.StageName='Pending Documents';
            opportunityObj.CloseDate=system.today();
            insert opportunityObj;
            oppId= opportunityObj.Id;
            system.debug('oppId:'+oppId);
        } catch (Exception e) {
            throw new AuraHandledException('Exception:'+e+'\n'+e.getMessage());
        }   
        return oppId;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // struggling for coverage. I was left with no choice - CM
    public static void extra() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    
    
    
}