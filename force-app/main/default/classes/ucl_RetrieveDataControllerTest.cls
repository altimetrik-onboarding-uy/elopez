/**
 * @date 03/27/2020
 * @author Altimetrik
 *
 * test class for data retrieval
 */
@isTest
public with sharing class ucl_RetrieveDataControllerTest {
    /**
     * @given a service to retrieve data from AWS bucket
     * @when service is invoked
     * @then all Enabled Legal Advisors are created
     * @and Clients are associated to their Legal Advisors
     * @and Disabled Legal Advisors are skipped
     */
    @isTest
    static void testInsertEnabledSkipDisabledLegalAdvisors() {
        List<Legal_Advisor__c> currentAdvisors = getAllAdvisors();
        List<Client__c> currentClients = getAllClients();

        setTestMock();
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Legal_Advisor__c> allAdvisors = getAllAdvisors();
        List<Legal_Advisor__c> allEnabledAdvisors = getAllEnabledAdvisors();
        List<Client__c> allClients = getAllClients();

        System.assertEquals(
            currentAdvisors.size() + 2,
            allAdvisors.size(),
            'Two Legal Advisors should have been created'
        );

        System.assertEquals(allAdvisors, allEnabledAdvisors, 'All new Legal Advisors should be Enabled');
        System.assertEquals(currentClients.size() + 4, allClients.size(), 'Four Clients should have been created');
    }

    /**
     * @given an Enabled Legal Advisor
     * @when Legal Advisor is retrieved as Disabled from AWS bucket
     * @then Legal Advisor Status should be updated to Disabled
     */
    @isTest
    static void testUpdateEnabledLegalAdvisors() {
        // using the same Number from static resource
        Legal_Advisor__c existingAdvisor = getLegalAdvisor(
            '768asdas-e7c4-4789-a465-1734886633d2',
            Constants.LEGAL_ADVISORS.STATUS_ENABLED
        );

        setTestMock();
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Legal_Advisor__c> updatedAdvisor = getAdvisorById(existingAdvisor.Id);

        System.assertEquals(
            Constants.LEGAL_ADVISORS.STATUS_DISABLED,
            updatedAdvisor.get(0).Status__c,
            'Advisor should have been disabled'
        );
    }

    /**
     * @given a Disabled Legal Advisor
     * @when Legal Advisor is retrieved as Enabled from AWS bucket
     * @then Legal Advisor Status should be updated to Enabled
     */
    @isTest
    static void testUpdateDisabledLegalAdvisors() {
        // using the same Number from static resource
        Legal_Advisor__c existingAdvisor = getLegalAdvisor(
            '9afccdd3-e7c4-4789-a465-1734886633d2',
            Constants.LEGAL_ADVISORS.STATUS_DISABLED
        );

        setTestMock();
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Legal_Advisor__c> updatedAdvisor = getAdvisorById(existingAdvisor.Id);

        System.assertEquals(
            Constants.LEGAL_ADVISORS.STATUS_ENABLED,
            updatedAdvisor.get(0).Status__c,
            'Advisor should have been enabled'
        );
    }

    /**
     * @given an Enabled Legal Advisor
     * @when Legal Advisor is not retrieved from AWS bucket
     * @then Legal Advisor should be removed from the system
     */
    @isTest
    static void testRemoveNotRetrievedLegalAdvisors() {
        // using different Number than the ones from static resource
        Legal_Advisor__c existingAdvisor = getLegalAdvisor(
            'different-advisor-number',
            Constants.LEGAL_ADVISORS.STATUS_ENABLED
        );

        setTestMock();
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Legal_Advisor__c> updatedAdvisor = getAdvisorById(existingAdvisor.Id);

        System.assertEquals(0, updatedAdvisor.size(), 'Not retrieved Advisors should have been removed');
    }

    /**
     * @given a Disabled Legal Advisor
     * @when Legal Advisor is retrieved as Disabled from AWS bucket
     * @then Legal Advisor should be removed from the system
     */
    @isTest
    static void testRemoveDisabledRetrievedLegalAdvisors() {
        // using the same Number from static resource
        Legal_Advisor__c existingAdvisor = getLegalAdvisor(
            '768asdas-e7c4-4789-a465-1734886633d2',
            Constants.LEGAL_ADVISORS.STATUS_DISABLED
        );

        setTestMock();
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Legal_Advisor__c> updatedAdvisor = getAdvisorById(existingAdvisor.Id);

        System.assertEquals(
            0,
            updatedAdvisor.size(),
            'Existing disabled Advisors should be removed when retrieved as disabled'
        );
    }

    /**
     * @given an existing not manually added Client
     * @when Client is not retrieved from AWS bucket
     * @then Client should be removed
     */
    @isTest
    static void testRemoveClientsNotRetrieved() {
        // using the same Number from static resource
        Legal_Advisor__c existingAdvisor = getLegalAdvisor(
            '768asdas-e7c4-4789-a465-1734886633d2',
            Constants.LEGAL_ADVISORS.STATUS_ENABLED
        );

        // using a different number than the ones from static resource
        Client__c existingClient = getClient('different-client-number', false, existingAdvisor.Id);

        setTestMock();
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Client__c> updatedClient = getClientById(existingClient.Id);

        System.assertEquals(
            0,
            updatedClient.size(),
            'Existing not manually added Clients should be removed when not retrieved'
        );
    }

    /**
     * @given an existing manually added Client
     * @when Client is not retrieved from AWS bucket
     * @then Client should not be removed
     */
    @isTest
    static void testManuallyAddedClientsNotRetrieved() {
        // using the same Number from static resource
        Legal_Advisor__c existingAdvisor = getLegalAdvisor(
            '768asdas-e7c4-4789-a465-1734886633d2',
            Constants.LEGAL_ADVISORS.STATUS_ENABLED
        );

        // using a different number than the ones from static resource
        Client__c existingClient = getClient('different-client-number', true, existingAdvisor.Id);

        setTestMock();
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Client__c> updatedClient = getClientById(existingClient.Id);

        System.assertEquals(
            existingClient,
            updatedClient.get(0),
            'Existing manually added Clients should not be removed'
        );
    }

    /**
     * @given a service to retrieve data from AWS bucket
     * @when service fails
     * @then an error should be logged in the system
     */
    @isTest
    static void testErrorLogged() {
        List<Exception_Logger__c> currentLoggedErrors = getLoggedErrors();

        setTestMock('makeitfail');
        Test.startTest();
        ucl_RetrieveDataController.retrieveData();
        Test.stopTest();

        List<Exception_Logger__c> allLoggedErrors = getLoggedErrors();

        System.assertEquals(currentLoggedErrors.size() + 1, allLoggedErrors.size(), 'An error should be logged');
    }

    private static Legal_Advisor__c getLegalAdvisor(String advisorNumber, String AdvisorStatus) {
        Legal_Advisor__c advisor = new Legal_Advisor__c(
            Number__c = advisorNumber,
            Name = '[Test] Advisor',
            Status__c = advisorStatus,
            As_of_Date__c = Date.today()
        );

        insert advisor;

        return advisor;
    }

    private static Client__c getClient(String clientNumber, Boolean addedManually, Id advisorId) {
        Client__c client = new Client__c(
            First_Name__c = '[TEST] First',
            Last_Name__c = '[TEST] Last',
            Email__c = 'test@email.com',
            Phone__c = '8919234123',
            Number__c = clientNumber,
            Added_Manually__c = addedManually,
            Legal_Advisor__c = advisorId
        );

        insert client;

        return client;
    }

    private static List<Legal_Advisor__c> getAllAdvisors() {
        return [SELECT Id FROM Legal_Advisor__c];
    }

    private static List<Legal_Advisor__c> getAllEnabledAdvisors() {
        return [SELECT Id FROM Legal_Advisor__c WHERE Status__c = :Constants.LEGAL_ADVISORS.STATUS_ENABLED];
    }

    private static List<Legal_Advisor__c> getAdvisorById(Id advisorId) {
        return [SELECT Id, Status__c FROM Legal_Advisor__c WHERE Id = :advisorId];
    }

    private static List<Client__c> getAllClients() {
        return [SELECT Id FROM Client__c];
    }

    private static List<Client__c> getClientById(Id clientId) {
        return [
            SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c, Number__c, Added_Manually__c, Legal_Advisor__c
            FROM Client__c
            WHERE Id = :clientId
        ];
    }

    private static List<Exception_Logger__c> getLoggederrors() {
        return [SELECT Id FROM Exception_Logger__c];
    }

    private static void setTestMock() {
        setTestMock('uclawyers');
    }
    private static void setTestMock(String staticResource) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(staticResource);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);
    }
}
