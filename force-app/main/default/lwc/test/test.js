import { LightningElement, api } from 'lwc';

export default class TestIframe extends LightningElement {
    @api height = '500px';
    @api sandbox = '';
    @api url = "https://trionworks.sharepoint.com/sites/SalesforceArchive/_layouts/15/embed.aspx?UniqueId=F58554BE-9431-425B-9F7B-2AACCFA68E87";
    @api width = '100%';
}