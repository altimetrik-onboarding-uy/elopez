trigger ucl_ExceptionLoggerTrigger on Exception_Logger__c (before delete) {
    if (Trigger.isBefore && Trigger.isDelete) {
        ucl_ExceptionLoggerTriggerHandler.handleDeleteException(Trigger.Old);
    }
}