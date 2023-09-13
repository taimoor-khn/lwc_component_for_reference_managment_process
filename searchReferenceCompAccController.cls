public class searchReferenceCompAccController {
    @AuraEnabled(cacheable=true)
    public static list<Contact> searchContacts(string accId) {
        system.debug('id'+accId);
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where AccountId=:accId];
        system.debug(con);
        return con;
    }
    @AuraEnabled(cacheable=true)
    public static Account accRecord(string accId) {
        system.debug('id'+accId);
        Account opp=[select Id,Owner.isActive,OwnerId,CSM__c from Account where Id=:accId limit 1];
        return opp;
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
            if((String)firstMap.get('opp')!='' &&  (String)firstMap.get('opp')!=null)
            {
                obj.Opportunity__c = (String)firstMap.get('opp');
            }
            
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
                system.debug(rfmList);
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
        return searchReferencesController.updateReferenceManagmentContacts(ContactIds,idRefSavedList);
    }
    @AuraEnabled(cacheable=false)
    public static string updateStatusTask(list<String> tskIdList,String con)
    {
        system.debug(tskIdList);
        
        return searchReferencesController.updateStatusTask(tskIdList,con);
    }
}