public with sharing class LogException extends Exception {
    public String moduleName { get; set; }
    public String stackTrace { get; set; }
    public String className { get; set; }
    public String methodName { get; set; }
    public String exceptionCause { get; set; }

    public void log(Exception ex) {
        try {
            extractExceptionData(ex);
            writeToObject(ex);
        } catch (Exception e) {
            new LogException().module('LogException').log(e);
        }
    }

    public LogException module(String name) {
        moduleName = name;
        return this;
    }

    public LogException exceptionCause(String cause) {
        exceptionCause = cause;
        return this;
    }

    public void extractExceptionData(Exception ex) {
        try {
            stackTrace = ex.getStackTraceString().substringBefore('\n');
            className = stackTrace.substringAfter('.').substringBefore('.');
            methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
        } catch (Exception e) {
            new LogException().module('LogException').log(e);
        }
    }

    public void writeToObject(Exception ex) {
        try {
            Exception_Logger__c logger = new Exception_Logger__c();
            logger.module_Name__c = moduleName;
            logger.stack_Trace__c = ex.getStackTraceString();
            logger.class_Name__c = className;
            logger.method_Name__c = methodName;
            logger.line_Number__c = ex.getLineNumber();
            logger.exception_Type__c = ex.getTypeName();
            logger.exception_Cause_Override__c = ExceptionCause;
            logger.exception_Cause__c = String.valueOf(ex.getCause());

            logger.exception_Message__c = ex.getMessage();

            insert logger;
        } catch (Exception e) {
            new LogException().module('LogException').log(e);
        }
    }
}