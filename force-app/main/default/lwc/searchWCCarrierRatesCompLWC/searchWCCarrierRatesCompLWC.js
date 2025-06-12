import { LightningElement, track } from 'lwc';
import getPicklistValues from '@salesforce/apex/SearchWCCarrierRatesCompCtrl.getPicklistValues';
import getCarrierPicklistValues from '@salesforce/apex/SearchWCCarrierRatesCompCtrl.getCarrierPicklistValues';
import getStatePicklistValues from '@salesforce/apex/SearchWCCarrierRatesCompCtrl.getStatePicklistValues';
import getCarrierWCRates from '@salesforce/apex/SearchWCCarrierRatesCompCtrl.getCarrierWCRates';
import isStateTerritorialRating from '@salesforce/apex/SearchWCCarrierRatesCompCtrl.isStateTerritorialRating';
import updateCarrierWCRates from '@salesforce/apex/SearchWCCarrierRatesCompCtrl.updateCarrierWCRates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WcCarrierRates extends LightningElement {
    // @api isEditable = false;

    @track isShowSearchFilter = true;
    @track isLoading = false;
    @track isShowModal = false;
    @track filteredData = [];
    @track columns = [];
    // @track errors = [];
    @track draftValues = [];
    @track lstFilters = [];
    @track sortedBy;
    @track sortedDirection = 'asc';
    @track mapStatusPicklistValues = [];
    @track mapCarrierPicklistValues = [];
    @track mapStatePicklistValues = [];

    connectedCallback() {
        this.createDataTableHeaders();
        this.initializeComponent();
    }

    initializeComponent() {
        // Set initial filters
        this.lstFilters = [{
            selectedCompCode: '',
            selectedState: '',
            selectedCarrier: '',
            selectedStatus: '',
            isDisabledSelectedCompCode: false,
            isDisabledSelectedState: false,
            isDisabledSelectedCarrier: false,
            isDisabledSelectedStatus: false
        }];

        // Fetch picklist values for Status__c
        this.getStatusPicklistValues();
    }

    createDataTableHeaders() {
        this.columns = [
            { label: 'Comp Code', fieldName: 'CompCodeName', type: 'text', sortable: true, editable: false },
            { label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true, editable: false },
            { label: 'Description', fieldName: 'Description__c', type: 'text', sortable: true, editable: false },
            { label: 'Carrier', fieldName: 'CarrierName', type: 'text', sortable: true, editable: false },
            { label: 'Rate', fieldName: 'Rate__c', type: 'number', sortable: true, editable: false, cellAttributes: { alignment: 'left' } },
            { label: 'Modifier', fieldName: 'Modifier__c', type: 'number', sortable: true, editable: this.isEditable, cellAttributes: { alignment: 'left' } },
            { label: 'State Assessment Fee', fieldName: 'State_Assessment_Fee__c', type: 'number', sortable: true, editable: false, cellAttributes: { alignment: 'left' } },
            { label: 'Trion Bill Rate', fieldName: 'Trion_Bill_Rate__c', type: 'number', sortable: true, editable: false, cellAttributes: { alignment: 'left' } },
            { label: 'Trion Bill Rate Exc. Assessment Fees', fieldName: 'Trion_Bill_Rate_Exc_Assessment_Fees__c', type: 'number', sortable: true, editable: false, cellAttributes: { alignment: 'left' } },
            { label: 'State', fieldName: 'StateName', type: 'text', sortable: true, editable: false },
            {
                label: 'Effective Date',
                fieldName: 'Effective_Date__c',
                type: 'date',
                sortable: true,
                editable: false,
                typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric', timeZone: 'UTC' }
            }
        ];
    }

getStatusPicklistValues() {
    this.showSpinner(); // Show spinner
    getPicklistValues({ objectName: 'Policy__c', fieldName: 'Status__c' })
        .then(result => {
            if (result) {
                this.mapStatusPicklistValues = Object.keys(result).map(key => ({
                    key: key,
                    value: result[key]
                }));
            }
            // Chain to the next method like in Aura
            this.getCarrierOptions();
        })
        .catch(error => {
            this.handleErrors(error); // Custom error handler
        })
        .finally(() => {
            this.hideSpinner(); // Hide spinner
        });
}

