/**
 * @date 03/27/2020
 * @author Altimetrik
 * 
 * Class to schedule data retrieval
 */
global with sharing class ucl_RetrieveDataScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        ucl_AWSHandler.handleRetrieveData();
    }
}
