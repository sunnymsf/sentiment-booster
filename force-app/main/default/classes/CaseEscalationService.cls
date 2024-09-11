public with sharing class CaseEscalationService {

    // Method to escalate a case based on the case Id
    @AuraEnabled(cacheable=false)
    public static void escalateCase(Id connectedChatId) {

        Connected_Chat__c connectedChat = [SELECT Id, Case__c FROM Connected_Chat__c WHERE Id = :connectedChatId LIMIT 1];

        System.debug('CaseId: ' + connectedChat.Case__c);

        String caseNumber='00001323';
        
		Case caseRecord = [SELECT CaseNumber, Status, Priority, OwnerId, IsEscalated FROM Case WHERE Id = :connectedChat.Case__c LIMIT 1];
        //Case caseRecord = [SELECT CaseNumber, Status, Priority, OwnerId, IsEscalated FROM Case WHERE CaseNumber = :caseNumber LIMIT 1];
        
        if (caseRecord != null) {
            // Set the case as escalated
            caseRecord.Priority = 'High';  // Set priority to 'High'
            caseRecord.Status = 'Escalated';  // Change status to 'Escalated'
            caseRecord.IsEscalated = true;  // Custom checkbox field to mark as escalated
            
            // Assign the case to the escalation queue (Replace with the correct Queue Id)
            //caseRecord.OwnerId = '005xx000001SvDDAA0';  // Example Queue ID
            
            // Update the case record
            update caseRecord;
            
            // Optional: Log the escalation
            System.debug('Case ' + caseRecord.Id + ' has been escalated.');
        } else {
            // Handle the case where the case is not found
            System.debug('No case found with Id: ' + CaseNumber);
        }
    }
}