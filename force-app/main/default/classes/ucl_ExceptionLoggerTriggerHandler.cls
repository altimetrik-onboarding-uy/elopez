/**
 * @date 03/27/2020
 * @author Altimetrik
 * 
 * class to handle Exception Logger Trigger
 */
public with sharing class ucl_ExceptionLoggerTriggerHandler {
    public static void handleDeleteException(List<Exception_Logger__c> loggedRecords) {
        for (Exception_Logger__c loggedRecord : loggedRecords) {
            if (!isOneOrMoreMonthsOld(loggedRecord.Creation_Date__c)) {
                loggedRecord.addError('Logs should be kept in the system for at least a month');
            }
        }
    }

    private static Boolean isOneOrMoreMonthsOld(Date creationDate) {
        return creationDate.monthsBetween(Date.today()) >= 1;
    }
}
