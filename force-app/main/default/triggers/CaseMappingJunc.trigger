trigger CaseMappingJunc on Case (After insert) {
    if(Trigger.isAfter && Trigger.isInsert ){
        List<Id>li=new List<Id>();
        for( Case c:Trigger.New){
            li.add(c.id);
        }
    }
    

}