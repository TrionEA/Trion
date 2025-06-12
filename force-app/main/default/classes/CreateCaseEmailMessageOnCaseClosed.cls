public class CreateCaseEmailMessageOnCaseClosed {
    
    @invocableMethod(label='Create ContentDocument Link For EmailMessage')
    public static List<returnVariable> CreateNewCaseandEmailMessage(List<InputVariables> InputVariables){
        Id OldMessageId = InputVariables[0].OldEmailMsgId;
        Id NewMessageId = InputVariables[0].NewEmailMsgId;
        //
        //for(Id EmailMsgId: EmailMsgIds){
            List<ContentDocumentLink> conLinList =[Select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility from ContentDocumentLink where LinkedEntityId =:OldMessageId];
            List<ContentDocumentLink> conLinListNew= new List<ContentDocumentLink>();
        	
            for(ContentDocumentLink con: conLinList){
                ContentDocumentLink cntDocLink = new ContentDocumentLink();
                cntDocLink.LinkedEntityId = NewMessageId;
                //cntDocLink.IsDeleted=false;
                cntDocLink.ShareType='V';
                cntDocLink.Visibility='AllUsers';
                cntDocLink.ContentDocumentId=con.ContentDocumentId;  
                conLinListNew.add(cntDocLink);
            }
    
            insert conLinListNew;
        System.debug('ContentDocLink'+conLinListNew);
        
        List<id> conIdsList = new List<Id>();
        for(ContentDocumentLink con: conLinListNew){
            conIdsList.add(con.Id);
        }
        
        
        	List<returnVariable> rtrnVariable= new List<returnVariable>();
        	returnVariable rtrnVar = new returnVariable();
        	rtrnVar.linkedEntyId = InputVariables[0].NewEmailMsgId;
        	rtrnVariable.add(rtrnVar);
        
        	return rtrnVariable;
        
        }
        
 
    public class InputVariables{
        @invocableVariable
        public Id OldEmailMsgId;
        
        @invocableVariable
        public Id NewEmailMsgId;
    }
    
    public class returnVariable{
        @invocableVariable
        public Id linkedEntyId;
    }
    
    public static void createNewCase(Id oldMsgId, Id newMsgId){
        List<ContentDocumentLink> conLinList =[Select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility from ContentDocumentLink where LinkedEntityId =:oldMsgId];
            List<ContentDocumentLink> conLinListNew= new List<ContentDocumentLink>();
        	
            for(ContentDocumentLink con: conLinList){
                ContentDocumentLink cntDocLink = new ContentDocumentLink();
                cntDocLink.LinkedEntityId = newMsgId;
                //cntDocLink.IsDeleted=false;
                cntDocLink.ShareType='V';
                cntDocLink.Visibility='AllUsers';
                cntDocLink.ContentDocumentId=con.ContentDocumentId;  
                conLinListNew.add(cntDocLink);
            }
    
            insert conLinListNew;
    }
    

}