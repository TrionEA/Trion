public class SchedulableMathOperations implements Schedulable {
    // The execute method is called when the job is triggered
    public void execute(SchedulableContext sc) {
        // Perform the mathematical operation
        MathOperations operations = new MathOperations();
        operations.calculateSum();
        
        // Schedule the job to run again in 5 minutes
        scheduleNextRun();
    }
    
    // Helper method to calculate the next 5-minute interval and schedule the job
    private void scheduleNextRun() {
        /*Datetime now = Datetime.now();
        Integer nextMinute = (Math.floor(now.minute() / 5) * 5 + 5) % 60;
        Integer nextHour = now.hour();
        if (nextMinute == 0) {
            nextHour = (now.hour() + 1) % 24;
        }
        Datetime nextRun = Datetime.newInstance(now.year(), now.month(), now.day(), nextHour, nextMinute, 0);*/
        String cronExpression = '* /5 * * * *';
        System.schedule('Math Operations Job ' , cronExpression, new SchedulableMathOperations());
    }
}