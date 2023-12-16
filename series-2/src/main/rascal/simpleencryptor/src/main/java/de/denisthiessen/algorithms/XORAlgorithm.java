package de.denisthiessen.algorithms;

public class XORAlgorithm implements IAlgorithm {

    public XORAlgorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {

        String key = "secretkey";
        StringBuilder encryptedText = new StringBuilder();
        for (int i = 0; i < sourceString.length(); i++) {
            char plainChar = sourceString.charAt(i);
            char keyChar = key.charAt(i % key.length());

            // XOR the plaintext character with the corresponding key character
            char encryptedChar = (char) (plainChar ^ keyChar);
            encryptedText.append(encryptedChar);
        }

        // Type 3 example clone (3)
        int i = 5;
        i += 5;
        i += 3;
        i -= 4;
        i = 3;
        testFunction();
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        System.out.println(i);

        return encryptedText.toString();
    }

    private void testFunction() {
        System.out.println("Hello World");
    }

    // Type 1 Example Clone. (1)
    public void printHey() {
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
        System.out.println("Hey!");
    }
}
