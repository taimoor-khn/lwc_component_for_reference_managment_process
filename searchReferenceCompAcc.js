import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchContacts from "@salesforce/apex/searchReferenceCompAccController.searchContacts";
import accRecord from "@salesforce/apex/searchReferenceCompAccController.accRecord";
import createRecord from "@salesforce/apex/searchReferenceCompAccController.createRecord";
import updateReferenceManagmentContacts from "@salesforce/apex/searchReferenceCompAccController.updateReferenceManagmentContacts";
import updateStatusTask from "@salesforce/apex/searchReferenceCompAccController.updateStatusTask";
import { CloseActionScreenEvent } from 'lightning/actions';
export default class SearchReferenceCompAcc extends LightningElement {
    @track isModalOpen = true;
    @track selectContactForm = false;
    @track verifyContactForm = false;
    @track isLoaded = false;
    @track savedIdRefList = []
    @track savedIdTaskList = []
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
    @api recordId;
    @track conRecordList = [];
    @track accRecordList = []
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
    connectedCallback() {
        setTimeout(() => {
            accRecord({ accId: this.recordId }).then((result) => {
                this.accRecordList = result;
                console.log(this.accRecordList)
            })
        }, 5);

    }

    inputReferenceForm(event) {
        if (event.target.name === 'acc') {
            this.refRecordList[0].acc = event.target.value;
        }
        else if (event.target.name === 'des') {
            this.refRecordList[0].des = event.target.value;
        }
        else if (event.target.name === 'refA') {
            this.refRecordList[0].refA = event.target.value;
        }
        else if (event.target.name === 'wADYN') {
            this.refRecordList[0].wADYN = event.target.value;
        } else if (event.target.name === 'sts') {
            this.refRecordList[0].sts = event.target.value;
        }

    }
    handleCreate() {
        this.isLoaded = true;
        if (this.refRecordList[0].acc === "" || this.refRecordList[0].accO === ""
            || this.refRecordList[0].rec === "" || this.refRecordList[0].compB === "") {
            this.refRecordList[0].acc = this.accRecordList.Id
            this.refRecordList[0].accO = this.accRecordList.OwnerId
            this.refRecordList[0].compB = this.accRecordList.Id
            if (this.accRecordList.Owner.isActive === "True") {
                this.refRecordList[0].rec = this.accRecordList.CSM__c
            }
            else {
                this.refRecordList[0].rec = this.accRecordList.OwnerId
            }

        }

        searchContacts({ accId: this.recordId }).then((result) => {
            if (result.length != 0) {
                this.conRecordList = result;
                console.log('r' + this.conRecordList)
                this.isModalOpen = false

                this.selectContactForm = true

            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error : Contact Record Not Available',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        })

        createRecord({ objList: this.refRecordList }).then((result) => {
            this.savedIdRefList = result;
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Reference Management Record is created',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('f' + result)
        })
        this.isLoaded = false
    }

    @track allContactofAccount = [];
    handleSelectContact() {
        this.isLoaded = true;
        var selectedRecordsofCon = this.template.querySelector("lightning-datatable").getSelectedRows();
        if (selectedRecordsofCon.length > 0) {
            this.allContactofAccount = selectedRecordsofCon
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
                    this.isLoaded = false
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error : Record Not Available',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }

            }).catch((error) => {
                this.isLoaded = false
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
                message: 'Select the Record',
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
