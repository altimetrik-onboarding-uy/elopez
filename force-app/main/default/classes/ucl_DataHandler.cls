public with sharing class ucl_DataHandler {
    public static void handleData(ucl_LegalAccountsResponse legalAccountsResponse) {
        Map<String, ucl_LegalAccount> newAdvisorsByNumber = getNewAdvisorsByNumber(legalAccountsResponse.legalAccounts);
        deleteMissingLegalAdvisors(newAdvisorsByNumber);
        List<ucl_LegalAccount> accountsToUpsert = filterAdvisorsToUpsert(newAdvisorsByNumber);

        Map<String, ucl_LegalAccount.Client> newClientsByExternalId = getNewClientsByExternalId(accountsToUpsert);
        deleteMissingClients(newClientsByExternalId);

        saveNewAdvisorAndClients(accountsToUpsert);
    }

    private static void deleteMissingLegalAdvisors(Map<String, ucl_LegalAccount> newAdvisorsByNumber) {
        List<Legal_Advisor__c> currentAdvisors = getAllLegalAdvisors();
        List<Legal_Advisor__c> advisorsToDelete = new List<Legal_Advisor__c>();

        for (Legal_Advisor__c advisor : currentAdvisors) {
            if (!newAdvisorsByNumber.containsKey(advisor.Number__c)) {
                advisorsToDelete.add(advisor);
            } else if (
                newAdvisorsByNumber.get(advisor.Number__c).accountStatus == Constants.LEGAL_ADVISORS.STATUS_DISABLED &&
                advisor.Status__c == Constants.LEGAL_ADVISORS.STATUS_DISABLED
            ) {
                advisorsToDelete.add(advisor);
            }
        }

        delete advisorsToDelete;
    }

    private static List<ucl_LegalAccount> filterAdvisorsToUpsert(Map<String, ucl_LegalAccount> newAdvisorsByNumber) {
        List<Legal_Advisor__c> currentAdvisors = getAllLegalAdvisors();
        Map<String, Legal_Advisor__c> currentAdvisorsByNumber = getCurrentAdvisorsByNumber(currentAdvisors);
        List<ucl_LegalAccount> accountsToUpsert = new List<ucl_LegalAccount>();

        for (ucl_LegalAccount newAdvisor : newAdvisorsByNumber.values()) {
            Legal_Advisor__c currentAdvisor = currentAdvisorsByNumber.get(newAdvisor.accountNumber);
            if (advisorShouldBeUpserted(newAdvisor, currentAdvisor)) {
                accountsToUpsert.add(newAdvisor);
            }
        }

        return accountsToUpsert;
    }

    private static void deleteMissingClients(Map<String, ucl_LegalAccount.Client> newClientsByExternalId) {
        List<Client__c> currentClients = getAllClients();
        List<Client__c> clientsToDelete = new List<Client__c>();

        for (Client__c client : currentClients) {
            if (!newClientsByExternalId.containsKey(client.Client_Unique_Id__c) && !client.Added_Manually__c) {
                clientsToDelete.add(client);
            }
        }

        delete clientsToDelete;
    }

    private static void saveNewAdvisorAndClients(List<ucl_LegalAccount> newAdvisors) {
        List<Legal_Advisor__c> advisors = new List<Legal_Advisor__c>();
        List<Client__c> clients = new List<Client__c>();

        Map<String, List<Client__c>> clientsByAdvisor = new Map<String, List<Client__c>>();

        for (ucl_LegalAccount newAdvisor : newAdvisors) {
            Legal_Advisor__c advisor = buildLegalAdvisor(newAdvisor);
            advisors.add(advisor);

            clientsByAdvisor.put(advisor.Number__c, new List<Client__c>());
            for (ucl_LegalAccount.Client client : newAdvisor.clients) {
                clientsByAdvisor.get(advisor.Number__c).add(buildClient(client));
            }
        }

        upsert advisors Legal_Advisor__c.Fields.Number__c;

        for (Legal_Advisor__c advisor : advisors) {
            if (clientsByAdvisor.containsKey(advisor.Number__c)) {
                List<Client__c> clientsToUpdate = clientsByAdvisor.get(advisor.Number__c);

                for (Client__c client : clientsToUpdate) {
                    client.Legal_Advisor__c = advisor.Id;
                    client.Client_Unique_Id__c = advisor.Number__c + client.Number__c;
                    clients.add(client);
                }
            }
        }

        upsert clients Client__c.Fields.Client_Unique_Id__c;
    }

    private static Legal_Advisor__c buildLegalAdvisor(ucl_LegalAccount newAdvisor) {
        return new Legal_Advisor__c(
            Name = newAdvisor.accountName,
            Number__c = newAdvisor.accountNumber,
            Status__c = newAdvisor.accountStatus,
            As_of_Date__c = Date.parse(newAdvisor.asOfDate)
        );
    }

    private static Client__c buildClient(ucl_LegalAccount.Client newClient) {
        return new Client__c(
            First_Name__c = newClient.firstName,
            Last_Name__c = newClient.lastName,
            Email__c = newClient.email,
            Phone__c = newClient.phone,
            Address__c = newClient.address,
            Number__c = newClient.clientNumber,
            Added_Manually__c = false
        );
    }

    private static Map<String, ucl_LegalAccount.Client> getNewClientsByExternalId(List<ucl_LegalAccount> newAdvisors) {
        Map<String, ucl_LegalAccount.Client> newClients = new Map<String, ucl_LegalAccount.Client>();

        for (ucl_LegalAccount advisor : newAdvisors) {
            List<ucl_LegalAccount.Client> advisorClients = advisor.Clients;
            for (ucl_LegalAccount.Client client : advisorClients) {
                newClients.put(advisor.AccountNumber + client.ClientNumber, client);
            }
        }

        return newClients;
    }

    private static Boolean advisorShouldBeUpserted(ucl_LegalAccount newAdvisor, Legal_Advisor__c advisor) {
        return newAdvisor.AccountStatus == Constants.LEGAL_ADVISORS.STATUS_ENABLED ||
            advisor.Status__c == Constants.LEGAL_ADVISORS.STATUS_ENABLED;
    }

    private static Map<String, ucl_LegalAccount> getNewAdvisorsByNumber(List<ucl_LegalAccount> newAdvisors) {
        Map<String, ucl_LegalAccount> advisorsByNumber = new Map<String, ucl_LegalAccount>();

        for (ucl_LegalAccount account : newAdvisors) {
            advisorsByNumber.put(account.AccountNumber, account);
        }

        return advisorsByNumber;
    }

    private static Map<String, Legal_Advisor__c> getCurrentAdvisorsByNumber(List<Legal_Advisor__c> currentAdvisors) {
        Map<String, Legal_Advisor__c> currentAdvisorsByNumber = new Map<String, Legal_Advisor__c>();

        for (Legal_Advisor__c advisor : currentAdvisors) {
            currentAdvisorsByNumber.put(advisor.Number__c, advisor);
        }

        return currentAdvisorsByNumber;
    }

    private static List<Legal_Advisor__c> getAllLegalAdvisors() {
        return [SELECT Id, Number__c, Status__c FROM Legal_Advisor__c];
    }

    private static List<Client__c> getAllClients() {
        return [SELECT Id, Number__c, Client_Unique_Id__c, Added_Manually__c FROM Client__c];
    }
}
