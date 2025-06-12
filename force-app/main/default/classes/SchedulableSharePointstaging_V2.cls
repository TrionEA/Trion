global class SchedulableSharePointstaging_V2 implements Schedulable {
    
    global SchedulableSharePointstaging_V2(){
    }
    
    global void execute(SchedulableContext sc){
        database.executeBatch(new SharePointStagingBatchable_V2(), 500);
    }

}