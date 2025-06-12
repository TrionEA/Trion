import { LightningElement, api, track } from 'lwc';
import getProposalDetails from '@salesforce/apex/ProposalAdminFeesCompCtrlLWC.getProposalDetails';
import getPicklistValues from '@salesforce/apex/ProposalAdminFeesCompCtrlLWC.getPicklistValues';
import updateProposal from '@salesforce/apex/ProposalAdminFeesCompCtrlLWC.updateProposal';
import isButtonVisibilitySOQLFilter from '@salesforce/apex/ProposalAdminFeesCompCtrlLWC.isButtonVisibilitySOQLFilter';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ProposalAdminFeesCompLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @api buttonvisibilitysoqlFilter;
    @track proposal = {};
    @track isShowAdminFeesModal = false;
    @track isButtonVisible = true;
    @track isLoading = false;

    @track adminFeeTypeOptions = [];
    @track mapDeliveryFeePerLocation = [];
    @track mapPerCheckFrequency = [];

    connectedCallback() {
        this.init();
    }

    toggleLoading(value) {
        this.isLoading = value;
    }

    init() {
        this.toggleLoading(true);
        getProposalDetails({ recordId: this.recordId })
            .then(result => {
                this.proposal = result;
                if (this.buttonvisibilitysoqlFilter) {
                    return isButtonVisibilitySOQLFilter({ 
                        visibilitysoqlFilter: this.buttonvisibilitysoqlFilter, 
                        recordId: this.recordId 
                    });
                }
                return true; // Default visible if no filter
            })
            .then(visible => {
                if (visible !== undefined) {
                    this.isButtonVisible = visible;
                }
            })
            .catch(error => {
                this.showToast('Error', this.reduceErrors(error), 'error');
            })
            .finally(() => {
                this.toggleLoading(false);
            });
    }

    handleShowEditAdminModal() {
        this.toggleLoading(true);
        // Fetch all three picklist values in parallel
        Promise.all([
            getPicklistValues({ objectName: 'Proposal__c', fieldName: 'Administrative_Fee_Type__c' }),
            getPicklistValues({ objectName: 'Proposal__c', fieldName: 'Delivery_Fee_Per_Location__c' }),
            getPicklistValues({ objectName: 'Proposal__c', fieldName: 'Per_Check_Frequency__c' })
        ])
        .then(([adminFeeTypeResult, deliveryFeeResult, perCheckFrequencyResult]) => {
            this.adminFeeTypeOptions = this.mapPicklistResult(adminFeeTypeResult);
            this.mapDeliveryFeePerLocation = this.mapPicklistResult(deliveryFeeResult);
            this.mapPerCheckFrequency = this.mapPicklistResult(perCheckFrequencyResult);
            this.isShowAdminFeesModal = true;
        })
        .catch(error => {
            this.showToast('Error', this.reduceErrors(error), 'error');
        })
        .finally(() => {
            this.toggleLoading(false);
        });
    }

    mapPicklistResult(result) {
        if (!result) return [];
        return Object.keys(result).map(key => ({ label: result[key], value: key }));
    }

    handleCloseEditAdminModal() {
        this.isShowAdminFeesModal = false;
        this.navigateToRecord();
    }

    handleSaveEditAdminModal() {
        // Validate all required fields inside the modal
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, field) => {
                field.reportValidity();
                return validSoFar && field.checkValidity();
            }, true);

        if (!allValid) {
            this.showToast('Error', 'Please fill all required information and try again.', 'error');
            return;
        }

        this.toggleLoading(true);
        updateProposal({ oProposal: this.proposal })
            .then(() => {
                this.showToast('Success', 'Record updated successfully!', 'success');
                this.isShowAdminFeesModal = false;
                this.navigateToRecord();
            })
            .catch(error => {
                this.showToast('Error', this.reduceErrors(error), 'error');
            })
            .finally(() => {
                this.toggleLoading(false);
            });
    }

    // handleChange(event) {
    //     const field = event.target.dataset.id;
    //     if (field) {
    //         this.proposal = { ...this.proposal, [field]: event.target.value };
    //     }
    // }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Proposal__c',
                actionName: 'view'
            }
        });
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) errors = [errors];
        return errors
            .map(e => {
                if (e.body && e.body.message) return e.body.message;
                return e.message || 'Unknown error';
            })
            .join(', ');
    }

    handleChange(event) {
        const field = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this.proposal = { ...this.proposal, [field]: value };
    }

    // getters for displaying values in modal popup
    get isGrossWages() {
        return this.proposal.Administrative_Fee_Type__c == 'Gross Wages';
    }

    get isPerCheck(){
        return this.proposal.Administrative_Fee_Type__c == 'Per Check';
    }

    get isAnnual() {
        return this.proposal.Administrative_Fee_Type__c == 'Annual';
    }

    get isDeliveryAmount(){
        return this.proposal.Delivery_Fee_Per_Location__c == 'Amount';
    }

    // getters for displaying fee values in table
    get adminFeeDisplay() {
        const t = this.proposal.Administrative_Fee_Type__c;
        if (t === 'Gross Wages') return `${(this.proposal.Admin_Fee_Gross_Wages__c * 100).toFixed(2)}%`;
        if (t === 'Annual') return this.toCurrency(this.proposal.Admin_Fee_Annual__c);
        if (t === 'Per Check') return this.toCurrency(this.proposal.Admin_Fee_Per_Check__c);
        return '';
    }

    get deliveryFeeDisplay() {
        return this.proposal.Delivery_Fee_Per_Location__c === 'Amount'
            ? this.toCurrency(this.proposal.Delivery_Fee__c)
            : 'Cost';
    }

    get securityDepositDisplay() {
        return this.proposal.Security_Deposit_Waived__c ? 'Waived' : this.proposal.Security_Deposit__c;
    }

    get clientSetupFeeDisplay() {
        return this.proposal.Client_Set_up_Fee_Waived__c ? 'Waived' : this.proposal.Client_Set_up_Fee__c;
    }

    get newHireFeeDisplay() {
        return this.proposal.Employee_New_Hire_Fee_Waived__c ? 'Waived' : this.proposal.Employee_New_Hire_Fee_Per_Employee__c;
    }

    get epliDisplay() {
        return this.proposal.EPLI_Waived__c ? 'Waived' : this.proposal.Employment_Practice_Liability_Insurance__c;
    }

    get epliDeductibleDisplay() {
        return this.proposal.EPLI_50_000_Deductible_Waived__c ? 'Waived' : this.toCurrency(this.proposal.EPLI_50_000_Deductible__c);
    }

    get wcFeeMaxDisplay() {
        return this.proposal.Worker_s_Compensation_Claims_Fee_waived__c ? 'Waived' : this.proposal.Worker_s_Compensation_Claims_Fee_Max__c;
    }

    get wcFeeDepositDisplay() {
        return this.proposal.Worker_s_Comp_Claims_Fee_Deposit_Waived__c ? 'Waived' : this.proposal.Worker_s_Compensation_Claims_Fee_Deposit__c;
    }

    toCurrency(val) {
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(val);
    }
}