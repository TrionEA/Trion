public class MetadataFolderCache {
    private static MetadataFolderCache instance;
    public String metadataFolderName;

    private MetadataFolderCache() {}

    public static MetadataFolderCache getInstance() {
        if (instance == null) {
            instance = new MetadataFolderCache();
        }
        return instance;
    }
}