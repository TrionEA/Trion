import { LightningElement,track,api,wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//apexclasses
import getObjectName from '@salesforce/apex/ClientContactsCompCtrl.getObjectName';
import getOpportunityDetails from '@salesforce/apex/ClientContactsCompCtrl.getOpportunityDetails';
import getProposalDetails from '@salesforce/apex/ClientContactsCompCtrl.getProposalDetails';
import getClientContacts from '@salesforce/apex/ClientContactsCompCtrl.getClientContacts';
import getStatePicklistValues from '@salesforce/apex/ClientContactsCompCtrl.getStatePicklistValues';
import getClientLocationPicklistValues from '@salesforce/apex/ClientContactsCompCtrl.getClientLocationPicklistValues';
import getPicklistValues from '@salesforce/apex/ClientContactsCompCtrl.getPicklistValues';
import createClientContacts from '@salesforce/apex/ClientContactsCompCtrl.createClientContacts';
import saveClientContacts from '@salesforce/apex/ClientContactsCompCtrl.saveClientContacts';
import deleteClientContacts from '@salesforce/apex/ClientContactsCompCtrl.deleteClientContacts';
import getNewClientLocation from '@salesforce/apex/ClientContactsCompCtrl.getNewClientLocation';
import createClientLocation from '@salesforce/apex/ClientContactsCompCtrl.createClientLocation';
import getClientLocationValue from '@salesforce/apex/ClientContactsCompCtrl.getClientLocationValue';
import getClientContactRecord from '@salesforce/apex/ClientContactsCompCtrl.getClientContactRecord';
import isButtonVisibilitySOQLFilter from '@salesforce/apex/ClientContactsCompCtrl.isButtonVisibilitySOQLFilter';

export default class ClientContactsComplwc extends LightningElement {
  
//inputs--------------------------------------------------------------------------
//tracking
    @track showMainModal = false; //for main modal
    @track isShowsubmodal=false; //sub modal
    @track isShow =false; //for conditional checkbox view
@track selectedLocation='None';
    //form data
    @track isIncluded = false;//for checkbox
    @track isPrimary = false;
    @track selectedtype='';//picklist
    
    
    typeoptions = [];
        @api recordId='';
        @track stateOptions = []; //for state

        @track locationOptions = []; // for locations

    //Data table
      @track lstClientContacts = [];
    @track columns = []; // define columns properly
    @track draftValues = [];
    @track sortedBy = '';
    @track sortedDirection = 'asc';
    @track isHideCheckboxColumn = false;
    @track errors;

    isLoading = false; // for spinner

    columns = [
        { label: 'First Name', fieldName: 'firstname', type: 'text' },
          { label: 'Last Name', fieldName: 'lastname', type: 'text' },
            { label: 'Email', fieldName: 'email', type: 'text' },
              { label: 'Title/Relationship', fieldName: 'title', type: 'text' },
        { label: 'Phone', fieldName: 'phone', type: 'text' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                     { label: 'Edit', name: 'Edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    @api opp; // from parent (contains opp.Proposal__c)
    @track selectedState;
    @track stateOptions = [];
    @track wcRateWhereClause;
    //@track mapClientLocationPicklistValues = [];
//spinner
    @track isLoading = false;
//type picklist
    @track selectedClientContactType;
    @track selectedTitle;
    @track isShowMobilePhone = false;
//wc code
  @track selectedStampCode;

//form fields
@track contact = {
        //clientContactId: '',
        firstName: '',
        lastName: '',
        titleRelationship: '',
        email: '',
        phone: '',
        isIncluded: false,
        isPrimary: false,
        ownership: null,
        selectedState : 'None',
        payroll: null,
        selectedClientLocation: '',
        selectedStampCode: '',
        birthdate: null,
        duties: '',
        //clientContactType: ''
    };
//sub modal data
 @track submodalData = {
        locNumber: '', // or you can use a default value or number if needed
        street: '',
        city: '',
        zipCode: ''
    };


//model Handlers
    showMainModel(){
        this.showMainModal = true;
    }
    closeMainModal(){
        this.showMainModal = false;
    }
    openModal() {
        
        this.showMainModal = true;
    }
     openSubModal() {
        this.isShowsubmodal = true;
        this.showMainModal=false;
    }
    closeSubModal() {
        this.isShowsubmodal = false;
        this.showMainModal=true;

    }
    

    //picklist type method
    // Wire Apex method

    @wire(getPicklistValues, { objectName: '$objectName', fieldName: '$fieldName' })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.contactTypeOptions = Object.keys(data).map(key => ({
                label: data[key],
                value: key
            }));
            console.log('Fetched picklist values:', this.contactTypeOptions);
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }
    handleClientContactTypeChange(event) {
        this.selectedClientContactType = event.detail.value;
        console.log('Selected client contact type:', this.selectedClientContactType);

        if (
            this.selectedClientContactType === 'Inspection' ||
            this.selectedClientContactType === 'Accting Record' ||
            this.selectedClientContactType === 'Claims Info'
        ) {
            this.showMobilePhone = true;
        } else {
            this.showMobilePhone = false;
        }
    }
    

    
    // Input Handlers dynamically
     handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this.contact = { ...this.contact, [field]: value };
        console.log('contact', this.contact);
    }
    // Save button logic
    // Handles save from main modal
handleMainModalSave() {
    console.log('triggered by modal');
    this.handlecontactSave();
}

// Handles save from submodal
handleSubModalSave() {
    this.handleClientLocationSave();
}
//fetch record id
connectedCallback() {
    console.log('Component connectedcallback loaded');

    if (this.recordId) {
        Promise.all([
            getProposalDetails({ recordId: this.recordId }),
            getOpportunityDetails({ recordId: this.recordId }),
            getObjectName({recordId:this.recordId})
        ])
        .then(([proposalResult, opportunityResult,objectNameresult]) => {
            console.log('Fetched Proposal:', proposalResult);
            console.log('Fetched Opportunity:', opportunityResult);
            console.log('Fetched objectNameresult:', objectNameresult);


            
            this.proposal = proposalResult;
            this.opp = opportunityResult;
             this.objectName = objectNameresult;

            if (this.opp?.Proposal__c && this.selectedState) {
                this.fetchClientLocations();
            }
        })
        .catch(error => {
            console.error('Error fetching Proposal or Opportunity or objectname:', error);
        });
    } else {
        console.warn('recordId not defined. Skipping data fetch.');
    }
}

    
    handlecontactSave() {
        console.log('handlecontactSave triggered');
        this.contact.selectedState = this.selectedState;
        this.contact.selectedStampCode = this.selectedStampCode;
        //this.contact.selectedClientLocation = this.selectedLocation
        this.contact.isPrimary=this.isPrimary;
        this.contact.isIncluded=this.isIncluded;
        const payload = JSON.stringify(this.contact);
        console.log('payload', payload);
        // You must pass the Opportunity record (either from recordId or context)
        createClientContacts({ jsonWrapper: payload, opp: this.opp })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Client Contact saved successfully',
                        variant: 'success'
                    })
                );
                 this.showMainModal = false; // If you're closing modal after save
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving Client Contact',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    

   
    // Taking inputs section1
      handlePrimaryIncludeChange(event) {
        const label = event.target.label;
      
        if (label === 'Officer/Owner') {
            this.isIncluded = event.target.checked;
            if(this.isIncluded)
            this.isShow = true;
            else
            this.isShow = false;
        } else if (label === 'Primary') {
            this.isPrimary = event.target.checked;
        }
    }

   // Row Action Handler
     handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'view':
                console.log('View record', row);
                break;
            case 'delete':
                console.log('Delete record', row);
                break;
            default:
                console.log('Unknown action', actionName);
        }
    }
    
  

