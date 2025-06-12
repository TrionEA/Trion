import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

// Apex Methods
import getFederaTaxData from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.getFederaTaxData';
import getProposalSUTAQuoteRecords from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.getProposalSUTAQuoteRecords';
import getYears from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.getYears';
import updateProposalYear from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.updateProposalYear';
import updateSUTAQuoteRecords from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.updateSUTAQuoteRecords';
import deleteSUTAQuoteRecords from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.deleteSUTAQuoteRecords';
import getSUTARecords from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.getSUTARecords';
import isButtonVisibilitySOQLFilter from '@salesforce/apex/EmploymentTaxesCompCtrlLWC.isButtonVisibilitySOQLFilter';

// Custom Labels
import SUTAQuoteDeleteInfoMsg from '@salesforce/label/c.SUTAQuoteDeleteInfoMsg';

export default class EmploymentTaxesComp extends NavigationMixin(LightningElement) {
    @api recordId;
    @api buttonvisibilitysoqlFilter = '';
    
    @track selectedYearId = '';
    @track selectedRecordId = '';
    @track selectedRecordName = '';
    @track isShowSelectYear = false;
    @track isShowCheckboxColumn = true;
    @track isShowEditModal = false;
    @track isEdit = false;
    @track isDelete = false;
    @track isChangeState = false;
    @track isShowDeleteModal = false;
    @track oProposal = {};
    @track lstSUTAQuotes = [];
    @track selectedSUTA = '';
    @track columns = [];
    @track sortedBy = '';
    @track selectedRows = [];
    @track errors = [];
    @track draftValues = [];
    @track sortedDirection = true;
    @track isButtonVisible = true;
    @track isLoading = false;
    @track isEditModalLoading = false;
    @track isDeleteModalLoading = false;
    
    // Options for comboboxes
    @track yearOptions = [];
    @track sutaOptions = [];
    
    // Custom label
    deleteInfoMessage = SUTAQuoteDeleteInfoMsg;

    connectedCallback() {
        this.initializeComponent();
    }

    async initializeComponent() {
        await this.fetchFederaTaxData();
        this.createDataTableHeaders(false);
        if (this.buttonvisibilitysoqlFilter) {
            await this.checkButtonVisibility();
        }
    }

