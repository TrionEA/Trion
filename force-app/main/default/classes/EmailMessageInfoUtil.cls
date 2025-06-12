public class EmailMessageInfoUtil {
    public List<Map<String, String>> csvInfoList = new List<Map<String, String>>();

    public void addToCsvInfoList(List<Map<String, String>> csvInfo) {
        this.csvInfoList.addAll(csvInfo);
    }
}