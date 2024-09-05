import { LightningElement, api, track } from 'lwc';
import getSentimentInfo from '@salesforce/apex/SentimentController.getSentimentInfo';
import escalateCase from '@salesforce/apex/CaseEscalationService.escalateCase';

export default class SentimentDashboard extends LightningElement {
    @api recordId;
    @track sentimentInfo;
    @track error;
    @track isLoading = false;
    isFetching = false
    @track editingIndex = null;
    @track lastUpdatedDisplay = '';
    @track showEscalateButton = true;

    pollingInterval = 300000; // Polling interval in milliseconds

    connectedCallback() {
        this.isLoading = true;
        this.fetchSentimentInfo();
        this.startPolling();
    }

    disconnectedCallback() {
        this.stopPolling();
    }

    startPolling() {
        this.pollingId = setInterval(() => {
            this.fetchSentimentInfo();
        }, this.pollingInterval);
    }

    stopPolling() {
        clearInterval(this.pollingId);
    }

    fetchSentimentInfo() {
        if (!this.isFetching) {
            this.isFetching = true;
            getSentimentInfo({ connectedChatId: this.recordId })
                .then((data) => {
                    this.sentimentInfo = JSON.parse(data);
                    this.updateSuggestionsWithEditingState();
                    this.lastUpdatedDisplay = this.getCurrentDateTime();
                    //this.showEscalateButton = this.sentimentInfo.frustrationScore > 0.8;
                    this.error = undefined;
                    console.log('Data fetched:', data);
                })
                .catch((error) => {
                    this.error = error;
                    this.sentimentInfo = undefined;
                    console.error('Error fetching data:', error);
                })
                .finally(() => {
                    this.isLoading = false;
                    this.isFetching = false;
                });
        }
    }

    updateSuggestionsWithEditingState() {
        if (this.sentimentInfo && this.sentimentInfo.suggestions) {
            this.sentimentInfo.suggestions = this.sentimentInfo.suggestions.map((suggestion, index) => {
                return { ...suggestion, isEditing: index === this.editingIndex };
            });
        }
    }

    get formattedSuggestions() {
        return this.sentimentInfo?.suggestions || [];
    }

    get frustrationScore() {
        return this.sentimentInfo?.frustrationScore * 10 || 50
    }

    handleEdit(event) {
        this.editingIndex = parseInt(event.currentTarget.dataset.index, 10);
        this.updateSuggestionsWithEditingState();
    }

    handleSave() {
        this.editingIndex = null;
        this.updateSuggestionsWithEditingState();
    }

    handleCopy(event) {
        const content = event.currentTarget.dataset.content;
        navigator.clipboard.writeText(content).then(() => {
            console.log('Copied to clipboard:', content);
        });
    }

    handleEscalate() {
        escalateCase({ connectedChatId: this.recordId })
            .then(() => {
                console.log('Case escalated successfully.');
            })
            .catch(error => {
                console.error('Error escalating case:', error);
            });
    }

    getCurrentDateTime() {
        const now = new Date();
        const options = { timeZone: 'Asia/Kolkata', hour12: true };
        const date = now.toLocaleDateString('en-IN', options);
        const time = now.toLocaleTimeString('en-IN', options);
        return `*Last updated : ${date}, ${time}`;
    }
}
