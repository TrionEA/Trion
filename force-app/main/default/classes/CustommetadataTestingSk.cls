public class CustommetadataTestingSk {
    public static void meth1() {
    Integer daysFromLabel = Integer.valueOf(System.label.Days);
    System.debug('DaysFromLabel: ' + daysFromLabel);
    
    // Ensure that the query doesn't return more than 50,000 records
    Integer maxQueryDays = Math.min(daysFromLabel, 30); // Assuming a maximum of 30 days to prevent excessive querying
    
    String dynamicQuery = 'SELECT Id FROM EmailMessage WHERE CreatedDate = LAST_N_DAYS:' + maxQueryDays;
    List<EmailMessage> lisMetadata = Database.query(dynamicQuery);
    
    System.debug('No of records are' + lisMetadata.size());
}

 }