public class BigObjectTest {
    public static void testBigObj(){
        
       List<EmailMessage_Html__b> emailStagingList = [SELECT Title__c, Status__c, sObject__c, Is_Large_File__c, File_Size__c, 
                                                           Error_Message__c, Emailmessage_Id__c,Parent_Case_Id__c,File_Body__c
                                                           FROM EmailMessage_Html__b
                                                           WHERE Status__c = 'Not Started' 
                                                           LIMIT 1];
        
	
        
            
            EmailMessage_Html__b emhb=new EmailMessage_Html__b();
            emhb.Title__c = 'EmailMessage_02sVE000000EuFFYA0.csv';
            emhb.File_Size__c =45678;
            emhb.EmailMessage_Id__c='02sVE000000EuFFYA0';
            emhb.Status__c = 'Completed';
            emhb.sObject__c='EmailMessage';
            //emhb.File_Body__c = csvString;
            emhb.Parent_Case_Id__c='500VE000001oilFYAQ';            
            if(emhb.File_Size__c > 12000000){
                emhb.Is_Large_File__c = 'yes';
                emhb.Status__c = 'Failed';
                emhb.Error_Message__c = 'File size > 12000000';
            }
            else{
                emhb.Is_Large_File__c = 'no';

            }
     
        Database.SaveResult result = Database.insertImmediate(emhb);
        
        if(result.isSuccess()){
             updateSharepointStatus(emailStagingList[0], 'Completed', 'null');
        } else{
                    String errorMessage = 'File upload failed. Status Code:  Response:';
                   updateSharepointStatus(emailStagingList[0], 'Pending', errorMessage);
                }
            
     
    }
        public static void updateSharepointStatus(EmailMessage_Html__b recordToUpdate, String status, String errorMessage) {
               
        EmailMessage_Html__b currentRecord = new EmailMessage_Html__b();
        currentRecord.Status__c = recordToUpdate.Status__c;
        currentRecord.EmailMessage_Id__c=recordToUpdate.EmailMessage_Id__c;
        currentRecord.sObject__c =recordToUpdate.sObject__c;
        currentRecord.File_Size__c = recordToUpdate.File_Size__c;
        currentRecord.Title__c = recordToUpdate.Title__c;
        currentRecord.Parent_Case_Id__c=recordToUpdate.Parent_Case_Id__c;
        currentRecord.Error_Message__c =recordToUpdate.Error_Message__c;
        
        Database.SaveResult result1 = Database.insertImmediate(currentRecord);
        
        if(currentRecord.Job_ID__c != 'Test##SP'){
            if(result1.isSuccess()){
                Database.deleteImmediate(new EmailMessage_Html__b(Status__c = recordToUpdate.Status__c, EmailMessage_Id__c = recordToUpdate.EmailMessage_Id__c, sObject__c=recordToUpdate.sObject__c));
            }
        }
        
    }
}