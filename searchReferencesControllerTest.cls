@IsTest(SeeAllData=false)
public class searchReferencesControllerTest {
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
        Opportunity opp=new Opportunity();
        opp.Name='opp bane';
        opp.StageName='Commit';
        opp.CloseDate=system.now().date();
        opp.AccountId=acc.Id;
        opp.Instance_Type__c='Medallia Experience Cloud';
        insert opp;
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
        
        Map<String, Object> hardcodedObject = new Map<String, Object>{
            'Country' => 'Pakistan',
                'Industry' => 'Hospitality & Travel',
                'InstanceType' => 'Medallia Experience Cloud',
                'Name' => 'Testing-Taimoor',
                'ServicingLead' => 'Medallia',
                'ServicingPartner' => 'Booz Allen',
                'id' => '0'
                };
                    system.debug('testing');
        list<Object> oList=new list<object>();
        Object obj1 = hardcodedObject;
        oList.add(obj1);
        system.debug('testing');
        //searchReferencesController.searchContacts('001D000000Jsm0WIAR');
        system.debug('testing');
        Test.startTest();
        searchReferencesController.searchAccounts(oList);
        Test.stopTest();
        
    }
    @isTest static void fun2() {
        Map<String, Object> hardcodedObject = new Map<String, Object>{
            'Country' => 'Pakistan',
                'Industry' => null,
                'InstanceType' => null,
                'Name' => null,
                'ServicingLead' => null,
                'ServicingPartner' => null,
                'id' => '0'
                };
                    system.debug('testing');
        list<Object> oList=new list<object>();
        Object obj1 = hardcodedObject;
        oList.add(obj1);
        system.debug('testing');
        //searchReferencesController.searchContacts('001D000000Jsm0WIAR');
        system.debug('testing');
        Test.startTest();
        searchReferencesController.searchAccounts(oList);
        Test.stopTest();
    }
    @isTest static void fun3()
    {
        Opportunity opp=[select Id from opportunity where Name='opp bane' limit 1] ;
        Test.startTest();
        searchReferencesController.oppRecord(opp.Id);
        Test.stopTest();
    }
    @isTest static void fun4()
    {
        Map<String, Object> hardcodedObject = new Map<String, Object>{
            'Account__c' => '0016C00000ptEGJQA2',
                'Account_Owner__c' => '0054X00000Dxb58QAB',
                'Company_Background__c' => '0016C00000ptEGJQA2',
                'Competitors__c' => '',
                'Denial_Reason__c' => '',
                'Description_of_request__c' => '',
                'Existing_vendors_if_applicable__c' => '',
                'Opportunity__c' => '0066C00000H6EKLQA3',
                'Recipient_from_Account__c' => null,
                'Reference_objectives_key_use_cases__c' => '',
                'Status__c' => '',
                'What_activity_do_you_need__c' => '',
                'Who_will_participate__c' => ''
                };
                    list<Object> oList=new list<object>();
        Object obj1 = hardcodedObject;
        oList.add(obj1);
        Test.startTest();
        searchReferencesController.createRecord(oList);
        Test.stopTest();
    }
    @isTest static void fun5()
    {
        Map<String, Object> hardcodedObject = new Map<String, Object>{
            'Account__c' => '0016C00000ptEGJQ884A2',
                'Account_Owner__c' => '0054X00000Dxb58QAB',
                'Company_Background__c' => '0016C00000ptEGJQA2',
                'Competitors__c' => '',
                'Denial_Reason__c' => '',
                'Description_of_request__c' => '',
                'Existing_vendors_if_applicable__c' => '',
                'Opportunity__c' => '0066C00000H6EKLQA3',
                'Recipient_from_Account__c' => null,
                'Reference_objectives_key_use_cases__c' => '',
                'Status__c' => '',
                'What_activity_do_you_need__c' => '',
                'Who_will_participate__c' => ''
                };
                    list<Object> oList=new list<object>();
        Object obj1 = hardcodedObject;
        oList.add(obj1);
        Test.startTest();
        searchReferencesController.createRecord(oList);
        Test.stopTest();
    }
    @isTest static void fun6()
    {
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where Name=:'taimoor'];
        Test.startTest();
        searchReferencesController.searchContacts(con[0].AccountId);
        Test.stopTest();
        system.debug(con);
        
    }
    @isTest static void fun7()
    {
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where Name=:'taimoor'];
        Reference_Management_Process__c refObj=[select id,Contact__c from Reference_Management_Process__c where Contact__c=:con[0].Id limit 1 ];
        
        string idRef=refObj.Id;
        list<String> idRefList=new list<String>();
        idRefList.add(idRef);
        Test.startTest();
        searchReferencesController.updateReferenceManagmentContacts(con[0].Id,idRefList);
        Test.stopTest();
    }
    @isTest static void fun8()
    {
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where Name=:'taimoor'];
        list<Task> tList=[select Id,whoId from Task where whoId=:con[0].Id];
        string idTsk=tList[0].id;
        list<String> idTskList=new list<String>();
        idTskList.add(idTsk);
        Test.startTest();
        searchReferencesController.updateStatusTask(idTskList,'yes');
        Test.stopTest();
    }    
    @isTest static void fun9()
    {
        list<Contact> con=[select Id,AccountId ,Name,Phone  from Contact where Name=:'taimoor'];
        list<Task> tList=[select Id,whoId from Task where whoId=:con[0].Id];
        string idTsk=tList[0].id;
        list<String> idTskList=new list<String>();
        idTskList.add(idTsk);
        Test.startTest();
        searchReferencesController.updateStatusTask(idTskList,'no');
        Test.stopTest();
    } 
}