//statepicklist
@wire(getStatePicklistValues)
wiredStatePicklistValues({ error, data }) {
    if (data) {
        console.log('State Picklist Data:', data); 
        this.stateOptions = Object.keys(data).map((key) => ({
            label: data[key],
            value: key
        }));
    } else if (error) {
        console.error('Error loading state picklist:', error);
    }
}

    handleStateChange(event) {
        this.selectedState = event.target.value;
        this.wcRateWhereClause = ` State__c = '${this.selectedState}'`;
        // if (this.selectedState && this.opp?.Proposal__c) {
        //     this.fetchClientLocations();
        // } else {
        //     console.warn('Missing ProposalId or State. Skipping fetch.');
        // }
       
    }

//wc code lookup
 handleWcCodeChange(event) {
        this.selectedStampCode = event.detail.recordId;
        console.log('Selected WC Code Id:', this.selectedStampCode);
    }
    
    //fetching locations

    // WIRE: Get Proposal Details
@wire(getProposalDetails, { recordId: '$recordId' })
wiredProposal({ error, data }) {
    if (data) {
        this.proposal = data;
        console.log('Fetched Proposal:', data);
                console.log('Fetched Proposal:', recordId);

        this.checkAndFetchClientLocations();
    } else if (error) {
        console.error('Error fetching Proposal:', error);
    }
}

// WIRE: Get Opportunity Details
@wire(getOpportunityDetails, { recordId: '$recordId' })
wiredOpportunity({ error, data }) {
    if (data) {
        this.opp = data;
        console.log('Fetched Opportunity:', data);
        this.checkAndFetchClientLocations();
    } else if (error) {
        console.error('Error fetching Opportunity:', error);
    }
}

// WIRE: Get Object Name
@wire(getObjectName, { recordId: '$recordId' })
wiredObjectName({ error, data }) {
    if (data) {
        this.objectName = data;
        console.log('Fetched Object Name:', data);
    } else if (error) {
        console.error('Error fetching Object Name:', error);
    }
}
checkAndFetchClientLocations() {
    if (this.opp?.Proposal__c && this.selectedState) {
        console.log('ProposalId:', this.opp.Proposal__c);
        console.log('Selected State:', this.selectedState);
        this.fetchClientLocations();
    } else {
        console.warn('ProposalId or Selected State not defined. Fetch skipped.');
        console.log('ProposalId:', this.opp?.Proposal__c);
        console.log('Selected State:', this.selectedState);
    }
}
    // Fetch client locations
    fetchClientLocations() {
        console.log('fetchClientLocations() called');
        console.log('ProposalId:', this.opp?.Proposal__c);
        console.log('Selected State:', this.selectedState);

        if (!this.opp?.Proposal__c || !this.selectedState) {
            console.warn('Missing ProposalId or State');
            this.locationOptions = [];
            return;
        }

        this.isLoading = true;
        getClientLocationPicklistValues({
            proposalId: this.opp.Proposal__c,
            stateId: this.selectedState
        })
            .then((result) => {
                console.log('Fetched locations:', result);
                if (result && Object.keys(result).length > 0) {
                    this.locationOptions = Object.keys(result).map(key => ({
                        label: result[key],
                        value: key
                    }));
                } else {
                    this.locationOptions = [];
                    console.warn('No locations found.');
                }
            })
            .catch((error) => {
                console.error('Error fetching client locations:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || error.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
// locations selection methos
handleLocationChange(){
     this.selectedLocation=event.detail.value;
       console.log('selectedLocation 1',this.selectedLocation);
    this.selectedLocation=this.contact.selectedClientLocation;
       console.log('selectedLocation2',this.selectedLocation);
       
}

}