public class PermissionSetUserReport {

    public class PermissionSetInfo {
        public String permissionSetName;
        public Integer userCount;
        public List<String> userNames;

        public PermissionSetInfo(String name) {
            this.permissionSetName = name;
            this.userCount = 0;
            this.userNames = new List<String>();
        }
    }

    public static void generateReport() {
        // Step 1: Get all permission sets
        Map<String, PermissionSetInfo> psInfoMap = new Map<String, PermissionSetInfo>();

        List<PermissionSet> allPermissionSets = [
            SELECT Name FROM PermissionSet
        ];

        for (PermissionSet ps : allPermissionSets) {
            psInfoMap.put(ps.Name, new PermissionSetInfo(ps.Name));
        }

        // Step 2: Get all permission set assignments
        List<PermissionSetAssignment> assignments = [
            SELECT PermissionSet.Name, Assignee.Name 
            FROM PermissionSetAssignment
            WHERE Assignee.IsActive = TRUE
        ];

        for (PermissionSetAssignment psa : assignments) {
            String psName = psa.PermissionSet.Name;
            if (psInfoMap.containsKey(psName)) {
                PermissionSetInfo info = psInfoMap.get(psName);
                info.userCount++;
                info.userNames.add(psa.Assignee.Name);
            }
        }

        // Step 3: Output results
        for (PermissionSetInfo info : psInfoMap.values()) {
            System.debug('==============================');
            System.debug('Permission Set: ' + info.permissionSetName);
            System.debug('Assigned Users Count: ' + info.userCount);
            if (info.userCount > 0) {
                System.debug('User Names: ' + String.join(info.userNames, ', '));
            } else {
                System.debug('User Names: None');
            }
        }
    }
}