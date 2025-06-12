global class AsyncHandlerSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        AsyncHandler asyncHandler = new AsyncHandler();
        System.enqueueJob(asyncHandler);
    }
}