getCarrierOptions() {
    this.showSpinner(); // Show spinner

    getCarrierPicklistValues()
        .then(result => {
            if (result) {
                this.mapCarrierPicklistValues = Object.keys(result).map(key => ({
                    key: key,
                    value: result[key]
                }));
            }
            this.getStateOptions(); // Call next method in chain
        })
        .catch(error => {
            this.handleErrors(error); // Use your custom error handler
        })
        .finally(() => {
            this.hideSpinner(); // Hide spinner
        });
}

getStateOptions() {
    this.showSpinner(); // show spinner

    getStatePicklistValues()
        .then(result => {
            if (result) {
                this.mapStatePicklistValues = Object.keys(result).map(key => ({
                    key: key,
                    value: result[key]
                }));
            }
        })
        .catch(error => {
            this.handleErrors(error); // custom error handler
        })
        .finally(() => {
            this.hideSpinner(); // hide spinner
        });
}

fetchCarrierWCRates(isDelete = false) {
    this.showSpinner(); // show spinner

    const filters = JSON.stringify(this.lstFilters);

    getCarrierWCRates({ filterJSON: filters })
        .then(result => {
            if (result) {
                result.forEach(record => {
                    if (record.WC_Code__c && record.WC_Code__r?.Name) {
                        record.CompCodeName = record.WC_Code__r.Name;
                    }
                    if (record.Carrier__c && record.Carrier__r?.Name) {
                        record.CarrierName = record.Carrier__r.Name;
                    }
                    if (record.State__c && record.State__r?.Name) {
                        record.StateName = record.State__r.Name;
                    }
                });

                this.filteredData = result;

                if (!isDelete) {
                    this.isShowSearchFilter = false;
                    this.isShowModal = false;
                }

                this.sortedBy = 'CompCodeName';
                this.sortedDirection = 'asc';
                this.sortData('CompCodeName', 'asc');
            }
        })
        .catch(error => {
            this.handleErrors(error);
        })
        .finally(() => {
            this.hideSpinner(); // hide spinner
        });
}

saveCarrierWCRates(draftValues) {
    this.showSpinner();

    updateCarrierWCRates({ lstCarrierWCRates: draftValues })
        .then(() => {
            this.showToast('Success', 'Carrier WC Rates updated successfully', 'success');
            this.fetchCarrierWCRates = false; // refresh data
            this.draftValues = [];           // clear draft values
        })
        .catch(error => {
            this.handleErrors(error);
        })
        .finally(() => {
            this.hideSpinner();
        });
}

// Adds one more filter entry
    handleMoreFilter() {
        const newFilter = {
            selectedCompCode: '',
            selectedState: '',
            selectedCarrier: '',
            selectedStatus: '',
            isDisabledSelectedCompCode: false,
            isDisabledSelectedState: false,
            isDisabledSelectedCarrier: false,
            isDisabledSelectedStatus: false
        };
        this.lstFilters = [...this.lstFilters, newFilter]; // preserve reactivity
    }

    // Resets filter list to one default filter
    handleResetFilter() {
        this.lstFilters = [{
            selectedCompCode: '',
            selectedState: '',
            selectedCarrier: '',
            selectedStatus: '',
            isDisabledSelectedCompCode: false,
            isDisabledSelectedState: false,
            isDisabledSelectedCarrier: false,
            isDisabledSelectedStatus: false
        }];
    }

     handleApplyFilter() {
        let isRequiredFilter = true;

        // Check each filter for required Comp Code
        this.lstFilters.forEach(filter => {
            if (!filter.selectedCompCode) {
                isRequiredFilter = false;
            }
        });

        if (isRequiredFilter) {
            // Disable the filter inputs
            this.lstFilters = this.lstFilters.map(filter => ({
                ...filter,
                isDisabledSelectedCompCode: true,
                isDisabledSelectedState: true,
                isDisabledSelectedCarrier: true,
                isDisabledSelectedStatus: true
            }));

            // Call helper methods
            this.createDataTableHeaders = true;
            this.fetchCarrierWCRates= false;
        } else {
            this.showToast('Error', 'Please select a valid Comp Code for all filters.', 'error');
        }
    }

    // Save inline edits
    handleSaveEdition(event) {
        this.draftValues = event.detail.draftValues;

        saveCarrierWCRates({ lstCarrierWCRates: this.draftValues })
            .then(() => {
                this.draftValues = [];
                this.fetchCarrierWCRates(false); // Implement this method
            })
            .catch(error => {
                this.showToast('Error saving', error.body.message, 'error');
            });
    }

    // Cancel inline edit
    handleCancel() {
        this.draftValues = [];
    }

    // Add new filter row and open modal
    handleAdd() {
        this.lstFilters = [
            ...this.lstFilters,
            {
                selectedCompCode: '',
                selectedState: '',
                selectedCarrier: '',
                selectedStatus: '',
                isDisabledSelectedCompCode: false,
                isDisabledSelectedState: false,
                isDisabledSelectedCarrier: false,
                isDisabledSelectedStatus: false
            }
        ];
        this.isShowModal = true;
    }

    handleCloseModal() {
        this.lstFilters = this.lstFilters.filter(
            filter => filter.selectedCompCode !== null && 
                      filter.selectedCompCode !== '' && 
                      filter.selectedCompCode !== undefined
        );
        this.isShowModal = false;
    }

    handleSearchCancel() {
    this.lstFilters = [{
        selectedCompCode: '',
        selectedState: '',
        selectedCarrier: '',
        selectedStatus: '',
        isDisabledSelectedCompCode: false,
        isDisabledSelectedState: false,
        isDisabledSelectedCarrier: false,
        isDisabledSelectedStatus: false
    }];
    
    this.isShowSearchFilter = true;
    this.filteredData = [];
}

