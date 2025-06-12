import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// Apex Methods
import isButtonVisibilitySOQLFilter from '@salesforce/apex/ClientEmployeeCtrl.isButtonVisibilitySOQLFilter';
import getObjectName from '@salesforce/apex/ClientEmployeeCtrl.getObjectName';
import getOpportunityDetails from '@salesforce/apex/ClientEmployeeCtrl.getOpportunityDetails';
import getProposalDetails from '@salesforce/apex/ClientEmployeeCtrl.getProposalDetails';
import getProposalSUTAQuoteRecords from '@salesforce/apex/ClientEmployeeCtrl.getProposalSUTAQuoteRecords';
import getStates from '@salesforce/apex/ClientEmployeeCtrl.getStates';
import deleteSUTAQuoteRecords from '@salesforce/apex/ClientEmployeeCtrl.deleteSUTAQuoteRecords';
import submitClientInfo from '@salesforce/apex/ClientEmployeeCtrl.submitClientInfo';

export default class ClientEmployeeInfo extends LightningElement {
    @api recordId;
    @api buttonvisibilitysoqlFilter;

    // Tracked properties
    @track isLoading = false;
    @track showSpinner = false;
    @track isButtonVisible = true;
    @track sObjectName = '';
    @track opp = {};
    @track oProposal = {};
    @track lstSUTAQuotes = [];
    @track columns = [];
    @track selectedRows = [];
    @track sortedBy = 'State_Name__c';
    @track sortedDirection = 'asc';
    @track isAddEmployeeInfoModal = false;
    @track isDelete = false;
    @track isShowCheckboxColumn = true;
    @track isModalLoading = false;
    
    // Modal form fields
    @track mapStateOptions = [];
    @track selectedStateId = '';
    @track numberOfEmployees = '';
    @track grossWages = '';

    // Wired data
    wiredSUTAQuotesResult;

    connectedCallback() {
        this.handleInitialization();
    }

    async handleInitialization() {
        try {
            await this.fetchObjectName();
            this.createDataTableHeaders();
            await this.checkButtonVisibility();
        } catch (error) {
            this.handleError(error);
        }
    }

