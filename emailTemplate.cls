public class emailTemplate {
    
    public static void sendemail(string nameEmailTemplate,Reference_Management_Process__c refObj)
    {
        //Reference_Management_Process__c refObj=[select id,Name,Account__c,Account__r.Name,Reference_Approval_Deadline__c,OwnerId,Contact__c from  Reference_Management_Process__c where Id ='aAb6C0000008U3OSAU' limit 1];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        list<Schema.EmailTemplate> emailTemp = [Select id, Subject, Body From EmailTemplate Where DeveloperName =:nameEmailTemplate];
        String sendingDat=emailTemp[0].body;
        sendingDat=sendingDat.replace('{!Reference_Management_Process__c.Reference_Management_Process_Name__c}',refObj.Reference_Management_Process_Name__c);
        sendingDat=sendingDat.replace('{!Reference_Management_Process__c.Account__c}',refObj.Account__r.Name);
        sendingDat=sendingDat.replace('{!Reference_Management_Process__c.ContactId__c}',refObj.Contact__c);
        if( sendingDat.contains('{!Reference_Management_Process__c.Reference_Approval_Deadline__c}'))
        {
            if(refObj.Reference_Approval_Deadline__c!=null)
            {
                sendingDat=sendingDat.replace('{!Reference_Management_Process__c.Reference_Approval_Deadline__c}',String.valueOf(refObj.Reference_Approval_Deadline__c));   
            }
            else
            {
                sendingDat=sendingDat.replace('{!Reference_Management_Process__c.Reference_Approval_Deadline__c}','Null');
            }
        }
        if(sendingDat.contains('{!Reference_Management_Process__c.Denial_Reason__c}'))
        {
            if(refObj.Denial_Reason__c!=null && refObj.Denial_Reason__c!='')
            {
                sendingDat=sendingDat.replace('{!Reference_Management_Process__c.Denial_Reason__c}',String.valueOf(refObj.Denial_Reason__c));     
            }
            else
            {
                sendingDat=sendingDat.replace('{!Reference_Management_Process__c.Denial_Reason__c}','Null');                 
            }
        }
        system.debug( sendingDat);
        // Reference_Management_Process__c con = [Select Id,ownerid,Account__c from Reference_Management_Process__c where id ='aAb6C0000008U2LSAU'];
        List<string> toAddress = new List<string>();
        toAddress.add('taimoor.ali@logicmount.com');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemp[0].Id);
        mail.plainTextBody=sendingDat;
        mail.setToAddresses(toAddress);
        mail.setTargetObjectId(refObj.OwnerId);
        mail.setSaveAsActivity(false);
        mail.setTreatTargetObjectAsRecipient(false);
        //mail.setWhatId(refIds);
        system.debug(mail);
        emailList.add(mail);
        // Send the emails in a transaction, then roll it back
        
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emailList);
        system.debug(resultMail);
        // Messaging.sendEmail(emailList);
        
        
    }
}