import { LightningElement, api, wire, track } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/TrionPurgeFiles.getRelatedFilesByRecordId';
import {NavigationMixin} from 'lightning/navigation'


export default class TrionCaseFiles extends NavigationMixin(LightningElement) {

    @api recordId;
    filesList =[];
    filesToDisplay = [];
    showFiles = false;

    get cardLabel() {
        return 'Files (' + this.filesList.length + ')';
    }

    @wire(getRelatedFilesByRecordId, {recordId: '$recordId'})
    wiredResult({data, error}){ 
        if(data){ 
            console.log(data);
            this.filesList = data.map(item => ({
             "label": item.Title,
             "value": item.ContentDocumentId,
             "fileExtension": item.FileExtension,
             "createdDate": item.CreatedDate,
             "contentSize": item.ContentSize,
             "downloadUrl": "/sfc/servlet.shepherd/document/download/" + item.ContentDocumentId 
        }));
        this.filesToDisplay = this.filesList.slice(0,2);
        this.showFiles = this.filesToDisplay.length > 0 ? true : false;
        console.log("filesList: ", this.filesList);
        }
        if(error){ 
            console.error('Error occurred retrieving File records...', error);
        }
    }
 

  openPreview(event) {
    event.preventDefault();
    const selectedContentDocumentId = event.target.dataset.id;
    const selectedFile = this.filesList.find(file => file.value === selectedContentDocumentId);

    if (selectedFile) {
        const showPreview = this.template.querySelector("c-file-preview");
        if (showPreview) {
            showPreview.fileDetails = selectedFile;
            showPreview.show();
            console.log('Modal opened');
        }
    }
  }

  showAllFiles(){
      var compDefinition = {
            componentDef: "c:trionAllCaseFiles",
            attributes: {
                recordId : this.recordId
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
  }
}