public with sharing class ucl_AWSHandler {

    @future
    public static void handleRetrieveData() {
        try {
            HttpResponse response = ucl_AWSHelper.makeRequest(Constants.AWS.UCL_BUCKET_ENDPOINT);
            ucl_DataHandler.handleData(getLegalAccountsResponse(response));
        } catch (Exception ex) {
            new LogException().log(ex);
        }
    }

    private static ucl_LegalAccountsResponse getLegalAccountsResponse(HttpResponse response) {
        List<Object> outterList = (List<Object>) JSON.deserializeUntyped(response.getBody());

        Map<String, Object> mappedAccounts = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serialize(outterList.get(0))
        );

        ucl_LegalAccountsResponse deserializeResults = (ucl_LegalAccountsResponse) JSON.deserialize(
            JSON.serialize(mappedAccounts),
            ucl_LegalAccountsResponse.class
        );

        return deserializeResults;
    }
}
