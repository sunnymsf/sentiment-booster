public class GetSentimentFromEmoji {
    
   public static List<String> extractEmojis(String input) {
        // Regular expression to match emojis (Unicode ranges for emojis)
         List<String> htmlEntities = new List<String>();

        // Regular expression to match HTML entities in the format &#xxxx; or &#xhhh;
        String entityPattern = '&#[0-9]{4,6};'; // For decimal entities
        Pattern myPattern = Pattern.compile(entityPattern);
        Matcher myMatcher = myPattern.matcher(input);

        // Iterate through the matches and add them to the list
        while (myMatcher.find()) {
            htmlEntities.add(myMatcher.group());
        }

        return htmlEntities;
    }
    
    public static Integer getSentimentEmojiiScore(String message)
    {
        List<String> allEmojis = extractEmojis(message);
        Integer frustrationScore = 0;
        Integer emojiCount = allEmojis.size();
        if(emojiCount == 0)
        {
            return 0;
        }
        
        String myemoji='';
        for (String emoji : allEmojis) {
           myemoji= myemoji + emoji;
            
    	System.debug('Emoji: ' + emoji);
		}
        String addon = 'You are a sentiment analysis assistant. Given the following emojis, your task is to assess the level of frustration expressed in them. Provide a frustration score on a scale from 0 to 10, where 0 means not frustrating at all and 10 means extremely frustrating. Please return response in Json , with field as frustation_score **Emojis:**';
             // Define the specific prompt value
        String decodedEmojis = myemoji.replaceAll('&#128578;', String.valueOf('\uD83D\uDE42'));
		String decodedEmoji = decodedEmojis.replaceAll('&#128545;', String.valueOf('\uD83D\uDE21'));
        
        // Combine the strings
        String combinedString = addon + ' ' + decodedEmoji;
        
         System.debug('Combined Emojiess'+combinedString);
        	aiplatform.ModelsAPI.createGenerations_Request request = new aiplatform.ModelsAPI.createGenerations_Request();

		// Specify model
		request.modelName = 'sfdc_ai__DefaultGPT35Turbo';

		// Create request body
		aiplatform.ModelsAPI_GenerationRequest requestBody = new aiplatform.ModelsAPI_GenerationRequest();
		request.body = requestBody;
        requestBody.prompt = combinedString;
        
        
        try {
    	// Make request
    	aiplatform.ModelsAPI modelsAPI = new aiplatform.ModelsAPI();
    	aiplatform.ModelsAPI.createGenerations_Response response = modelsAPI.createGenerations(request);
        //JSONObject jsonObject = new JSONObject(response.Code200.generation.generatedText);  
        Map<String, Object> jsonObject = (Map<String, Object>)JSON.deserializeUntyped(response.Code200.generation.generatedText);    
    	 frustrationScore = (Integer)jsonObject.get('frustration_score');
            
            
            System.debug('Frustation Score from Emojii: ' + frustrationScore);
          
         
            
            

	// Handle error
		} catch(aiplatform.ModelsAPI.createGenerations_ResponseException e) {
    	System.debug('Response code: ' + e.responseCode);
    	System.debug('The following exception occurred: ' + e);
		} 
        
        
        
        return frustrationScore;
        
        
    }

}