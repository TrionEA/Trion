public class Arch_SchdulingRetryCSVAndFA implements Schedulable {
     String status;
    public Arch_SchdulingRetryCSVAndFA(String status){
        this.status = status;
    }
    public void execute(SchedulableContext sc){
        List<EmailMessageHtml__c>lisEmails=[Select id from EmailMessageHtml__c where status__c=:status];
        List<Stagging__c>stList=[select id from Stagging__c where status__c=:status];
        if(!lisEmails.isEmpty()){
            if(lisEmails.size()<=500){
           System.schedule('Schedule CSV Upload- 1#' , ' 0 55 4 * * ? ', new  Arch_SchedulableSharePointCSV('Retry Required'));
            }
            if(lisEmails.size()>500 && lisEmails.size()<=1000){
                System.schedule('Schedule CSV Upload- 2#' , ' 0 55 4 * * ? ', new  Arch_SchedulableSharePointCSV('Retry Required'));
                System.schedule('Schedule CSV Upload- 3#' , ' 0 55 4 * * ? ', new  Arch_SchedulableSharePointCSV('Retry Required'));
            }

        }
        if(!stList.isEmpty()){
            if(stList.size()<=500){
            System.schedule('Schedule FA Upload- 1#' , ' 0 24 3 * * ? ', new Arch_RetrySchedulableSharePointFA('Retry Required'));
            }
            if(stList.size()>500 && stList.size()<=1000){
                   System.schedule('Schedule FA Upload- 2#' , ' 0 24 3 * * ? ', new Arch_RetrySchedulableSharePointFA('Retry Required'));
                   System.schedule('Schedule FA Upload- 3#' , ' 0 24 3 * * ? ', new Arch_RetrySchedulableSharePointFA('Retry Required'));
                
            }
        }
        
        System.schedule('Schedule Arch_ScheduleConvertCSVPopulateTable- 1#' , ' 0 24 4 * * ? ', new Arch_ScheduleUploadSecondValidationBatch());

    }

}