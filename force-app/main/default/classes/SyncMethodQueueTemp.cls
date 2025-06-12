public class SyncMethodQueueTemp {
    public static void getSharepointId(List<String> emailIdFromSp, String accessToken, String caseParentId, EmailMessageInfoUtil emailMessageInfoUtil){
        
        //FetchEmailMessagesQueueable(emailIdFromSp, accessToken, caseParentId, emailMessageInfoUtil);     
     
        System.debug('sharepointEmailIdList===> ' + emailIdFromSp); 
        System.debug('sharepointEmailIdList===> ' + emailIdFromSp.size()); 
        System.debug('accessToken ===>' + accessToken);  
        System.debug('caseParentId====> ' + caseParentId);         
        System.debug('emailMessageInfoUtil====> ' + emailMessageInfoUtil);  
          
    }
    public class EmailMessageInfoUtil {
        public List<Map<String, String>> csvInfoList = new List<Map<String, String>>();
        public List<Map<String, String>> csvInfoList1 = new List<Map<String, String>>();
    }
}