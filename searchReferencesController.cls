public class searchReferencesController {
    @AuraEnabled(cacheable=true)
    public static opportunity oppRecord(string oppid) {
        system.debug('id'+oppid);
        Opportunity opp=[select Id,Competitors_in_Bid__c,Vendor_Selected__c,OwnerId,Relationship_with_Prospect__c,StageName from opportunity where Id=:oppid limit 1];
        return opp;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Contact> searchContacts(string accId) {
        system.debug('id'+accId);
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where AccountId=:accId];
        system.debug(con);
        return con;
    }
    @AuraEnabled(cacheable=true)
    public static list<Account> searchAccounts(list<object> lstring) {
        system.debug(lstring[0]);
        system.debug(lstring);
        String str = JSON.serialize(lstring);
        List<Object> arr =(List<Object>)JSON.deserializeUntyped(str);
        Account acc =new Account();
        Opportunity opp=new Opportunity();
        for(object o:arr)
        {
            Map<String, Object> firstMap = (Map<String, Object>)o;
            acc.Name= (String)firstMap.get('Name');
            acc.BillingCountry= (String)firstMap.get('Country');
            acc.Industry = (String)firstMap.get('Industry');
            acc.Servicing_Lead__c = (String)firstMap.get('ServicingLead');
            acc.Servicing_Partner__c=(String)firstMap.get('ServicingPartner');
            opp.Instance_Type__c = (String)firstMap.get('InstanceType');
        }
        list<string> bC=acc.BillingCountry.split(',');
        list<string> aBC=acc.BillingCountry.split(';');
        
        if(acc.Name!=null ||  acc.Industry!=null ||acc.Servicing_Lead__c!=null ||  acc.Servicing_Partner__c!=null ||opp.Instance_Type__c!=null)
        {
            List<Account> accounts = [SELECT Id,CSM__c,Owner.isActive,OwnerId, Name,Industry,BillingCountry,Account_Health__c,Referenceable__c,Servicing_Lead__c FROM Account WHERE Name = :acc.Name AND Industry=:acc.Industry
                                      AND Servicing_Lead__c=:acc.Servicing_Lead__c
                                      AND Servicing_Partner__c=:acc.Servicing_Partner__c
                                      AND Id IN (
                                          SELECT AccountId
                                          FROM Opportunity
                                          WHERE Instance_Type__c =:opp.Instance_Type__c
                                      )];
            system.debug(accounts);
            return accounts;
        }
        else
        {
            List<Account> accounts = [SELECT Id,CSM__c,Owner.isActive,OwnerId, Name,Industry,BillingCountry,Account_Health__c,Referenceable__c,Servicing_Lead__c FROM Account WHERE Name = :acc.Name AND (BillingCountry In:aBC
                                                                                                                                                                                                          OR BillingCountry In:bC)AND Industry=:acc.Industry
                                      AND Servicing_Lead__c=:acc.Servicing_Lead__c
                                      AND Servicing_Partner__c=:acc.Servicing_Partner__c
                                      AND Id IN (
                                          SELECT AccountId
                                          FROM Opportunity
                                          WHERE Instance_Type__c =:opp.Instance_Type__c
                                      )];
            system.debug(accounts);
            return accounts;
        }
        
    }
    @AuraEnabled(cacheable=false)
    public static list<Id> createRecord(list<object> objList)
    {
        system.debug(objList);
        String str = JSON.serialize(objList);
        List<Object> arr =(List<Object>)JSON.deserializeUntyped(str);
        list<Reference_Management_Process__c> rfmList=new list<Reference_Management_Process__c>();
        list<Id> rfmIdList=new list<Id>();
        for(object o:arr)
        {
            Reference_Management_Process__c obj=new Reference_Management_Process__c();
            Map<String, Object> firstMap = (Map<String, Object>)o;
            obj.Account__c= (String)firstMap.get('acc');
            obj.Account_Owner__c= (String)firstMap.get('accO');
            obj.Company_Background__c = (String)firstMap.get('compB');
            obj.Competitors__c = (String)firstMap.get('comp');
            // obj.Contact__c=(String)firstMap.get('con');
            obj.Denial_Reason__c = (String)firstMap.get('den');
            obj.Description_of_request__c= (String)firstMap.get('des');
            obj.Existing_vendors_if_applicable__c = (String)firstMap.get('exi');
            obj.Opportunity__c = (String)firstMap.get('opp');
            //obj.Prospect_Customer__c=(String)firstMap.get('pro');
            obj.Recipient_from_Account__c = (String)firstMap.get('rec');
            system.debug((String)firstMap.get('refA'));
            if((String)firstMap.get('refA')!=null &&(String)firstMap.get('refA')!='' )
            {
                obj.Reference_Approval_Deadline__c =  date.ValueOf((String)firstMap.get('refA'));
            }
            //obj.Reference_Management_Process_Name__c= (String)firstMap.get('refM');
            obj.Reference_objectives_key_use_cases__c = (String)firstMap.get('refO');
            // obj.Stage__c = (String)firstMap.get('stg');
            obj.Status__c=(String)firstMap.get('sts');
            obj.What_activity_do_you_need__c = (String)firstMap.get('wADYN');
            obj.Who_will_participate__c = (String)firstMap.get('wWP');
            system.debug(obj);
            rfmList.add(obj);    
        }
        Database.SaveResult[] saveResultList;
        try {
            if(rfmList.size()>0)
            {
                //insert listCaseTeamMember;
                saveResultList = Database.insert(rfmList, true);
                for (Database.SaveResult sr : saveResultList) 
                {
                    if (sr.isSuccess()) 
                    {
                        System.debug('Successfully inserted Reference Mangement Process' + sr.getId());
                        rfmIdList.add( sr.getId());
                    } 
                    else 
                    {              
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Reference Mangement Process fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        } 
        catch(Exception  e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage()+saveResultList);
            throw new AuraHandledException(e.getMessage());
        }
        return rfmIdList;
    }
    @AuraEnabled(cacheable=false)
    public static list<Id> updateReferenceManagmentContacts(String ContactIds,list<String> idRefSavedList)
    {
        system.debug(idRefSavedList);
        list<Reference_Management_Process__c> rfmListSalesforce=[select id,Reference_Management_Process_Name__c,Denial_Reason__c,Name,Account__c,Account__r.Name,Reference_Approval_Deadline__c,OwnerId,Contact__c from  Reference_Management_Process__c where Id In :idRefSavedList];
        list<Reference_Management_Process__c> updatedList=new list<Reference_Management_Process__c>();
        system.debug(rfmListSalesforce);
        list<Task> tList=new list<Task>();
        list<Id> tskIdList=new list<Id>();
        for(Reference_Management_Process__c refObj:rfmListSalesforce)
        {
            Task t=new Task();
            t.WhoId=ContactIds;
            t.WhatId=refObj.Id;
            t.ActivityDate=Date.today().addDays(+5);
            t.OwnerId=refObj.OwnerId;
            refObj.Contact__c=ContactIds;
            updatedList.add(refObj);
            tList.add(t);
        }
        Database.SaveResult[] saveResultList;
        Database.SaveResult[] saveResultListforTask;
        try
        {
            if(updatedList.size()>0)
            {
                //insert listCaseTeamMember;
                saveResultList = Database.update(updatedList, true);
                system.debug(updatedList);
                for(Reference_Management_Process__c refObj :updatedList)
                {
                    system.debug(''+refObj.Reference_Management_Process_Name__c+''+refObj.Account__r.Name+''+refObj.Contact__c+''+refObj.Reference_Approval_Deadline__c+''+refObj.Denial_Reason__c+'');
                    emailTemplate.sendemail('Contact_Verification_Request',refObj);
                }
                for (Database.SaveResult sr : saveResultList) 
                {
                    if (sr.isSuccess()) 
                    {
                        System.debug('Successfully Updated Reference Mangement Process' + sr.getId());
                        
                    } 
                    else 
                    {              
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Reference Mangement Process fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            
            if(tList.size()>0)
            {
                saveResultListforTask= Database.Insert(tList, true);
                for (Database.SaveResult sr : saveResultListforTask) 
                {
                    if (sr.isSuccess()) 
                    {
                        System.debug('Successfully Inserted Task' + sr.getId());
                        tskIdList.add(sr.getId());
                    } 
                    else 
                    {              
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Task fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        } 
        catch(Exception  e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage()+saveResultList+saveResultListforTask);
            throw new AuraHandledException(e.getMessage());
        }
        return tskIdList;
    }
    @AuraEnabled(cacheable=false)
    public static string updateStatusTask(list<String> tskIdList,String con)
    {
        system.debug(tskIdList); 
        if(con=='yes')
        {
            list<Task> tskSalesforce=[select id,WhatId,ActivityDate,OwnerId,Description,Status from Task where Id In:tskIdList];
            list<Task> upTskList=new list<Task> ();
            list<Task> newTskList=new list<Task> ();
            list<id> listRefId=new list<id>();
            for(Task obj:tskSalesforce)
            {
                obj.Status='Completed';
                obj.Description='Contact verified successfully';
                upTskList.add(obj);
                Task newTask=new Task();
                newTask.WhatId=obj.WhatId;
                newTask.ActivityDate=Date.today().addDays(+1);
                newTask.OwnerId=obj.OwnerId;
                listRefId.add(obj.WhatId);
                newTask.Description='Please Send Thank you email to "" for Approving Reference Request';
                newTskList.add(newTask);
                
            }
            Database.SaveResult[] saveResultUpdatedTaskList;
            Database.SaveResult[] saveResultNewTaskList;
            try
            {
                if(upTskList.size()>0)
                {
                    //insert listCaseTeamMember;
                    saveResultUpdatedTaskList = Database.update(upTskList, true);
                    list<Reference_Management_Process__c> rfmLi=[select id,Name,Account__c,Reference_Management_Process_Name__c,Account__r.Name,Reference_Approval_Deadline__c,Denial_Reason__c,OwnerId,Contact__c from  Reference_Management_Process__c where Id In :listRefId];
                    for(Reference_Management_Process__c rObj:rfmLi)
                    {
                        emailTemplate.sendemail('Contact_Verification_Approved' ,rObj);
                    }
                    
                    for (Database.SaveResult sr : saveResultUpdatedTaskList) 
                    {
                        if (sr.isSuccess()) 
                        {
                            System.debug('Successfully Updated Task' + sr.getId());
                            
                        } 
                        else 
                        {              
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Task fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
                
                if(newTskList.size()>0)
                {
                    saveResultNewTaskList= Database.Insert(newTskList, true);
                    for (Database.SaveResult sr : saveResultNewTaskList) 
                    {
                        if (sr.isSuccess()) 
                        {
                            System.debug('Successfully Inserted New Task' + sr.getId());
                            
                        } 
                        else 
                        {              
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('New Task fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
            }
            catch(Exception  e) 
            {
                System.debug('The following exception has occurred: ' + e.getMessage()+saveResultNewTaskList+saveResultUpdatedTaskList);
                throw new AuraHandledException(e.getMessage());
            }
        }
        else if(con=='no')
        {
            list<Task> tskSalesforce=[select id,WhatId,Description,Status from Task where Id In:tskIdList];
            list<Task> upTskList=new list<Task> ();
            list<Id> listRefId=new list<Id>();
            for(Task obj:tskSalesforce)
            {
                obj.Status='Completed';
                obj.Description='Contact cannot verified successfully';
                upTskList.add(obj);
                listRefId.add(obj.WhatId);
                
            }
            
            Database.SaveResult[] saveResultUpdatedTaskList;
            try
            {
                if(upTskList.size()>0)
                {
                    //insert listCaseTeamMember;
                    saveResultUpdatedTaskList = Database.update(upTskList, true);
                    list<Reference_Management_Process__c> rfmLi=[select id,Name,Account__c,Reference_Management_Process_Name__c,Account__r.Name,Denial_Reason__c,Reference_Approval_Deadline__c,OwnerId,Contact__c from  Reference_Management_Process__c where Id In :listRefId];
                    for(Reference_Management_Process__c obj:rfmLi)
                    {
                        system.debug(obj);
                        emailTemplate.sendemail('Contact_Verification_Declined',obj);
                    }
                    
                    for (Database.SaveResult sr : saveResultUpdatedTaskList) 
                    {
                        if (sr.isSuccess()) 
                        {
                            System.debug('Successfully Updated Task' + sr.getId());
                            
                        } 
                        else 
                        {              
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Task fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
            }
            catch(Exception  e) 
            {
                System.debug('The following exception has occurred: ' + e.getMessage()+saveResultUpdatedTaskList);
                throw new AuraHandledException(e.getMessage());
            }
        }
        return 'Success';
    }
    
}