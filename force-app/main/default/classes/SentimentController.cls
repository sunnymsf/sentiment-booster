public with sharing class SentimentController {
    
    // Method to get sentiment analysis info as JSON with connectedChatId parameter
    @AuraEnabled(cacheable=false)
    public static String getSentimentInfo(String connectedChatId) {
        // Create a map for sentiment info
        Map<String, Object> sentimentInfo = new Map<String, Object>();
        
        // Use the connectedChatId in the sentiment info if needed
        sentimentInfo.put('connectedChatId', connectedChatId);

        List<String> llmSuggestions = new List<String>();
        Integer frustrationScore;
        Set<Id> chatIds = new Set<Id>();
        //chatIds.add('a8Cal000000D5ebEAC');
        chatIds.add(connectedChatId);

        String mssg = SentimentController.processNewChatIds(chatIds);
        System.debug('Message From Chats: ' + mssg);
        Integer emojiFS = GetSentimentFromEmoji.getSentimentEmojiiScore(mssg);

        Map<Integer, List<String>> textBody = GetSentimentFromLLM.getSentimentScore(mssg);
        
        
        for (Integer key : textBody.keySet()) {
            llmSuggestions = textBody.get(key);
            System.debug('LLM Suggestion forecast: ' + llmSuggestions); 
            frustrationScore = key;
            System.debug('LLM Suggestion Frustration: ' + frustrationScore);
        }
        Decimal aggFS=0;
        if(emojiFS !=0){ 
            aggFS = (emojiFS*0.6) + (frustrationScore*0.4);
        }else { aggFS= frustrationScore;}
         
        System.debug('Aggregated frustrationScore ' + aggFS);
        sentimentInfo.put('frustrationScore', aggFS);
        
        // Create suggestions list
        List<Map<String, Object>> suggestions = new List<Map<String, Object>>();
        for (String suggestion : llmSuggestions) {
            System.debug('Suggestion: ' + suggestion);
            Map<String, Object> suggestionMap = new Map<String, Object>();
            suggestionMap.put('type', 'message');
            suggestionMap.put('content', suggestion);
            suggestions.add(suggestionMap);
        }
        
        // Set suggestions
        sentimentInfo.put('suggestions', suggestions);
        
        // Convert map to JSON string
        return JSON.serialize(sentimentInfo);
    }

    public static String processNewChatIds(Set<Id> chatIds) {
        // Query to fetch all Connected_Message__c records for the given Chat__c IDs, ordered by CreatedDate
        List<Connected_Message__c> messages = [
            SELECT Chat__c, Body__c 
            FROM Connected_Message__c 
            WHERE Chat__c IN :chatIds 
            AND Message_Type__c = 'inbound'
            ORDER BY Chat__c, CreatedDate ASC
        ];

        // Map to store Chat__c ID as the key and a list of messages (Body__c) as the value
        Map<Id, List<String>> chatMessagesMap = new Map<Id, List<String>>();
        
        // Process each message record
        for (Connected_Message__c message : messages) {
            if (message.Body__c != null) {
                if (chatMessagesMap.containsKey(message.Chat__c)) {
                    chatMessagesMap.get(message.Chat__c).add(message.Body__c);
                } else {
                    chatMessagesMap.put(message.Chat__c, new List<String>{message.Body__c});
                }
            }
        }

        // Build and print the aggregated message string in order
        String aggregatedDebugMessage = 'All Messages per Chat in Order:\n';
        for (Id chatId : chatMessagesMap.keySet()) {
            String messagesString = '';
            for (String message : chatMessagesMap.get(chatId)) {
                if (messagesString != '') {
                    messagesString += ', ';
                }
                messagesString += message;
            }
            aggregatedDebugMessage += 'Chat ID: ' + chatId + ' | Messages: ' + messagesString + '\n';
        }
        
        // Print the aggregated debug message
        System.debug(aggregatedDebugMessage);
        return aggregatedDebugMessage;
    }
    
    // Method to get sentiment analysis info as JSON with connectedChatId parameter (Dummy version)
    @AuraEnabled(cacheable=false)
    public static String getSentimentInfoDummy(String connectedChatId) {
        // Create a map for sentiment info
        Map<String, Object> sentimentInfo = new Map<String, Object>();
        
        // Use the connectedChatId in the sentiment info if needed
        sentimentInfo.put('connectedChatId', connectedChatId);

        // Set frustrationScore
        sentimentInfo.put('frustrationScore', 0.5);
        
        List<Map<String, Object>> suggestions = new List<Map<String, Object>>();
        
        Map<String, Object> suggestion1 = new Map<String, Object>();
        suggestion1.put('type', 'message');
        suggestion1.put('content', 'Thank you for reaching out to us');
        suggestions.add(suggestion1);
        
        Map<String, Object> suggestion2 = new Map<String, Object>();
        suggestion2.put('type', 'message');
        suggestion2.put('content', 'Sorry for the inconvenience');
        suggestions.add(suggestion2);
        
        // Set suggestions
        sentimentInfo.put('suggestions', suggestions);
        
        // Convert map to JSON string
        return JSON.serialize(sentimentInfo);
    }
}