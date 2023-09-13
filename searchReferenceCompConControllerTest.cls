@IsTest(SeeAllData=false)
public class searchReferenceCompConControllerTest {
    @testSetup static void setup() {
        Account acc=new Account();
        acc.Name='Testing-Taimoor';
        acc.Industry='Hospitality & Travel';
        acc.BillingCountry='Pakistan';
        acc.Servicing_Partner__c='Booz Allen';
        insert acc;
        system.debug(acc);
        Contact con=new Contact();
        con.LastName='taimoor';
        con.Phone='+925946787';
        con.AccountId=acc.Id;
        insert con;
        system.debug(acc);
        Reference_Management_Process__c re=new Reference_Management_Process__c();
        re.Denial_Reason__c='sd';
        re.Account__c=acc.Id;
        re.Contact__c=con.Id;
        insert re;
        Task t=new Task();
        t.whatId=re.Id;
        t.Status='Completed';
        t.Description='Contact verified successfully';
        t.ActivityDate=system.now().Date();
        t.WhoId=con.Id;
        insert t;
        
    }
    @isTest static void fun1() {
        
        
        list<Account> acc=[select Id,Name  from Account where Name='Testing-Taimoor'];
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where Name='taimoor'];
        
        Map<String, Object> hardcodedObject = new Map<String, Object>{
            'con' => con[0].id,
                'des' => 'Description1',
                'acc' => acc[0].id,
                'accO' => '0054X00000Dxb58QAB',
                'compB' => acc[0].id,
                'rec' => '0054X00000Dxb58QAB',
                'refA' => '2023-09-05', // Date in yyyy-MM-dd format
                'wADYN' => ''
                };
                    
                    list<Object> oList=new list<object>();
        oList.add(hardcodedObject);
        Test.startTest();
        searchReferenceCompConController.createRecord(oList);
        Test.stopTest();
    }
    @isTest static void fun2() {
        
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where Name=:'taimoor'];
        Test.startTest();
        searchReferenceCompConController.conRecord(con[0].id);
        Test.stopTest();
    }
    
    @isTest static void fun3()
    {
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where Name=:'taimoor'];
        Reference_Management_Process__c refObj=[select id,Name,Account__c,Account__r.Name,Reference_Management_Process_Name__c,Denial_Reason__c,Reference_Approval_Deadline__c,OwnerId,Contact__c from  Reference_Management_Process__c where Contact__c=:con[0].id limit 1];
        schema.EmailTemplate et=new schema.EmailTemplate();
        et.Subject='testing';
        et.Name='Contact_Verification_Approved';
        et.Body='{!Reference_Management_Process__c.Reference_Management_Process_Name__c}{!Reference_Management_Process__c.Account__c}{!Reference_Management_Process__c.Denial_Reason__c}{!Reference_Management_Process__c.ContactId__c}  {!Reference_Management_Process__c.Reference_Approval_Deadline__c}';
        et.DeveloperName='Contact_Verification_Approved';
        et.TemplateType= 'Text';
        et.isActive = true;
        et.FolderId ='0054X00000Dxb58QAB';
        insert et;
        Test.startTest();
        emailTemplate.sendemail('Contact_Verification_Approved',refObj);
        Test.stopTest();
    }
}