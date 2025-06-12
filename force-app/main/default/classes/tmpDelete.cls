public class tmpDelete implements Queueable {
 
    public void execute(QueueableContext context) {

        System.debug('Queueable called');

        syncmethod('input Sample ##' );

    }

    public static void syncmethod(String inputString) {

        System.debug('Sync method was called with input -> ' + inputString);

    }

}