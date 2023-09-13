import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import conRecord from "@salesforce/apex/searchReferenceCompConController.conRecord";
import createRecord from "@salesforce/apex/searchReferenceCompConController.createRecord";
import { CloseActionScreenEvent } from 'lightning/actions';
export default class SearchReferenceCompCon extends LightningElement {
    @track conRecordList = []
    @track isLoaded = false;
    @track isModalOpen = true;
    @track refRecordList =
        [
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
    @api recordId;
    connectedCallback() {
        this.isLoaded = true
        setTimeout(() => {
            conRecord({ conId: this.recordId }).then((result) => {
                this.conRecordList = result;
                this.isLoaded = false
                console.log(this.conRecordList)
            })
        }, 5);

    }
    inputReferenceForm(event) {
        if (event.target.name === 'des') {
            this.refRecordList[0].des = event.target.value;
        }
        else if (event.target.name === 'refA') {
            this.refRecordList[0].refA = event.target.value;
        }
        else if (event.target.name === 'wADYN') {
            this.refRecordList[0].wADYN = event.target.value;
        }

    }
    handleCreate() {
        this.isLoaded = true
        console.log('account' + this.conRecordList)
        if (this.refRecordList[0].con === "" || this.refRecordList[0].acc === "" ||
            this.refRecordList[0].accO === "" || this.refRecordList[0].rec === "" || this.refRecordList[0].compB === "") {
            this.refRecordList[0].con = this.conRecordList.Id
            this.refRecordList[0].acc = this.conRecordList.AccountId
            this.refRecordList[0].accO = this.conRecordList.Account.OwnerId
            this.refRecordList[0].compB = this.conRecordList.AccountId
            console.log(this.conRecordList.Account.Owner)
            if (this.conRecordList.Account.Owner.isActive === "True") {
                this.refRecordList[0].rec = this.conRecordList.Account.CSM__c
            }
            else {
                this.refRecordList[0].rec = this.conRecordList.Account.OwnerId
            }
        }
        createRecord({ objList: this.refRecordList }).then((result) => {
            if (result.length != 0) {
                this.isLoaded = false
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Reference Management Record is created',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
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

            console.log('f' + result)
        })
            .catch((error) => {
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
}