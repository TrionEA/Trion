public class Dummy {
    public static void createEmail(){
        EmailMessage emVar= New EmailMessage();
        emVar.FromAddress = 'max@gmail.com';
        emVar.ToAddress ='max@gmail.com';
        emVar.Subject='suject';
        emVar.ParentId	= '500VE000005ZKVdYAO';
        insert emVar;
        updateEmail(emVar.id);
        
    }
    public static void updateEmail( id emailId){
        EmailMessage emVar= [select id, ParentId from EmailMessage where id =:emailId];
        emVar.ParentId ='500VE000005bHBuYAM';
        update emVar;
        
    }
    
}