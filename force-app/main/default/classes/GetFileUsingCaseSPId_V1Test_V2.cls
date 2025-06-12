@isTest
public class GetFileUsingCaseSPId_V1Test_V2 {
    @isTest
    static void testTriggerExecution() {
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        
        List<GetDataFromSharepoint__e> events = new List<GetDataFromSharepoint__e>();
        events.add(new GetDataFromSharepoint__e(Emailid__c = '02s567897657843', ParentCaseId__c = testCase.Id));
        events.add(new GetDataFromSharepoint__e(Emailid__c = '02s23456789ijhf', ParentCaseId__c = testCase.Id));
        
        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();
        
        
        GetFileUsingCaseSPId_V1.getCaseFolderData(testCase.id);
    }
    
    
}