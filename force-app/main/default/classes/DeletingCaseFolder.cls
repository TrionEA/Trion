public class DeletingCaseFolder implements Queueable {
    private List<String> caseIds;

    public DeletingCaseFolder(List<String> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {
        Http httpCallOut = new Http();
        for (String caseId : caseIds) {
            try {
                HttpRequest httpReq = new HttpRequest();
                String driveId = Label.SharepointDriveId;
                String objectNameCase = 'AutomationTest';
                
                httpReq.setMethod('DELETE');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setHeader('Accept', 'application/json');
                httpReq.setEndPoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+objectNameCase +'/'+caseId);
                
                HttpResponse res = httpCallOut.send(httpReq);
                if (res.getStatusCode() == 204) {
                    System.debug('Case folder ' + caseId + ' deleted successfully');
                } else {
                    System.debug('Failed to delete case folder ' + caseId + '. Status Code: ' + res.getStatusCode());
                }
            } catch (Exception e) {
                System.debug('Error deleting case folder for Case ID: ' + caseId + ' - ' + e.getMessage());
            }
        }
    }
}