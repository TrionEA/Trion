public class CaseBusinessHoursHandler {

    public static void handleBeforeInsert(List<Case> newCases) {
        for (Case c : newCases) {
            c.Last_Status_Change__c = System.now();
            c.Time_With_Customer__c = 0;
            c.Time_With_Support__c = 0;
            c.New_Case__c = true;
        }
    }

    public static void handleBeforeUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        Set<String> stopStatusSet = new Set<String>();
        for (Stop_Status__c stopStatus : [SELECT Name FROM Stop_Status__c]) {
            stopStatusSet.add(stopStatus.Name);
        }

        BusinessHours defaultHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];

        Set<String> closedStatusSet = new Set<String>();
        for (CaseStatus status : [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = true]) {
            closedStatusSet.add(status.MasterLabel);
        }

        for (Case updatedCase : newCases) {
            Case oldCase = oldMap.get(updatedCase.Id);

            if (oldCase.Status != updatedCase.Status && updatedCase.Last_Status_Change__c != null) {
                if (!oldCase.IsClosed) {
                    Id hoursToUse = updatedCase.BusinessHoursId != null
                        ? updatedCase.BusinessHoursId
                        : defaultHours.Id;

                    Double timeSinceLastStatus = BusinessHours.diff(
                        hoursToUse,
                        updatedCase.Last_Status_Change__c,
                        System.now()
                    ) / 3600000.0;

                    if (stopStatusSet.contains(oldCase.Status)) {
                        updatedCase.Time_With_Customer__c += timeSinceLastStatus;
                    } else {
                        updatedCase.Time_With_Support__c += timeSinceLastStatus;
                    }

                    if (closedStatusSet.contains(updatedCase.Status)) {
                        updatedCase.Case_Age_In_Business_Hours__c =
                            updatedCase.Time_With_Customer__c + updatedCase.Time_With_Support__c;
                    }
                }

                updatedCase.Last_Status_Change__c = System.now();
            }
        }
    }
}