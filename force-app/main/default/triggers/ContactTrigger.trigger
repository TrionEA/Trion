trigger ContactTrigger on Contact (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            
        }
         if(trigger.isUpdate){
            
        }
         if(trigger.isDelete){
            
        }
    }
    if(Trigger.isAfter){
         if(trigger.isInsert){
            
        }
         if(trigger.isUpdate){
            
        }
         if(trigger.isDelete){
            
        }
       if(trigger.isUnDelete){
           
       }
    }
}