    async checkButtonVisibility() {
        try {
            this.isLoading = true;
            const result = await isButtonVisibilitySOQLFilter({
                visibilitysoqlFilter: this.buttonvisibilitysoqlFilter,
                recordId: this.recordId
            });
            this.isButtonVisible = result;
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    async fetchFederaTaxData() {
        try {
            this.isLoading = true;
            const result = await getFederaTaxData({ recordId: this.recordId });
            this.oProposal = result;
            if (result.Year__c) {
                this.selectedYearId = result.Year__c;
            }
            await this.fetchProposalSUTAQuoteRecords();
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    async fetchProposalSUTAQuoteRecords() {
        try {
            this.isLoading = true;
            const result = await getProposalSUTAQuoteRecords({ recordId: this.recordId });
            if (result) {
                result.forEach(record => {
                    if (record.SUTA__c && record.SUTA__r) {
                        record.SUTAName = record.SUTA__r.Name;
                    } else {
                        record.SUTAName = null;
                    }
                });
            }
            this.lstSUTAQuotes = result || [];
            if (result && result.length > 0) {
                this.sortedBy = 'Proposal_SUTA_header__c';
                this.sortedDirection = 'asc';
                this.sortData('Proposal_SUTA_header__c', 'asc');
            }
            console.log('this.lstSUTAQuotes-->'+JSON.stringify(this.lstSUTAQuotes));
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    createDataTableHeaders(isEditable) {
        const actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        
        this.columns = [
            { label: 'State', fieldName: 'State_Name__c', type: 'text', sortable: true, editable: false },
            { label: 'Reporting Level', fieldName: 'Reporting_Level__c', type: 'text', sortable: true, editable: false },
            { label: 'Entity', fieldName: 'Entity__c', type: 'text', sortable: true, editable: false },
            { label: 'Cost Rate', fieldName: 'SUTA_Cost_Rate__c', type: 'number', sortable: true, editable: false, cellAttributes: { alignment: 'left' } },
            { label: 'Bill Rate', fieldName: 'SUTA_Bill_Rate__c', type: 'number', sortable: true, editable: isEditable, cellAttributes: { alignment: 'left' } },
            { type: 'action', typeAttributes: { rowActions: actions } }
        ];
    }

    async fetchYears() {
        try {
            this.isLoading = true;
            const result = await getYears();
            const yearOptions = [];
            if (result) {
                for (const key in result) {
                    yearOptions.push({ label: result[key], value: key });
                }
            }
            this.yearOptions = yearOptions;
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    async fetchSUTARecords(sutaId, stateId, yearId) {
        try {
            this.isEditModalLoading = true;
            const result = await getSUTARecords({
                sutaId: sutaId,
                stateId: stateId,
                yearId: yearId
            });
            const sutaOptions = [];
            if (result) {
                for (const key in result) {
                    sutaOptions.push({ label: result[key], value: key });
                }
            }
            this.sutaOptions = sutaOptions;
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isEditModalLoading = false;
        }
    }

    // Event Handlers
    async handleTaxYear() {
        this.isShowSelectYear = true;
        if (this.oProposal.Year__c) {
            this.selectedYearId = this.oProposal.Year__c;
        }
        await this.fetchYears();
    }

    handleYearChange(event) {
        this.selectedYearId = event.detail.value;
    }

    async handleSelectTaxYear() {
        if (this.selectedYearId) {
            await this.selectTaxYear();
        } else {
            this.showToast('Error', 'Please select a valid Year', 'error');
        }
    }

    handleCancelTaxYear() {
        this.isShowSelectYear = false;
    }

    async selectTaxYear() {
        try {
            this.isLoading = true;
            await updateProposalYear({
                proposalId: this.recordId,
                proposalYear: this.selectedYearId
            });
            this.isShowSelectYear = false;
            this.selectedYearId = null;
            await this.fetchFederaTaxData();
            this.navigateToRecord(this.recordId);
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleColumnSorting(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.sortData(fieldName, sortDirection);
    }

    async handleSaveEdition(event) {
        const draftValues = event.detail.draftValues;
        await this.saveSUTAQuoteRecords(draftValues);
    }

    async saveSUTAQuoteRecords(draftValues) {
        try {
            this.isLoading = true;
            await updateSUTAQuoteRecords({ lstQuotes: draftValues });
            await this.fetchFederaTaxData();
            this.draftValues = [];
            this.isShowCheckboxColumn = true;
            this.isEdit = false;
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    async handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        switch (action.name) {
            case 'edit':
                this.selectedRecordId = row.Id;
                this.selectedRecordName = row.Name;
                this.isShowEditModal = true;
                this.selectedSUTA = row.SUTA__c;
                await this.fetchSUTARecords(row.SUTA__c, row.State__c, row.Year__c);
                break;
            case 'delete':
                this.isShowDeleteModal = true;
                this.selectedRecordId = row.Id;
                break;
        }
    }

    handleCancelDeleteRecords() {
        this.isShowDeleteModal = false;
        this.selectedRecordId = null;
    }

    async handleDeleteRecords() {
        await this.deleteSelectedRecords();
    }

    async deleteSelectedRecords() {
        try {
            this.isDeleteModalLoading = true;
            await deleteSUTAQuoteRecords({ quoteId: this.selectedRecordId });
            await this.fetchFederaTaxData();
            this.selectedRecordId = null;
            this.isShowDeleteModal = false;
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isDeleteModalLoading = false;
        }
    }

    handleRecordEditCancel() {
        this.isShowEditModal = false;
        this.selectedRecordId = null;
        this.selectedRecordName = null;
        this.selectedSUTA = null;
    }

    handleSUTAChange(event) {
        this.selectedSUTA = event.detail.value;
    }

    async handleEditQuoteRecord() {
        try {
            this.isEditModalLoading = true;
            
            const billRateField = this.template.querySelector('[data-field="SUTA_Bill_Rate"]');
            //const costRateField = this.template.querySelector('lightning-input-field[field-name="SUTA_Cost_Rate__c"]');
            const costRateField = this.template.querySelector('[data-field="SUTA_Cost_Rate"]');
            
            const billRate = billRateField ? billRateField.value : null;
            const costRate = costRateField ? costRateField.value : null;
            
            if (costRate != null && costRate !== '' && billRate >= costRate) {
                const objQuote = {
                    sobjectType: 'SUTA_Quote__c',
                    Id: this.selectedRecordId,
                    SUTA__c: this.selectedSUTA,
                    SUTA_Bill_Rate__c: billRate
                };
                console.log('billRate-->'+billRate);
                console.log('costRate-->'+costRate);

                const editForm = this.template.querySelector('lightning-record-edit-form');
                editForm.submit(objQuote);
            } else {
                console.log('costRateField-->'+costRateField);
                console.log('billRateField-->'+billRateField);
                this.showToast('Error', 'SUTA Bill Rate should be equal or greater than SUTA Cost Rate', 'error');
                this.isEditModalLoading = false;
            }
        } catch (error) {
            this.handleError(error);
            this.isEditModalLoading = false;
        }
    }

    handleErrorQuoteRecord(event) {
        this.isEditModalLoading = false;
        const message = event.detail.message;
        if (message) {
            this.showToast('Error', message, 'error');
        }
    }

    async handleSuccessQuoteRecord() {
        this.isShowEditModal = false;
        this.selectedRecordId = null;
        this.selectedRecordName = null;
        this.selectedSUTA = null;
        this.isEditModalLoading = false;
        await this.fetchProposalSUTAQuoteRecords();
    }

    handleCancel() {
        this.draftValues = [];
        this.isShowCheckboxColumn = true;
        this.isEdit = false;
    }

    // Utility Methods
    sortData(fieldName, sortDirection) {
        const cloneData = [...this.lstSUTAQuotes];
        cloneData.sort(this.sortBy(fieldName, sortDirection === 'asc' ? 1 : -1));
        this.lstSUTAQuotes = cloneData;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) { return primer(x[field]); }
            : function (x) { return x[field]; };
        
        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleError(error) {
        console.error('Error:', error);
        let message = 'Unknown error occurred';
        if (error.body) {
            if (error.body.message) {
                message = error.body.message;
            } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                message = error.body.pageErrors[0].message;
            } else if (error.body.fieldErrors) {
                const fieldErrors = Object.values(error.body.fieldErrors).flat();
                if (fieldErrors.length > 0) {
                    message = fieldErrors[0].message;
                }
            }
        } else if (error.message) {
            message = error.message;
        }
        this.showToast('Error', message, 'error');
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
}