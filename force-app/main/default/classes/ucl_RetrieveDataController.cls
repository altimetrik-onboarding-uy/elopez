public with sharing class ucl_RetrieveDataController {
    @AuraEnabled
    public static void retrieveData() {
        ucl_AWSHandler.handleRetrieveData();
    }
}