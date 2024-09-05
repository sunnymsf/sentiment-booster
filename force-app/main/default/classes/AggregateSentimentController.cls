public with sharing class AggregateSentimentController {
    @AuraEnabled(cacheable=true)
    public static List<AggregatedSentiment__c> getAggregatedSentiments() {
        return [
            SELECT Summary__c, Duration__c, AgentName__c, FrustrationScore__c, 	ConnectedChatId__c
            FROM AggregatedSentiment__c
            ORDER BY FrustrationScore__c DESC
            LIMIT 50
        ];
    }
}
