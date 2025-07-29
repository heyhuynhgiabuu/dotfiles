public class HelloJava {
    public static void main(String[] args) {
        System.out.println("Hello from nvim-java!");
        System.out.println("IntelliJ-like Java development in Neovim");
        
        // Test some Java features
        String message = "Testing nvim-java setup";
        printMessage(message);
    }
    
    private static void printMessage(String msg) {
        System.out.println("Message: " + msg);
    }
    
    // Test method for unit testing
    public static int add(int a, int b) {
        return a + b;
    }
}