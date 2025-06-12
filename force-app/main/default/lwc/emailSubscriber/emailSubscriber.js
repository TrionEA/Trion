import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import EMAIL_CHANNEL from '@salesforce/messageChannel/EmailDataMessageChannel__c';

export default class EmailSubscriber extends LightningElement {
    @wire(MessageContext)
    messageContext;

    emailSubject = '';
    emailBody = '';

    // Subscribe to the message channel
    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            EMAIL_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Handle incoming messages
    handleMessage(message) {
        this.emailSubject = message.subject || '';
        this.emailBody = message.body || '';
    }

    // Unsubscribe from the message channel when component is disconnected
    disconnectedCallback() {
        unsubscribe(this.subscription);
    }
}