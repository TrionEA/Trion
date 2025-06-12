import { LightningElement, api } from 'lwc';
export default class TestIframe extends LightningElement {
  @api height = '500px';
  @api sandbox = '';
    @api url = "https://enabledanalytics.sharepoint.com/sites/Temp2/_layouts/15/embed.aspx?UniqueId=3a965c9c-4edf-4fb0-b614-57dd31d0b0da";
  @api width = '100%';
  
  renderedCallback() {
    
      const element = this.template.querySelector('iframe');
      element.sandbox = this.sandbox;
    
  }
}