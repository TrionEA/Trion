public class MathOperations {
    public void calculateSum() {
        Integer n = 10;  // Example number
        Integer sum = 0;
        
        for (Integer i = 1; i <= n; i++) {
            sum += i;
        }
        
        System.debug('The sum of the first ' + n + ' natural numbers is: ' + sum);
    }
}