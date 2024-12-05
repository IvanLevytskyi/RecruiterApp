/**
 * @description HttpCalloutMockClass is class used for testing to create a mock response
 */
global class HttpCalloutMockClass implements HttpCalloutMock {
    global static Map<String, String> headers = new Map<String, String> ();
    global static String body;
    global static Integer statusCode;
    global static String status;

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        for (String header : headers.keySet()) {
            res.setHeader(header, headers.get(header));
        }
        res.setBody(body);
        res.setStatusCode(statusCode);
        res.setStatus(status);
        return res;
    }
}