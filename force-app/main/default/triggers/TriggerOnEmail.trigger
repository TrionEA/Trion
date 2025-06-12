trigger TriggerOnEmail on EmailMessage (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        TriggerOnEmailhandler tr=new TriggerOnEmailhandler(Trigger.new);
    }
    

}