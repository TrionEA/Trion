@isTest
public class CaseBusinessHoursHandlerTest {

    @testSetup
    static void setupData() {
        // Insert a custom Stop_Status__c value used in logic
        Stop_Status__c stopStatus = new Stop_Status__c(Name = 'Waiting on Customer');
        insert stopStatus;

        // We cannot insert BusinessHours or CaseStatus. We assume:
        // - A default BusinessHours exists.
        // - At least one closed CaseStatus (like 'Closed') exists.
    }

    @isTest
    static void testBeforeInsert() {
        Case testCase = new Case(
            Subject = 'Test Insert Case',
            Status = 'New'
        );

        Test.startTest();
        insert testCase;
        Test.stopTest();

        Case inserted = [SELECT Last_Status_Change__c, Time_With_Customer__c, Time_With_Support__c, New_Case__c
                         FROM Case WHERE Id = :testCase.Id];

        System.assertNotEquals(null, inserted.Last_Status_Change__c, 'Last_Status_Change__c should be set');
        System.assertEquals(0, inserted.Time_With_Customer__c, 'Time_With_Customer__c should be 0');
        System.assertEquals(0, inserted.Time_With_Support__c, 'Time_With_Support__c should be 0');
        System.assertEquals(true, inserted.New_Case__c, 'New_Case__c should be true');
    }
@isTest
static void testBeforeUpdateStatusChange() {
    // Insert initial case with known status
    Case testCase = new Case(
        Subject = 'Test Update Case',
        Status = 'New'
    );
    insert testCase;

    // Simulate that status was changed 2 business hours ago
    testCase.Last_Status_Change__c = System.now().addHours(-2);
    update testCase;

    // Update status to a known stop status
    testCase.Status = 'Waiting on Customer';

    Test.startTest();
    update testCase;
    Test.stopTest();

    Case updated = [SELECT Time_With_Customer__c, Time_With_Support__c FROM Case WHERE Id = :testCase.Id];

    System.debug('Customer time: ' + updated.Time_With_Customer__c);
    System.debug('Support time: ' + updated.Time_With_Support__c);

    System.assert(updated.Time_With_Customer__c > 0 || updated.Time_With_Support__c > 0,
        'Expected time to be logged in one of the buckets');
}

}