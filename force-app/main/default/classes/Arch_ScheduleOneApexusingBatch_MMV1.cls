global class Arch_ScheduleOneApexusingBatch_MMV1 implements Schedulable{
    
    String status;
    global Arch_ScheduleOneApexusingBatch_MMV1(String status){
        this.status = status;
    }
    
    global void execute(SchedulableContext ctx) {
        
        System.abortJob(ctx.getTriggerId());
        
        Datetime now = Datetime.now();
        Datetime nextRun = now.addMinutes(3);
        Datetime nextRunHour = now.addDays(1);
        String cronExp = nextRun.second() + ' ' + nextRun.minute() + ' ' + '3' + ' ' + nextRun.day() + ' ' + nextRun.month() + ' ? ' + nextRun.year();
        System.schedule('CronEXp-' + nextRun.getTime(), cronExp, new Arch_ScheduleOneApexusingBatch_MMV1(status));
        // Database.executeBatch(new Arch_SharePointEmailBatchCSV(status), 500);
        //cheduleNext();
        
        /*  DateTime stopTime = DateTime.now().addMinutes(3);
if (DateTime.now() < stopTime) {
// Stop scheduling
System.abortJob(ctx.getTriggerId());
}*/
    }
    global static void scheduleNext() {
        /*Datetime now = Datetime.now();
Datetime nextRun = now.addMinutes(3);
String cronExp = nextRun.second() + ' ' + nextRun.minute() + ' ' + nextRun.hour() + ' ' + nextRun.day() + ' ' + nextRun.month() + ' ? ' + nextRun.year();
System.schedule('CronEXp-' + nextRun.getTime(), cronExp, new Arch_ScheduleOneApexusingBatch_MMV1(status));
*/
    }
    global static void startSchedule() {
        scheduleNext();
    }
}