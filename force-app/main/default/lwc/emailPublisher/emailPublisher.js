import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class EmailPublisher extends NavigationMixin(LightningElement) {
    emailSubject = '';
    emailBody = '';

    handleSubjectChange(event) {
        this.emailSubject = event.target.value;
    }

    handleBodyChange(event) {
        this.emailBody = event.target.value;
    }

    publishEmailData() {
        // Construct URL parameters
        const queryParams = {
            subject: this.emailSubject,
            body: this.emailBody,
            // Add more parameters as needed
        };

        // Navigate to custom web page with URL parameters
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/n/EmailMessages?' + this.constructQueryString(queryParams)
            },
        });
    }

    // Helper function to construct query string from object
    constructQueryString(params) {
        return Object.keys(params)
            .map(key => key + '=' + encodeURIComponent(params[key]))
            .join('&');
    }
}