/**
 * @date 03/27/2020
 * @author Altimetrik
 *
 * test class for Exception Logger Trigger
 */
@isTest
public with sharing class ucl_ExceptionLoggerTriggerTest {
    /**
     * @given the WFR 'Notify logged error'
     * @when an Exception is logged
     * @then exception is notified via email
     */
    @isTest
    static void testLoggedErrorNotifiedOnCreation() {
        Exception ex = getException();
        Test.startTest();
        new LogException().log(ex);
        Test.stopTest();

        List<Exception_Logger__c> allExceptionLogs = getAllExceptionLogs();

        System.assert(allExceptionLogs.get(0).Notified__c, 'Exception should have been notified');
    }

    /**
     * @given an Exception Log created less than a month ago
     * @when trying to delete the log
     * @then logic prevent the log to be deleted
     */
    @isTest
    static void testPreventLogDeletion() {
        new LogException().log(new DmlException());
        List<Exception_Logger__c> logs = getAllExceptionLogs();

        Test.startTest();
        try {
            delete logs;
            System.assert(false, 'Logic should have prevented log deletion');
        } catch (DmlException ex) {
            System.assert(
                ex.getMessage().contains('Logs should be kept in the system for at least a month'),
                'Logic should prevent log deletion'
            );
        }
        Test.stopTest();
    }

    /**
     * @given an Exception Log created more than a month ago
     * @when trying to delete the log
     * @then logic should not prevent the log to be deleted
     */
    @isTest
    static void testAllowLogDeletion() {
        new LogException().log(new DmlException());
        List<Exception_Logger__c> logs = getAllExceptionLogs();
        logs.get(0).Creation_Date__c = Date.today().addMonths(-1);

        update logs;

        Test.startTest();
        delete logs;
        Test.stopTest();

        List<Exception_Logger__c> allLogs = getAllExceptionLogs();
        System.assert(allLogs.isEmpty(), 'Logs should have been deleted');
    }

    private static List<Exception_Logger__c> getAllExceptionLogs() {
        return [SELECT Id, Notified__c, Creation_Date__c FROM Exception_Logger__c];
    }

    private static Exception getException() {
        DmlException ex = new DmlException();
        return ex;
    }
}
