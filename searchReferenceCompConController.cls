public class searchReferenceCompConController {
    @AuraEnabled(cacheable=true)
    public static Contact conRecord(string conId) {
        system.debug('id'+conId);
        Contact con=[select Id,accountId,account.Name,account.OwnerId,account.Owner.isActive,account.CSM__c  from Contact where Id=:conId limit 1];
        return con;
    }
    @AuraEnabled(cacheable=false)
    public static list<Id> createRecord(list<object> objList)
    {
        String str = JSON.serialize(objList);
        system.debug(objList);
          system.debug(str);
        List<Object> arr =(List<Object>)JSON.deserializeUntyped(str);
        list<Reference_Management_Process__c> rfmList=new list<Reference_Management_Process__c>();
        list<Id> rfmIdList=new list<Id>();
        list<Task> tList=new list<Task>();
        for(object o:arr)
        {
            system.debug(o);
            Reference_Management_Process__c obj=new Reference_Management_Process__c();
            Map<String, Object> firstMap = (Map<String, Object>)o;
            obj.Contact__c=(String)firstMap.get('con');
            obj.Description_of_request__c= (String)firstMap.get('des');
            system.debug((String)firstMap.get('acc'));
            obj.Account__c= (String)firstMap.get('acc');
            obj.Account_Owner__c= (String)firstMap.get('accO');
            obj.Company_Background__c = (String)firstMap.get('compB');
            obj.Recipient_from_Account__c = (String)firstMap.get('rec');
            if((String)firstMap.get('refA')!=null &&(String)firstMap.get('refA')!='' )
            {
                obj.Reference_Approval_Deadline__c =  date.ValueOf((String)firstMap.get('refA'));
            }
            obj.Status__c='Verification with Contact';
            obj.What_activity_do_you_need__c = (String)firstMap.get('wADYN');
            
            system.debug(obj);
            rfmList.add(obj);    
        }
        
        Database.SaveResult[] saveResultList;
        try {
            if(rfmList.size()>0)
            {
                system.debug(rfmList);
                //insert listCaseTeamMember;
                saveResultList = Database.insert(rfmList, true);
                system.debug(rfmList+'======'+saveResultList);
                
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
                list<Reference_Management_Process__c> rfmListSalesforce=[select id,Reference_Management_Process_Name__c,Denial_Reason__c,Name,Account__c,Account__r.Name,Reference_Approval_Deadline__c,OwnerId,Contact__c from  Reference_Management_Process__c where Id In :rfmIdList];                
                for(Reference_Management_Process__c obj:rfmListSalesforce)
                {
                    emailTemplate.sendemail('Contact_Verification_Approved' ,obj);
                    Task t=new Task();
                    t.WhoId=obj.Contact__c;
                    t.WhatId=obj.Id;
                    t.Status='Completed';
                    t.Description='Contact verified successfully';
                    t.ActivityDate=Date.today().addDays(+1);
                    //t.OwnerId=obj.OwnerId;
                    tList.add(t);
                }
                //emailTemplate.sendemail('Contact_Verification_Approved');
                Database.SaveResult[] saveResultNewTaskList;
                if(tList.size()>0)
                {
                    saveResultNewTaskList= Database.Insert(tList, true);
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
            
        } 
        catch(Exception  e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage()+saveResultList);
            throw new AuraHandledException(e.getMessage());
        }
        return rfmIdList;
    }
}