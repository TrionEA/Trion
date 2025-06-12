public class CsvProcessor {

    private static final String SHAREPOINT_CSV_URL = 'https://enabledanalytics.sharepoint.com/:f:/s/SFDCFILES/Ep09QzS-qoVNqxSz8fcQ5vMBE-wh5Gc_nqouBskecuvkPA?e=AfXcyB';

    public static void processCsvData() {
        String csvData = fetchCsvData(SHAREPOINT_CSV_URL);

        if (csvData != null) {
            List<Map<String, String>> parsedData = parseCsvData(csvData);

            // Process the parsed data as needed
            // Example: Insert/update records in Salesforce
            // TODO: Implement your logic here
            System.debug('Parsed CSV Data: ' + parsedData);
        } else {
            // Handle error
            System.debug('Failed to fetch CSV data from SharePoint.');
        }
    }

    private static String fetchCsvData(String csvFileUrl) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(csvFileUrl);
        request.setMethod('GET'); // Use GET method

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            // Handle error
            System.debug('Failed to fetch CSV data. HTTP Status: ' + response.getStatusCode());
            return null;
        }
    }

    private static List<Map<String, String>> parseCsvData(String csvData) {
        List<Map<String, String>> parsedData = new List<Map<String, String>>();

        // Split CSV data by line
        List<String> csvLines = csvData.split('\n');

        // Extract headers
        List<String> headers = csvLines[0].split(',');

        // Iterate through each data line
        for (Integer i = 1; i < csvLines.size(); i++) {
            List<String> values = csvLines[i].split(',');

            Map<String, String> rowData = new Map<String, String>();
            // Map headers to values
            for (Integer j = 0; j < headers.size(); j++) {
                rowData.put(headers[j], values[j]);
            }
            parsedData.add(rowData);
        }

        return parsedData;
    }
}