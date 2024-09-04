public with sharing class CaseController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases() {
        return [SELECT Id, CaseNumber, Subject, Status, Priority FROM Case ORDER BY CreatedDate DESC LIMIT 50];
    }
}