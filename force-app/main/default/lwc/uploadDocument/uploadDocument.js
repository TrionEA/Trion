import { LightningElement, api, track } from 'lwc';
import isButtonVisibilitySOQLFilter from '@salesforce/apex/UploadDocument.isButtonVisibilitySOQLFilter';
import getObjectName from '@salesforce/apex/UploadDocument.getObjectName';
// import getOpportunityDetails from '@salesforce/apex/UploadDocument.getOpportunityDetails';
import getProposalDetails from '@salesforce/apex/UploadDocument.getProposalDetails';
import getSubmissionRequirement from '@salesforce/apex/UploadDocument.getSubmissionRequirement';
import getPicklistValues from '@salesforce/apex/UploadDocument.getPicklistValues';
import createProposalAndupdateSubmissionRequirement from '@salesforce/apex/UploadDocument.createProposalAndupdateSubmissionRequirement';
import updateSubmissionRequirement from '@salesforce/apex/UploadDocument.updateSubmissionRequirement';
import getWCRate from '@salesforce/apex/UploadDocument.getWCRate';
import updateWCRate from '@salesforce/apex/UploadDocument.updateWCRate';
import getClientLocationPicklistValues from '@salesforce/apex/UploadDocument.getClientLocationPicklistValues';
import isShowCongaButtons from '@salesforce/apex/UploadDocument.isShowCongaButtons';
import getAccordSignatureRequestURL from '@salesforce/apex/UploadDocument.getAccordSignatureRequestURL';
import getGenerateACORD from '@salesforce/apex/UploadDocument.getGenerateACORD';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class UploadDocument extends NavigationMixin(LightningElement) {
    @api recordId;
    @api oSubmissionRequirement;
    @track oProposal;

    @track buttonvisibilitysoqlFilter;
    @track isButtonVisible = false;
    @track isLoading = false;
    @track sObjectName;
    @track proposalId;
    @track opp;
    @track dataTableColumns = [];
    @track wcRateDataTableColumns = [];
    @track opportunityDetails;
    @track proposalDetails;
    @track data = [];
    @track wcratesdata = [];
    @track selectedRows = [];
    @track showUploadComponent = false;
    @track requirementOptions = [];
    @track acordTypeOptions = [];
    @track selectedRequirement = '';
    @track selectedACORDType = '';
    @track sortBy;
    @track sortDirection;
    @track submissionRequirementNotes;
    @track submissionRequirementRecord;
    @track showTemplate = false;
    @track isShowACORDTemplet = false;
    @track isShowStateRatingModal = false;
    @track isShowAccordSignatureRequestButton = false;
    @track isShowGenerateACORDButton = false;
    // @track isUploadModalVisible = false;
    @track isFileUploaded = false;
    @track isShowAddNote = false;
    @track isShowAddWCCodeModal = false;
    @track isShowWorkSubContracted = false;
    @track isShowVOLUNTEER_OR_DONATED_LABOR_EXPLANATION = false;
    @track isShowEmployeesWorkFromHome = false;
    @track isShowSPECIFYTAXLIENSBANKRUPTCY = false;
    @track isShowEXPLAINUNDISPUTEDANDUNPAIDWCPREMIUM = false;
    @track selectedRecordId;
    @track natureofBusinessDescription;
    @track startDt;
    @track startDtToFirstOfMonth;
    @track selectedWCRate = {};
    @track selectedStateCompCode = '';
    @track selectedWcRateId = '';
    @track selectedWcRateName = '';
    @track selectedClientLocation = '';
    @track wcRateWhereClause = '';
    @track mapClientLocationPicklistValues = [];
    @track clientLocationOptions = []; 
    @track wcCodeOptions = [];
    eachAccident;
    diseasePolicyLimit;
    diseaseEachEmployee;
    u_s_l_h;
    voluntaryComp;
    foreignCov;
    managedCareOption;
    totalEstimatedAnnualPremiumAllState;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.docx'];
    }

    getFirstDateOfMonth(dt){
        const regex = /(\-\d\d)$/;          
        var givenDateConvertedToFirst = dt.replace(regex,'-01');          
        return givenDateConvertedToFirst ;
    }

     get isShowACORDTemplet() {
        return this.oSubmissionRequirement?.Requirement_Type__c === 'ACORD';
    }

    connectedCallback() {
        this.handleInitialization();
        this.fetchPicklist();
        this.createDataTableHeaders();
        this.createWCRateDataTableHeaders();
        this.loadWCRates();
    }

    handleInitialization() {
        this.fetchObjectName();
        if (this.buttonvisibilitysoqlFilter) {
            this.checkButtonVisibility();
        }
    }

    checkButtonVisibility() {
        this.showSpinner();

        isButtonVisibilitySOQLFilter({
            visibilitysoqlFilter: this.buttonvisibilitysoqlFilter,
            recordId: this.recordId
        })
        .then(result => {
            this.isButtonVisible = result;
        })
        .catch(error => {
            console.error('Error checking button visibility:', error);
            // Optionally display error in UI
        })
        .finally(() => {
            this.hideSpinner();
        });
    }

    fetchObjectName() {
        this.showSpinner();
        getObjectName({ recordId: this.recordId })
        .then(objectName => {
            this.sObjectName = objectName;
            if (objectName === 'proposal__c') {
                getProposalDetails({ recordId: this.recordId })
                    .then(proposal => {
                        this.oProposal = proposal;
                        this.totalEstimatedAnnualPremiumAllState = proposal.TOTAL_ESTIMATED_ANNUAL_PREMIUM_ALL_STATE__c;

                        const opportunityId = proposal?.Opportunity__c;
                        if (opportunityId) {
                            this.fetchSubmissionRequirements(opportunityId);
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching Proposal details:', error);
                    });
            } else if (objectName === 'opportunity') {
                this.fetchSubmissionRequirements(this.recordId);
            }
        })
        .catch(error => {
            console.error('Error determining object name:', error);
        })
        .finally(() => {
            this.hideSpinner();
        });
    }

    fetchSubmissionRequirements(opportunityId) {
        getSubmissionRequirement({
            recordId: opportunityId,
            status: '',
            Requiredstatus: ''
        })
            .then((result) => {
            // Sort the full data by Required_Optional__c
            const sortedData = [...result].sort((a, b) => {
                if (a.Required_Optional__c === b.Required_Optional__c) return 0;
                return a.Required_Optional__c === 'Required' ? -1 : 1;
            });

            this.data = sortedData;

            // Create dropdown options from sorted data
           this.requirementOptions = [
                { label: '--None--', value: '' },
                ...sortedData.map(req => ({
                    label: req.Requirement_Type__c,
                    value: req.Requirement_Type__c
            }))
           ];

           if (sortedData.length > 0) {
            const employerLiabilityReq = sortedData[0]; // or apply filter if needed

            this.eachAccident = employerLiabilityReq.EACH_ACCIDENT__c;
            this.diseasePolicyLimit = employerLiabilityReq.DISEASE_POLICY_LIMIT__c;
            this.diseaseEachEmployee = employerLiabilityReq.DISEASE_EACH_EMPLOYEE__c;
            this.u_s_l_h = employerLiabilityReq.U_S_L_H__c;
            this.voluntaryComp = employerLiabilityReq.VOLUNTARY_COMP__c;
            this.foreignCov = employerLiabilityReq.FOREIGN_COV__c;
            this.managedCareOption = employerLiabilityReq.MANAGED_CARE_OPTION__c;
        }
        })
            .catch((error) => {
                console.error('Error fetching Submission Requirements:', error);
            });
    }

    fetchPicklist() {
        this.showSpinner();

    getPicklistValues({
        objectName: 'Submission_Requirement__c',
        fieldName: 'ACORD_Type__c'
    })
    .then(result => {
        let opts = [{ label: '--None--', value: '' }];
        for (let key in result) {
            opts.push({ label: result[key], value: key });
        }
        this.acordTypeOptions = opts;
        this.hideSpinner();
    })
    .catch(error => {
        console.error('Error fetching picklist values:', error);
        this.hideSpinner();
    });
}

fetchClientLocationRecords(stateId) {
    getClientLocationPicklistValues({ stateId })
        .then(result => {
            // Convert Map to combobox-friendly array
            const options = Object.entries(result).map(([key, value]) => ({
                label: value,
                value: key
            }));

            // Add '--None--' option at the top
            this.clientLocationOptions = [
                { label: '--None--', value: '' },
                ...options
            ];

            // Ensure the correct value is shown as selected
            this.selectedClientLocation = this.selectedWCRate?.Client_Location__c || '';
        })
        .catch(error => {
            console.error('Error fetching client locations:', error);
        });
}

fetchShowCongaButtons(submissionDocId) {
        this.showSpinner();
        isShowCongaButtons({ submissionDocId })
            .then(result => {
                this.isShowAccordSignatureRequestButton = result;
                this.isShowGenerateACORDButton = result;
            })
            .catch(error => {
                console.error('Error fetching Conga buttons visibility:', error);
                this.showToast('Error', 'Failed to load Conga buttons visibility', 'error');
            })
            .finally(() => {
                this.hideSpinner();
            });
    }

    fetchAccordSignatureRequestURL(submissionDocId) {
        this.showSpinner();
        getAccordSignatureRequestURL({ submissionDocId })
            .then(result => {
                if (result) {
                    window.open(result, '_blank');
                } else {
                    this.showToast('Error', 'No Accord Signature Request URL found.', 'error');
                }
            })
            .catch(error => {
                console.error('Error fetching Accord Signature Request URL:', error);
                this.showToast('Error', 'Failed to get Accord Signature Request URL', 'error');
            })
            .finally(() => {
                this.hideSpinner();
            });
    }

    fetchGenerateACORD(submissionDocId) {
        this.showSpinner();
        getGenerateACORD({ submissionDocId })
            .then(result => {
                if (result) {
                    window.open(result, '_blank');
                } else {
                    this.showToast('Error', 'No Generate ACORD URL found.', 'error');
                }
            })
            .catch(error => {
                console.error('Error fetching Generate ACORD URL:', error);
                this.showToast('Error', 'Failed to get Generate ACORD URL', 'error');
            })
            .finally(() => {
                this.hideSpinner();
            });
    }

    createDataTableHeaders() {
    const dataTableActions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
    // { label: 'Accord Signature Request', name: 'Accord_Signature_Request' },
    // { label: 'Generate ACORD', name: 'Generate_ACORD' }
    ];

    this.dataTableColumns = [
        { label: 'Document', fieldName: 'Requirement_Type__c', type: 'text', sortable: true, editable: false },
        { label: 'Required/Optional', fieldName: 'Required_Optional__c', type: 'text', sortable: true, editable: false },
        { label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true, editable: false },
        { label: 'ACORD Type', fieldName: 'ACORD_Type__c', type: 'text', sortable: true, editable: false },
        { label: 'Notes', fieldName: 'Notes__c', type: 'text', sortable: true, editable: false },
        {
            type: 'action',
            typeAttributes: { rowActions: dataTableActions, menuAlignment: 'auto' }
        }
    ];
    }

    createWCRateDataTableHeaders() {
        const wcRateDataTableActions = [{ label: 'Edit', name: 'edit' }];

        this.wcRateDataTableColumns = [
            { label: 'Loc #', fieldName: 'Client_Location', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
            { label: 'State Name', fieldName: 'WCStateName', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } },
            { label: 'Class Code/Description', fieldName: 'Description__c', type: 'text', sortable: true },
            { label: '# Part Time Employees', fieldName: 'Part_Time_Employees__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
            { label: '# Full Time Employees', fieldName: 'of_Employees__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
            { label: 'Gross Wages', fieldName: 'Gross_Wages__c', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' } },
            { label: 'Rate', fieldName: 'Current_Rate__c', type: 'percent-fixed', sortable: true, cellAttributes: { alignment: 'left' } },
            { label: 'Estimated Annual Manual Premium', fieldName: 'Estimated_Annual_Manual_Premium__c', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' } },
            {
                type: 'action',
                typeAttributes: { rowActions: wcRateDataTableActions, menuAlignment: 'auto' }
            }
        ];
    }

    loadWCRates() {
        console.log('Loading WC Rates for proposalId:', this.proposalId);
        getWCRate({ proposalId: this.proposalId })
            .then(result => {
                console.log('Raw result:', result);

                this.wcratesdata = result.map(r => ({
                    ...r,
                    WCStateName: r?.SUTA_Quote__r?.State__r?.Name || '',
                    Client_Location: r?.Client_Location__r?.Loc__c || ''
                }));
                this.sortData(this.sortedBy, this.sortedDirection);
            })
            .catch(error => {
                console.error('Error fetching WC Rate records:', error);
            });
    }

    handleUploadClick() {
        this.showUploadComponent = true;
        this.selectedRequirement = '';
        this.selectedACORDType = '';
    }

    handleRequirementChange(event) {
    this.selectedRequirement = event.detail.value;

    if (this.selectedRequirement && this.selectedRequirement !== '--None--') {
        if (this.selectedRequirement === 'ACORD') {
            this.isShowACORDTemplet = true;
            this.showTemplate = false;
            this.showUploadComponent = false;
        } else {
            this.showTemplate = true;
            this.isShowACORDTemplet = false;
             this.showUploadComponent = true;
        }
    }
    }

    handleACORDTypeChange(event) {
         this.selectedACORDType = event.detail.value;
    }

    handleDateChange(event) {
        this.startDt = event.target.value;
      this.startDtToFirstOfMonth = this.getFirstDateOfMonth(this.startDt) ;
    }

    handleInputChange(event) {
    const field = event.target.name;
    const value = event.target.value;

    if (field === 'EACH ACCIDENT') {
        this.eachAccident = value;
    } else if (field === 'DISEASE POLICY LIMIT') {
        this.diseasePolicyLimit = value;
    } else if (field === 'DISEASE EACH EMPLOYEE') {
        this.diseaseEachEmployee = value;
    }
}

    handlePremiumChange(event) {
        this.totalEstimatedAnnualPremiumAllState = event.target.value;
    }

    handleBack(){
        this.showUploadComponent = true;
        this.showTemplate = false;
        this.isShowACORDTemplet = false;
        this.selectedRequirement = '';
        this.selectedACORDType = ''; 
        this.totalEstimatedAnnualPremiumAllState = '';
    }

    handleCancel() {
        this.showUploadComponent = false;
        this.showTemplate = false;
        this.isShowACORDTemplet = false;
    }

    handleStateRatingSave(){
        
    }

    handleStateRatingCancel() {
        this.showUploadComponent = false;
        this.showTemplate = false;
        this.isShowACORDTemplet = true;
        this.isShowStateRatingModal = false;

    }

    hideModalBox() {           
    this.showUploadComponent = false;     
    }

    handleCloseTemplate() {
    this.showTemplate = false;
    this.isShowACORDTemplet = false;
    this.selectedRequirement = '';
    }

    handleAddWCCodeCloseTemplate()
    {
        this.isShowAddWCCodeModal = false;
    }

    handleStateRatingCloseTemplate() {
    this.showTemplate = false;
    this.isShowACORDTemplet = true;
    this.isShowStateRatingModal = false;
    }

    handleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    this.sortBy = sortedBy;
    this.sortDirection = sortDirection;

    // Sort data
    const sortedData = [...this.data].sort((a, b) => {
        let valA = a[sortedBy] || '';
        let valB = b[sortedBy] || '';

        // Handle string comparison
        return sortDirection === 'asc'
            ? valA.localeCompare(valB)
            : valB.localeCompare(valA);
    });

    this.data = sortedData;
    this.wcratesdata = sortedData;

    // Also update dropdown if sorting by Requirement_Type__c or Required_Optional__c
    if (sortedBy === 'Requirement_Type__c' || sortedBy === 'Required_Optional__c') {
        this.requirementOptions = sortedData.map(req => ({
            label: req.Requirement_Type__c,
            value: req.Requirement_Type__c
        }));
    }
    }

    handleRowAction(event) {
    const action = event.detail.action;
    const row = event.detail.row;

    switch (action.name) {
        case 'view':
            this.submissionRequirementRecord = row;
            this.fetchContentDocumentId(row.Id); // You need to implement this method
            break;

        case 'delete':
            this.submissionRequirementRecord = row;
            this.deleteFileUpdateSubmissionRequirement(row.Id); // You need to implement this method
            break;

        case 'edit':
            if (row.Requirement_Type__c === 'ACORD') {
                this.submissionRequirementRecord = row;
                this.isShowACORDTemplet = true;
                this.selectedRecordId = row.Id;
                this.submissionRequirementNotes = row.Notes__c;
                this.natureofBusinessDescription = row.Nature_of_Business_Description__c;

                // this.getWCRateRecords();
                // this.fetchPicklistValues('Submission_Requirement__c', 'ACORD_Type__c', row.ACORD_Type__c);
                // this.createWCRateDataTableHeaders();
                // this.fetchShowCongaButtons(row.Id);
            } else {
                this.showToast('Error', 'You don\'t have permission to edit this record', 'error');
            }
            break;

        case 'Accord_Signature_Request':
            this.fetchAccordSignatureRequestURL(row.Id);
            break;

        case 'Generate_ACORD':
            this.fetchGenerateACORD(row.Id);
            break;
    }
}

handleWCRateRowAction(event){
    const action = event.detail.action;
    const row = event.detail.row;

    switch (action.name) {
        case 'edit':
            this.selectedWCRate = { ...row };
            this.selectedWcRateId = row.Id;
            this.selectedClientLocation = row.Client_Location__c;
            this.selectedStateCompCode = row.State_Comp_Code__c;
            this.selectedWcRateName = `${row?.SUTA_Quote__r?.State__r?.Name || ''}${row?.Client_Loc__c ? ' - ' + row.Client_Loc__c : ''}`;

                    if (row?.State_Comp_Code__c && row?.Description__c) {
            this.wcCodeOptions = [
                { label: '--None--', value: '' },
                { label: row.Description__c, value: row.State_Comp_Code__c }
            ];
            this.selectedStateCompCode = row.State_Comp_Code__c;
        } else {
            this.wcCodeOptions = [{ label: '--None--', value: '' }];
            this.selectedStateCompCode = '';
        }

            // Build where clause if state exists
            if (row?.SUTA_Quote__r?.State__c) {
                this.wcRateWhereClause = `State__c = '${row.SUTA_Quote__r.State__c}'`;
                this.fetchClientLocationRecords(row.SUTA_Quote__r.State__c);
            }

            // Set modal flags
            this.isShowStateRatingModal = true;
            this.isShowACORDTemplet = false;
            break;
    }
}

handleLocationChange(event) {
    this.selectedClientLocation = event.detail.value;
}

handleWcCodeChange(event) {
    this.selectedStateCompCode = event.detail.value;
}

handelAddWCCodeChange(){
    this.isShowAddWCCodeModal = true;
}

handleChangeSUBCONTRACTORSUSED(event){
    const value = event.target.value;
        this.isShowWorkSubContracted = (value === 'Y');
}

handleVOLUNTEERORDONATEDLABOR(event){
    const value = event.target.value;
        this.isShowVOLUNTEER_OR_DONATED_LABOR_EXPLANATION = (value === 'Y');
}

handleEMPLOYEESPREDOMINANTLYWORKATHOME(event){
    const value = event.target.value;
        this.isShowEmployeesWorkFromHome = (value === 'Y');
}

handleTAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS(event){
    const value = event.target.value;
        this.isShowSPECIFYTAXLIENSBANKRUPTCY = (value === 'Y');
}

handleUNDISPUTEDUNPAIDWCPREMIUMDUE(event){
    const value = event.target.value;
        this.isShowEXPLAINUNDISPUTEDANDUNPAIDWCPREMIUM = (value === 'Y');
}

handleUploadFinish() {
        const requirementType = this.oSubmissionRequirement?.Requirement_Type__c;

        if (requirementType === 'ACORD') {
            const isFormValidated = true;
            const selectedACORDType = this.selectedAcordtype;

            if (selectedACORDType && selectedACORDType.trim() !== '') {
                if (isFormValidated) {
                    let submissionRequirementObj = { sobjectType: 'Submission_Requirement__c' };
                    submissionRequirementObj.ACORD_Type__c = selectedACORDType;

                    const fieldsToFetch = [
                        'OWN_OPERATE_LEASE_AIRCRAFT_WATERCRAFT',
                        'DISCONTINUED_OPERATIONS_HAZARDOUS_MATER',
                        'WORK_PERFORMED_UNDERGROUND_OR_ABOVE_15_F',
                        'WORK_PERFORMED_ON_BARGES_VESSELS_DOCKS',
                        'ENGAGED_IN_ANY_OTHER_TYPE_OF_BUSINESS',
                        'SUB_CONTRACTORS_USED',
                        'WORK_SUBLET_W_O_CERTIFICATES_OF_INSURANC',
                        'WRITTEN_SAFETY_PROGRAM_IN_OPERATION',
                        'GROUP_TRANSPORTATION_PROVIDED',
                        'EMPLOYEES_UNDER_16_OR_OVER_60_YEARS_OF_A',
                        'SEASONAL_EMPLOYEES',
                        'VOLUNTEER_OR_DONATED_LABOR',
                        'EMPLOYEES_WITH_PHYSICAL_HANDICAPS',
                        'EMPLOYEES_TRAVEL_OUT_OF_STATE',
                        'Indicate_state_s_of_travel_and_frequenc',
                        'ATHLETIC_TEAMS_SPONSORED',
                        'PHYSICALS_REQUIRED_AFTER_OFFERS_OF_EMPLO',
                        'ANY_OTHER_INSURANCE_WITH_THIS_INSURER',
                        'COVERAGE_DEC_CANC_NON_RENEWED_IN_LAST_3',
                        'EMPLOYEE_HEALTH_PLANS_PROVIDED',
                        'EMPLOYEES_PERFORM_WORK_FOR_OTHER_BUSINES',
                        'LEASE_EMPLOYEES_TO_OR_FROM_OTHER_EMPLOYE',
                        'EMPLOYEES_PREDOMINANTLY_WORK_AT_HOME',
                        'TAX_LIENS_BANKRUPTCY_WITHIN_LAST_5_YRS',
                        'UNDISPUTED_UNPAID_WC_PREMIUM_DUE'
                    ];

                    fieldsToFetch.forEach(field => {
                        const element = this.template.querySelector(`[data-id="${field}"]`);
                        if (element) {
                            submissionRequirementObj[`${field}__c`] = element.value;
                        }
                    });

                    submissionRequirementObj.Nature_of_Business_Description__c = this.natureofBusinessDescription;

                    const sr = this.oSubmissionRequirement || {};
                    submissionRequirementObj.EACH_ACCIDENT__c = sr.EACH_ACCIDENT__c;
                    submissionRequirementObj.DISEASE_POLICY_LIMIT__c = sr.DISEASE_POLICY_LIMIT__c;
                    submissionRequirementObj.DISEASE_EACH_EMPLOYEE__c = sr.DISEASE_EACH_EMPLOYEE__c;
                    submissionRequirementObj.U_S_L_H__c = sr.U_S_L_H__c;
                    submissionRequirementObj.VOLUNTARY_COMP__c = sr.VOLUNTARY_COMP__c;
                    submissionRequirementObj.FOREIGN_COV__c = sr.FOREIGN_COV__c;
                    submissionRequirementObj.MANAGED_CARE_OPTION__c = sr.MANAGED_CARE_OPTION__c;
                    submissionRequirementObj.Notes__c = this.submissionRequirementNotes;

                    const optionalFields = [
                        'of_work_subcontracted',
                        'VOLUNTEER_OR_DONATED_LABOR_EXPLANATION',
                        'of_Employees_work_from_home',
                        'SPECIFY_TAX_LIENS_BANKRUPTCY',
                        'EXPLAIN_UNDISPUTED_AND_UNPAID_WC_PREMIUM'
                    ];

                    optionalFields.forEach(field => {
                        const el = this.template.querySelector(`[data-id="${field}"]`);
                        if (el) {
                            submissionRequirementObj[`${field}__c`] = el.value;
                        }
                    });

                    createProposalAndupdateSubmissionRequirement({
                        oProposal: this.oProposal,
                        oSubmissionRequirement: submissionRequirementObj,
                        submissionRequirementId: sr.Id,
                        notes: this.submissionRequirementNotes,
                        isSubmit: true
                    })
                    .then(() => {
                        this.showToast('Success', 'Submission requirement saved successfully', 'success');
                        this.resetSubmissionRequirementState();
                        this.fetchSubmissionRequirements(this.recordId);
                        this.navigateToRecord(this.recordId);
                    })
                    .catch(error => {
                        const msg = error?.body?.message || error?.message || 'Unknown error';
                        this.showToast('Error', msg, 'error');
                        console.error(error);
                    });
                } else {
                    this.showToast('Error', 'Please fill all required fields to continue', 'error');
                }
            } else {
                this.showToast('Error', 'Please select ACORD Type', 'error');
            }

        } else {
            if (this.isFileUploaded || (this.submissionRequirementNotes && this.submissionRequirementNotes.trim() !== '')) {
                this.submitSubmissionRequirement();
            } else {
                this.showToast('Error', 'Please upload a file or enter notes to continue', 'error');
            }
        }
    }

    handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    
    this.isFileUploaded = true;

    let message = 'File uploaded successfully';
    if (uploadedFiles.length > 1) {
        message = 'Files uploaded successfully';
    }

    this.showToast('Success', message, 'success');
    
    // Refresh submission requirements (if needed)
    this.fetchSubmissionRequirements(this.recordId);
    
    // Optional: show number of files in alert
    alert('No. of files uploaded: ' + uploadedFiles.length);
}

    submitSubmissionRequirement() {
        const isSubmit = true;

        if (!this.oProposal && this.sObjectName !== 'proposal__c') {
            this.showToast('Error', 'Proposal data is missing.', 'error');
            return;
        }

        updateSubmissionRequirement({
            oProposal: this.oProposal,
            oSubmissionRequirement: this.submissionRequirementRecord,
            notes: this.submissionRequirementNotes,
            isSubmit: isSubmit
        })
        .then(() => {
            this.showToast('Success', 'Record updated successfully', 'success');
            this.resetSubmissionRequirementState();
            this.fetchSubmissionRequirements(this.recordId);
            this.navigateToRecord(this.recordId);
        })
        .catch(error => {
            const message = error?.body?.message || error?.message || 'An unknown error occurred';
            this.showToast('Error', message, 'error');
        });
    }

    resetSubmissionRequirementState() {
        this.isShowACORDTemplet = false;
        this.isFileUploaded = false;
        this.isShowAddNote = false;
        this.submissionRequirementRecord = null;
        this.submissionRequirementNotes = null;
        this.selectedRecordId = null;
        this.natureofBusinessDescription = null;
    }


    showSpinner() {
        this.isLoading = true;
    }

    hideSpinner() {
        this.isLoading = false;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant,
        }));
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Submission_Requirement__c', 
                actionName: 'view'
            }
        });
    }
}