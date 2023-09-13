import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchAccounts from "@salesforce/apex/searchReferencesController.searchAccounts";
import oppRecord from "@salesforce/apex/searchReferencesController.oppRecord";
import createRecord from "@salesforce/apex/searchReferencesController.createRecord";
import searchContacts from "@salesforce/apex/searchReferencesController.searchContacts";
import updateReferenceManagmentContacts from "@salesforce/apex/searchReferencesController.updateReferenceManagmentContacts";
import updateStatusTask from "@salesforce/apex/searchReferencesController.updateStatusTask";

export default class SearchReferenceComp extends LightningElement {
    @track isLoaded = false;
    @api recordId;
    @track selectContactForm = false;
    @track verifyContactForm = false;
    @track openCreateForm = false;
    @track openDatTable = false;
    @track conRecordList = [];
    @track obj = {
        id: 0,
        accId: '',
        Name: '',
        Country: '',
        Health: '',
        Referenceable: '',
        OwnerId: '',
        OwnerIsActive: '',
        CSM_c: ''

    };
    @track oppRecordList = []
    @track savedIdRefList = []
    @track savedIdTaskList = []
    @track refRecordList = [
        {
            id: 0,
            acc: '',
            accO: '',
            compB: '',
            comp: '',
            con: '',
            den: '',
            des: '',
            exi: '',
            opp: '',
            pro: '',
            rec: '',
            refA: '',
            refM: '',
            refO: '',
            stg: '',
            sts: '',
            wADYN: '',
            wWP: ''
        }
    ]
    @track columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Health', fieldName: 'Account_Health__c', type: 'text' },
        { label: 'Referenceable', fieldName: 'Referenceable__c', type: 'text' },
        { label: 'Country', fieldName: 'BillingCountry', type: 'text' },
        // Add more columns as needed
    ];
    @track conColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Account', fieldName: 'AccountId', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'text' }
        // Add more columns as needed
    ];

    @track optionsVerify =
        [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' },
        ];
    @track selectedRowsofAll = [
        {
            id: 0,
            accId: '',
            Name: '',
            Country: '',
            Health: '',
            Referenceable: '',
            OwnerId: '',
            OwnerIsActive: '',
            CSM_c: ''
        }
    ];
    @track isModalOpen = true;
    @track accountData = [];
    @track itemList = [
        {
            id: 0,
            Name: '',
            Country: '',
            Industry: '',
            ServicingLead: '',
            ServicingPartner: '',
            InstanceType: ''

        }
    ];

    inputChange(event) {
        if (event.target.name === 'Name') {
            this.itemList[0].Name = event.target.value;
            console.log(this.itemList[0].Name)
        }
        else if (event.target.name === 'Country') {
            this.itemList[0].Country = event.target.value;

        }
        else if (event.target.name === 'Industry') {
            this.itemList[0].Industry = event.target.value;
            console.log(this.itemList[0].Industry)
        }
        else if (event.target.name === 'ServicingLead') {
            this.itemList[0].ServicingLead = event.target.value;
            console.log(this.itemList[0].ServicingLead)
        }
        else if (event.target.name === 'ServicingPartner') {
            this.itemList[0].ServicingPartner = event.target.value;
            console.log(this.itemList[0].ServicingPartner)
        }
        else if (event.target.name === 'InstanceType') {
            this.itemList[0].InstanceType = event.target.value;
            console.log(this.itemList[0].InstanceType)
        }
    }
    closeModal() {

        this.isModalOpen = false;
    }
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleSearch() {

        this.isLoaded = true;
        console.log(this.itemList)
        searchAccounts({ lstring: this.itemList }).then((result) => {
            console.log(result.detail)
            if (result.length != 0) {
                this.openDatTable = true;
                this.accountData = result;
                this.isLoaded = false
                this.isModalOpen = false;
            }
            else {
                this.isLoaded = false
                console.log('null')
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Record Not Availabe',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }

        })
            .catch((error) => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'error.body.message' + error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
    }



    handleNext() {
        this.isLoaded = true
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        if (selectedRecords.length > 0) {
            console.log('selectedRecords are ', selectedRecords);

            let i = 0;
            selectedRecords.forEach(currentItem => {
                console.log('current' + currentItem.Owner.IsActive);
                if (i === 0) {
                    this.obj.accId = currentItem.Id;
                    this.obj.Name = currentItem.Name;
                    this.obj.Country = currentItem.BillingCountry;
                    this.obj.Health = currentItem.Account_Health__c;
                    this.obj.Referenceable = currentItem.Referenceable__c;
                    if (currentItem.Owner.IsActive === 'true') {
                        this.obj.CSM_c = currentItem.OwnerId;
                    }
                    else {
                        this.obj.CSM_c = currentItem.CSM__c;
                    }
                    this.obj.OwnerIsActive = currentItem.Owner.IsActive;

                    this.obj.OwnerId = currentItem.OwnerId;
                }
                this.selectedRowsofAll[i].accId = currentItem.Id;
                this.selectedRowsofAll[i].Name = currentItem.Name;
                this.selectedRowsofAll[i].Country = currentItem.BillingCountry;
                this.selectedRowsofAll[i].Health = currentItem.Account_Health__c;
                this.selectedRowsofAll[i].Referenceable = currentItem.Referenceable__c;
                if (currentItem.Owner.IsActive === 'true') {
                    this.selectedRowsofAll[i].CSM_c = currentItem.OwnerId;
                }
                else {
                    this.selectedRowsofAll[i].CSM_c = currentItem.CSM__c;
                }
                this.selectedRowsofAll[i].OwnerIsActive = currentItem.Owner.IsActive;
                this.selectedRowsofAll[i].OwnerId = currentItem.OwnerId;
                i++;
            });
            console.log('owner' + this.obj.OwnerId)
            this.openDatTable = false;
            this.openCreateForm = true;
            console.log(this.selectedRowsofAll)
            console.log(this.recordId)
            oppRecord({ oppid: this.recordId }).then((result) => {
                this.oppRecordList = result;
                console.log(this.oppRecordList)
            })
            this.isLoaded = false;
        }
        else {
            this.isLoaded = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Select the Record',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }

    }

    inputReferenceForm(event) {
        if (event.target.name === 'acc') {
            this.refRecordList[0].acc = event.target.value;
        }
        else if (event.target.name === 'accO') {
            this.refRecordList[0].accO = event.target.value;
        }
        else if (event.target.name === 'compB') {
            this.refRecordList[0].compB = event.target.value;
        }
        else if (event.target.name === 'comp') {
            this.refRecordList[0].comp = event.target.value;
        }
        else if (event.target.name === 'con') {
            this.refRecordList[0].con = event.target.value;
        }
        else if (event.target.name === 'den') {
            this.refRecordList[0].den = event.target.value;
        }
        else if (event.target.name === 'des') {
            this.refRecordList[0].des = event.target.value;
        }
        else if (event.target.name === 'exi') {
            this.refRecordList[0].exi = event.target.value;
        }
        else if (event.target.name === 'opp') {
            this.refRecordList[0].opp = event.target.value;
        }
        else if (event.target.name === 'pro') {
            this.refRecordList[0].pro = event.target.value;
        }
        else if (event.target.name === 'rec') {
            this.refRecordList[0].rec = event.target.value;
        }
        else if (event.target.name === 'refA') {
            this.refRecordList[0].refA = event.target.value;
        }
        else if (event.target.name === 'refM') {
            this.refRecordList[0].refM = event.target.value;
        }
        else if (event.target.name === 'refO') {
            this.refRecordList[0].refO = event.target.value;
        }
        else if (event.target.name === 'sts') {
            this.refRecordList[0].sts = event.target.value;
        }
        else if (event.target.name === 'stg') {
            this.refRecordList[0].stg = event.target.value;
        }
        else if (event.target.name === 'wADYN') {
            this.refRecordList[0].wADYN = event.target.value;
        }
        else if (event.target.name === 'wWP') {
            this.refRecordList[0].wWP = event.target.value;
        }

    }

    handleCreateReference() {
        this.isLoaded = true;
        console.log('==' + this.oppRecordList.OwnerId)
        if (this.refRecordList[0].acc === "" || this.refRecordList[0].accO === "" || this.refRecordList[0].compB === "" || this.refRecordList[0].opp === ""
            || this.refRecordList[0].pro === "" || this.refRecordList[0].rec === "" || this.refRecordList[0].refM === "" || this.refRecordList[0].stg === "") {

            this.refRecordList[0].acc = this.obj.accId
            this.refRecordList[0].accO = this.obj.OwnerId
            this.refRecordList[0].compB = this.obj.accId
            this.refRecordList[0].opp = this.oppRecordList.Id
            this.refRecordList[0].pro = this.oppRecordList.Relationship_with_Prospect__c
            this.refRecordList[0].rec = this.obj.CSM_c
            //this.refRecordList[0].refM=
            this.refRecordList[0].stg = this.oppRecordList.StageName
        }

        if (this.selectedRowsofAll.length > 0) {

            for (let k = 1; k < this.selectedRowsofAll.length; k++) {
                this.refRecordList[k].acc = this.selectedRowsofAll[k].accId
                this.refRecordList[k].accO = this.refRecordList[0].accO
                this.refRecordList[k].compB = this.selectedRowsofAll[k].accId
                this.refRecordList[k].comp = this.refRecordList[0].comp
                this.refRecordList[k].con = this.refRecordList[0].con
                this.refRecordList[k].den = this.refRecordList[0].den
                this.refRecordList[k].des = this.refRecordList[0].des
                this.refRecordList[k].exi = this.refRecordList[0].exi
                this.refRecordList[k].opp = this.refRecordList[0].opp
                this.refRecordList[k].pro = this.refRecordList[0].pro
                this.refRecordList[k].rec = this.refRecordList[0].rec
                this.refRecordList[k].refA = this.refRecordList[0].refA
                this.refRecordList[k].refM = this.refRecordList[0].refM
                this.refRecordList[k].refO = this.refRecordList[0].refO
                this.refRecordList[k].stg = this.oppRecordList.StageName//opportunity stage direct
                this.refRecordList[k].sts = this.refRecordList[0].sts
                this.refRecordList[k].wADYN = this.refRecordList[0].wADYN
                this.refRecordList[k].wWP = this.refRecordList[0].wWP

            }
        }
        console.log(this.refRecordList)
        createRecord({ objList: this.refRecordList }).then((result) => {
            this.savedIdRefList = result;
            console.log(result)
            this.isLoaded = false;
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Successfully Inserted',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

            this.isLoaded = true;
            searchContacts({ accId: this.obj.accId }).then((result) => {
                if (result.length != 0) {
                    this.conRecordList = result;
                    console.log(this.oppRecordList)
                    this.isLoaded = false
                    this.openCreateForm = false;
                    this.selectContactForm = true;
                } else {
                    this.isLoaded = false
                    console.log('null')
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Contact related Account Record Not Availabe',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }

            })
        }).catch((error) => {
            this.isLoaded = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error :' + error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });

    }
    @track allContactofAccount = [];
    handleSelectContact() {
        this.isLoaded = true;
        var selectedRecordsofCon = this.template.querySelector("lightning-datatable").getSelectedRows();
        if (selectedRecordsofCon.length > 0) {
            console.log('selectedRecords are ', selectedRecordsofCon);
            this.allContactofAccount = selectedRecordsofCon
            //for(let k=0;k<this.selectedRowsofAll.length;k++)
            //{
            //  this.refRecordList[k].con=this.allContactofAccount[0].Id;
            //}
            updateReferenceManagmentContacts({ ContactIds: this.allContactofAccount[0].Id, idRefSavedList: this.savedIdRefList }).then((result) => {
                if (result.length != 0) {
                    this.isLoaded = false;
                    this.savedIdTaskList = result;
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.selectContactForm = false;
                    this.verifyContactForm = true;
                }
                else {
                    this.isLoaded = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error : Record Not Available',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }

            }).catch((error) => {
                this.isLoaded = false;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error :' + error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });

        }
        else {
            this.isLoaded = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error : Select the record',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }
    @track verifyVar;
    handleCheck(event) {
        console.log(event.target.value)
        if (event.target.value === 'yes') {
            this.verifyVar = event.target.value
        }
        else if (event.target.value === 'no') {
            this.verifyVar = event.target.value

        }
    }

    handleVerifyContact() {
        this.isLoaded = true;
        if (this.verifyVar === 'yes') {
            updateStatusTask({ tskIdList: this.savedIdTaskList, con: this.verifyVar }).then((result) => {
                console.log(result)
                if (result.length != 0) {
                    this.isLoaded = false;
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
                .catch((error) => {
                    this.isLoaded = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error :' + error.body.message,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                });

        }
        else if (this.verifyVar === 'no') {
            updateStatusTask({ tskIdList: this.savedIdTaskList, con: this.verifyVar }).then((result) => {
                console.log(result)
                if (result.length != 0) {
                    this.isLoaded = false;
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
                .catch((error) => {
                    this.isLoaded = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error :' + error.body.message,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                });

        }

    }
}