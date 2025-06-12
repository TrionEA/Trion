public class SampleSplitClassDK_V1 {

    Public static void splitData(){
        String data;
        //data = 'Deepak';
        data = 'Quotes is used to escape the delimiter comma used to represent multiple values.';
        System.debug('data => '+data);
        String[] splittedData = data.split(' ', 3);
        System.debug('splittedData => '+splittedData);
        system.debug('Serialized String is '+system.json.serializePretty(splittedData));
        //System.debug('splittedData => '+Arrays.toString(splittedData));
        
    }
}