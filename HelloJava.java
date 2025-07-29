public class HelloJava {
    public static void main(String[] args) {
        System.out.println("Hello from nvim-java!");
        System.out.println("IntelliJ-like Java development in Neovim");
        
        // Test some Java features
        String message = "Testing nvim-java setup";
        printMessage(message);
        
        // Test arithmetic operations
        int result1 = add(5, 3);
        int result2 = subtract(10, 4);
        System.out.println("5 + 3 = " + result1);
        System.out.println("10 - 4 = " + result2);
    }
    
    private static void printMessage(String msg) {
        System.out.println("Message: " + msg);
    }
    
    // Test method for unit testing
    public static int add(int a, int b) {
        return a + b;
    }

    // Test method for unit testing
    public static int subtract(int a, int b) {
        return a - b;
    }
}
