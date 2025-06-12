@isTest
public class Arch_PurgeContentDocumentTest {

    @isTest
    static void cleanerTest(){
        
        Database.executeBatch(new Arch_PurgeContentDocument(), 2000);
    }
}