import { LightningElement, api, wire, track } from 'lwc';
import getSentimentInfo from '@salesforce/apex/SentimentController.getSentimentInfo';

export default class SentimentDashboard extends LightningElement {
    @api recordId;
    @track sentimentInfo;
    @track error;
    @track lastUpdated; // To store last updated time
    @track isLoading = false; // To control the loading indicator

    pollInterval = 5000; // Polling interval in milliseconds
    pollingId; // To store the polling interval ID

    connectedCallback() {
        this.startPolling();
    }

    disconnectedCallback() {
        this.stopPolling();
    }

    startPolling() {
        this.pollingId = setInterval(() => {
            this.fetchSentimentInfo();
        }, this.pollInterval);
    }

    stopPolling() {
        if (this.pollingId) {
            clearInterval(this.pollingId);
        }
    }

    fetchSentimentInfo() {
        this.isLoading = true; // Show loading indicator
        getSentimentInfo({ connectedChatId: this.recordId })
            .then(data => {
                this.sentimentInfo = JSON.parse(data);
                this.lastUpdated = this.getCurrentDateTime(); // Update last updated time
                this.error = undefined;
                console.log("Fetched latest data",this.sentimentInfo)
            })
            .catch(error => {
                this.error = error;
                this.sentimentInfo = undefined;
                this.lastUpdated = undefined;
            })
            .finally(() => {
                this.isLoading = false; // Hide loading indicator
            });
    }

    get formattedSuggestions() {
        return this.sentimentInfo?.suggestions || [];
    }

    get lastUpdatedDisplay() {
        return this.lastUpdated ? `Last Updated: ${this.lastUpdated}` : 'Last Updated: N/A';
    }

    getCurrentDateTime() {
        const now = new Date();
        const options = {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            timeZone: 'Asia/Kolkata',
            timeZoneName: 'short'
        };
        return new Intl.DateTimeFormat('en-IN', options).format(now);
    }

    handleCopy(event) {
        const content = event.target.closest('li').querySelector('.suggestion-text').textContent.trim();
        navigator.clipboard.writeText(content).then(() => {
            console.log('Copied to clipboard:', content);
        }).catch(err => {
            console.error('Failed to copy:', err);
        });
    }
}