    async checkButtonVisibility() {
        if (!this.buttonvisibilitysoqlFilter) return;
        
        this.showSpinner = true;
        try {
            const result = await isButtonVisibilitySOQLFilter({
                visibilitysoqlFilter: this.buttonvisibilitysoqlFilter,
                recordId: this.recordId
            });
            this.isButtonVisible = result;
        } catch (error) {
            this.handleError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    async fetchObjectName() {
        this.showSpinner = true;
        try {
            const result = await getObjectName({ recordId: this.recordId });
            this.sObjectName = result;
            
            if (result === 'opportunity') {
                await this.fetchOpportunityDetails();
            } else {
                await this.fetchProposalDetails(this.recordId);
            }
        } catch (error) {
            this.handleError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    async fetchOpportunityDetails() {
        this.showSpinner = true;
        try {
            const result = await getOpportunityDetails({ recordId: this.recordId });
            this.opp = result;
            
            if (result.Proposal__c) {
                await this.fetchProposalDetails(result.Proposal__c);
            }
        } catch (error) {
            this.handleError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    async fetchProposalDetails(recordId) {
        this.showSpinner = true;
        try {
            const result = await getProposalDetails({ recordId: recordId });
            this.oProposal = result;
            await this.fetchProposalSUTAQuoteRecords(result.Id);
        } catch (error) {
            this.handleError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    async fetchProposalSUTAQuoteRecords(proposalId) {
        this.showSpinner = true;
        try {
            const result = await getProposalSUTAQuoteRecords({ proposalId: proposalId });
            this.lstSUTAQuotes = result || [];
            
            if (result && result.length > 0) {
                this.sortedBy = 'State_Name__c';
                this.sortedDirection = 'asc';
                this.sortData('State_Name__c', 'asc');
            }
        } catch (error) {
            this.handleError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    createDataTableHeaders() {
        this.columns = [
            {
                label: 'State',
                fieldName: 'State_Name__c',
                type: 'text',
                sortable: true,
                editable: false
            },
            {
                label: '# of Employees',
                fieldName: 'of_Employees__c',
                type: 'number',
                sortable: true,
                editable: false,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Gross Wages',
                fieldName: 'Gross_Wages__c',
                type: 'currency',
                sortable: true,
                editable: false,
                cellAttributes: { alignment: 'left' }
            }
        ];
    }

    async deleteSUTAQuotes() {
        this.showSpinner = true;
        try {
            await deleteSUTAQuoteRecords({ lstSUTAQuote: this.selectedRows });
            
            // Reset selections and refresh data
            this.template.querySelector('lightning-datatable').selectedRows = [];
            this.selectedRows = [];
            this.isDelete = false;
            this.isShowCheckboxColumn = true;
            
            await this.handleInitialization();
            this.showToast('Success', 'Records deleted successfully!', 'success');
        } catch (error) {
            this.handleError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    async createClientInfo() {
        this.showSpinner = true;
        try {
            let oppId;
            if (this.sObjectName === 'opportunity') {
                oppId = this.opp.Id;
            } else {
                oppId = this.oProposal.Opportunity__c;
            }

            await submitClientInfo({
                opportunityId: oppId,
                proposalId: this.oProposal.Id,
                stateId: this.selectedStateId,
                numberOfEmployees: parseInt(this.numberOfEmployees),
                grossWages: parseFloat(this.grossWages)
            });

            this.isAddEmployeeInfoModal = false;
            this.resetFormFields();
            await this.handleInitialization();
            this.showToast('Success', 'Client Employee Info added successfully!', 'success');
        } catch (error) {
            this.handleError(error);
        } finally {
            this.showSpinner = false;
        }
    }

    async loadStateOptions() {
        try {
            const result = await getStates();
            this.mapStateOptions = Object.keys(result).map(key => ({
                label: result[key],
                value: key
            }));
        } catch (error) {
            this.handleError(error);
        }
    }

    resetFormFields() {
        this.mapStateOptions = [];
        this.selectedStateId = '';
        this.numberOfEmployees = '';
        this.grossWages = '';
    }

    // Event Handlers
    handleColumnSorting(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.sortData(fieldName, sortDirection);
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    async handleAddRecords() {
        this.resetFormFields();
        await this.loadStateOptions();
        this.isAddEmployeeInfoModal = true;
    }

    handleDeleteRecords() {
        this.selectedRows = [];
        this.isDelete = true;
        this.isShowCheckboxColumn = false;
    }

    handlePerformDeleteRecords() {
        if (this.selectedRows && this.selectedRows.length > 0) {
            this.deleteSUTAQuotes();
        } else {
            this.showToast('Error', 'Please select at least one record to delete.', 'error');
        }
    }

    handleCancel() {
        if (this.template.querySelector('lightning-datatable')) {
            this.template.querySelector('lightning-datatable').selectedRows = [];
        }
        this.selectedRows = [];
        this.isDelete = false;
        this.isShowCheckboxColumn = true;
        this.isAddEmployeeInfoModal = false;
        this.resetFormFields();
    }

    async handleAddClientEmployeeInfo() {
        // Validate form inputs
        if (!this.selectedStateId) {
            this.showToast('Error', 'Please select a state.', 'error');
            return;
        }

        if (!this.numberOfEmployees || parseInt(this.numberOfEmployees) <= 0) {
            this.showToast('Error', 'Please enter a valid number of employees.', 'error');
            return;
        }

        if (!this.grossWages || parseFloat(this.grossWages) <= 0) {
            this.showToast('Error', 'Please enter a valid gross wages amount.', 'error');
            return;
        }

        if (!this.validateForm()) {
            this.showToast('Error', 'Please fill all required information and try again.', 'error');
            return;
        }

        await this.createClientInfo();
    }

    // Input change handlers
    handleStateChange(event) {
        this.selectedStateId = event.detail.value;
        console.log('State changed:', this.selectedStateId);
    }

    handleNumberOfEmployeesChange(event) {
        this.numberOfEmployees = event.detail.value;
        console.log('Number of employees changed:', this.numberOfEmployees);
    }

    handleGrossWagesChange(event) {
        this.grossWages = event.detail.value;
        console.log('Gross wages changed:', this.grossWages);
    }

    // Utility Methods
    sortData(fieldName, sortDirection) {
        const cloneData = [...this.lstSUTAQuotes];
        cloneData.sort(this.sortBy(fieldName, sortDirection === 'asc' ? 1 : -1));
        this.lstSUTAQuotes = cloneData;
    }

    sortBy(field, reverse) {
        return (a, b) => {
            a = a[field] || '';
            b = b[field] || '';
            return reverse * ((a > b) - (b > a));
        };
    }

    validateForm() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handleError(error) {
        console.error('Error:', error);
        let message = 'An error occurred';
        if (error.body && error.body.message) {
            message = error.body.message;
        } else if (error.message) {
            message = error.message;
        }
        this.showToast('Error', message, 'error');
    }

    // Getters
    get hasData() {
        return this.lstSUTAQuotes && this.lstSUTAQuotes.length > 0;
    }

    get showDeleteButton() {
        return this.selectedRows && this.selectedRows.length > 0;
    }

    get proposalClientName() {
        return this.oProposal && this.oProposal.Client__c ? this.oProposal.Client__c : '';
    }
}