handleDeleteFilter(event) {
    const index = event.target.dataset.index;
    this.lstFilters.splice(index, 1);

    if (this.lstFilters.length === 0) {
        this.lstFilters.push({
            selectedCompCode: '',
            selectedState: '',
            selectedCarrier: '',
            selectedStatus: '',
            isDisabledSelectedCompCode: false,
            isDisabledSelectedState: false,
            isDisabledSelectedCarrier: false,
            isDisabledSelectedStatus: false
        });
    }

    // Reassign to trigger reactivity
    this.lstFilters = [...this.lstFilters];

    if (!this.isShowSearchFilter) {
        this.fetchCarrierWCRates = true; // Pass true for isDelete
    }
}

handleEditFilter(event) {
    const index = event.target.dataset.index;
    if (index !== undefined && this.lstFilters[index]) {
        this.lstFilters[index].isDisabledSelectedCompCode = false;
        this.lstFilters[index].isDisabledSelectedState = false;
        this.lstFilters[index].isDisabledSelectedCarrier = false;
        this.lstFilters[index].isDisabledSelectedStatus = false;

        // Reassign to trigger reactivity
        this.lstFilters = [...this.lstFilters];
    }
}

showSpinner() {
        this.isLoading = true;
    }

    // Equivalent of hideSpinner()
    hideSpinner() {
        this.isLoading = false;
    }

    // Example usage
    someAction() {
        this.showSpinner();
        // Simulate async operation
        setTimeout(() => {
            this.hideSpinner();
        }, 2000);
    }

sortData(fieldName, sortDirection) {
        let reverse = sortDirection !== 'asc';

        let sorted = [...this.filteredData].sort(this.sortBy(fieldName, reverse));
        this.filteredData = sorted;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
    }

    // Helper for dynamic sorting
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) { return primer(x[field]); }
            : function (x) { return x[field]; };

        reverse = !reverse ? 1 : -1;

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    // Call this on column sort event from lightning-datatable
    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortData(fieldName, sortDirection);
    }

handleSave(event) {
    const draftValues = event.detail.draftValues;
    this.saveCarrierWCRates(draftValues);
}

showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // e.g., 'success', 'error', 'warning', 'info'
        });
        this.dispatchEvent(evt);
    }

    handleErrors(errors) {
        if (!errors || !Array.isArray(errors)) return;

        errors.forEach(error => {
            // Page Errors
            if (error.pageErrors) {
                error.pageErrors.forEach(pageErr => {
                    this.showToast(pageErr.statusCode, pageErr.message, 'warning');
                });
            }

            // Field Errors
            if (error.fieldErrors) {
                Object.keys(error.fieldErrors).forEach(field => {
                    error.fieldErrors[field].forEach(fieldErr => {
                        this.showToast(fieldErr.statusCode, `${fieldErr.message} [${field}]`, 'error');
                    });
                });
            }

            // General Message
            if (error.message) {
                const msgArray = error.message.split('|');
                msgArray.forEach(msg => {
                    this.showToast('Error', msg, 'error');
                });
            }
        });
    }
}