public with sharing class ucl_AWSHelper {
    public static HttpResponse makeRequest(String endpoint) {
        return makeRequest(endpoint, 'GET');
    }

    public static HttpResponse makeRequest(String endpoint, String method) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);

        Http http = new Http();
        HTTPResponse response = http.send(request);

        return response;
    }
}
