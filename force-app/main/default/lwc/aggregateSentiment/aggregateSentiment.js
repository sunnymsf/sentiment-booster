import { LightningElement, track, wire } from 'lwc';
import getAggregatedSentiments from '@salesforce/apex/AggregateSentimentController.getAggregatedSentiments';

export default class AggregateSentiment extends LightningElement {
    @track sentiments = [];
    @track error;

    @wire(getAggregatedSentiments)
    wiredSentiments({ error, data }) {
        if (data) {
            // Map sentiments to include an emoji and a border color based on the frustration score
            this.sentiments = data.map(sentiment => ({
                ...sentiment,
                emoji: this.getEmojiForFrustrationScore(sentiment.frustrationScore__c),
                borderStyle: `border-color: ${this.getBorderColorForFrustrationScore(sentiment.frustrationScore__c)}`
            }));
            this.error = undefined; // Reset error when data is successfully fetched
        } else if (error) {
            this.error = error;
            this.sentiments = []; // Clear sentiments on error
            console.error('Error fetching sentiments:', error);
        }
    }

    handleItemClick(event) {
        console.log("Navigating to chat details", event)

        const connectedChatId = event.currentTarget.dataset.id;
        const url = `/lightning/r/Connected_Chat__c/${connectedChatId}/view`;

        window.open(url, '_blank'); 
    }

    getEmojiForFrustrationScore(score) {
        if (score === 10) return '😡'; // Angry
        if (score >= 8) return '😠';    // Very Frustrated
        if (score >= 6) return '😕';    // Frustrated
        if (score >= 4) return '😐';    // Neutral
        if (score >= 2) return '🙂';    // Satisfied
        return '😃';                   // Happy
    }

    getBorderColorForFrustrationScore(score) {
        if (score >= 10) return '#ff0000'; // Red
        if (score >= 9) return '#ff3333'; // Light Red
        if (score >= 8) return '#ff6666'; // Light Coral
        if (score >= 7) return '#ff9966'; // Light Orange
        if (score >= 6) return '#ffcc66'; // Light Yellow
        if (score >= 5) return '#ffff66'; // Pale Yellow
        if (score >= 4) return '#ccffcc'; // Light Green
        if (score >= 3) return '#99ff99'; // Pale Green
        if (score >= 2) return '#66ff66'; // Light Green
        if (score >= 1) return '#33ff33'; // Medium Green
        return '#00ff00'; // Bright Green
    }

}
