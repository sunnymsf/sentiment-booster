public class GetSentimentFromLLM {
  
    
    
     public static Map<Integer, List<String>> getSentimentScore(String message) {
        
         //Map<String, Object>
         String addon = 'You are a sentiment analysis assistant. Given the following messages, your task is to assess the level of frustration expressed in them. Provide a frustration score on a scale from 0 to 10, where 0 means not frustrating at all and 10 means extremely frustrating. Additionally, suggest a few responses that could help in improving the sentiment and reducing the frustration score.\n\n**Instructions:**\n1. **Frustration Score**: Provide a numerical score from 0 to 10 that best represents the level of frustration in the messages.\n2. **Suggested Responses**: Suggest a few empathetic and constructive responses that could help in improving the sentiment of the messages.\n\n**Example:**\nMessages: "I can\'t believe how long this is taking. This is so frustrating!"\nFrustration Score: 8\nSuggested Responses:\n1. "I understand how this situation could be frustrating. We\'re working hard to resolve the issue as quickly as possible."\n2. "I’m really sorry for the delay. Is there anything specific I can do to assist you further?"\n\n**Please follow these instructions carefully to ensure accurate and helpful responses.** Also Please return response in Json , with fields as frustation_score and suggestions as array ** **Messages:**';
             // Define the specific prompt value
        //String promptValue = 'tell multiple jokes, each in a different response';
        
        // Combine the strings
        String combinedString = addon + ' ' + message;
        
         System.debug(combinedString);
         	// Create generate text request
		aiplatform.ModelsAPI.createGenerations_Request request = new aiplatform.ModelsAPI.createGenerations_Request();

		// Specify model
		request.modelName = 'sfdc_ai__DefaultGPT35Turbo';

		// Create request body
		aiplatform.ModelsAPI_GenerationRequest requestBody = new aiplatform.ModelsAPI_GenerationRequest();
		request.body = requestBody;

		// Add prompt to body
		requestBody.prompt = combinedString;
         Integer frustrationScore;
         List<Object> suggestionsObject;
         List<String> suggestions;
         
        try {
    	// Make request
    	aiplatform.ModelsAPI modelsAPI = new aiplatform.ModelsAPI();
    	aiplatform.ModelsAPI.createGenerations_Response response = modelsAPI.createGenerations(request);
        //JSONObject jsonObject = new JSONObject(response.Code200.generation.generatedText);  
        Map<String, Object> jsonObject = (Map<String, Object>)JSON.deserializeUntyped(response.Code200.generation.generatedText);    
    	 frustrationScore = (Integer)jsonObject.get('frustration_score');
            
            
            System.debug('Frustation Score: ' + frustrationScore);
          suggestionsObject = (List<Object>)jsonObject.get('suggestions');

		// Convert the List<Object> to List<String>
		 suggestions = new List<String>();
			for (Object suggestion : suggestionsObject) {
    		suggestions.add((String)suggestion);
			}   
            System.debug('Suggestions: ' + suggestions);
         
            
            

	// Handle error
		} catch(aiplatform.ModelsAPI.createGenerations_ResponseException e) {
    	System.debug('Response code: ' + e.responseCode);
    	System.debug('The following exception occurred: ' + e);
		} 
        
         // Correct initialization
		Map<Integer, List<String>> result = new Map<Integer, List<String>>();

         result.put(frustrationScore,suggestions);
         
         return result;
         
       
         
        
         
    }

}