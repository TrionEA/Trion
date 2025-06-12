@isTest
public class Arch_PurgeEmailTest {

    @isTest
    static void cleanerTest(){
        
        Database.executeBatch(new Arch_PurgeEmail(), 2000);
    }
}