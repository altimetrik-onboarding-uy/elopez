/**
 * @date 03/27/2020
 * @author Altimetrik
 */
@isTest
public with sharing class ucl_RetrieveDataSchedulerTest {

    /**
     * @given ucl_RetrieveDataScheduler
     * @when class is scheduled
     * @then a new scheduled job should be created
     */
    @isTest
    static void testRetrieveDataScheduler() {
        List<CronTrigger> currentJobs = getAllJobs();

        ucl_RetrieveDataScheduler job = new ucl_RetrieveDataScheduler();
        String chron = '0 0 23 * * ?';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('uclawyers');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        System.schedule('Retrieve Data Job', chron, job);
        Test.stopTest();

        List<CronTrigger> newJobs = getAllJobs();

        System.assertEquals(currentJobs.size() + 1, newJobs.size(), 'A new job should have been scheduled');
    }

    private static List<CronTrigger> getAllJobs() {
        return [SELECT Id FROM CronTrigger];
    }
}
