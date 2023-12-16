package de.denisthiessen.algorithms;

public class CaesarAlgorithm implements IAlgorithm {

    public CaesarAlgorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {

        // Type 2 example clone (4)
        testNothing("Test", 1);
        testNothing("Hello", 5);
        testNothing("Please. Send. Help", 69);
        testNothing("I'm stuck in this array of characters", 420);

        int shift = 42;
        StringBuilder encryptedText = new StringBuilder();
        for (char c : sourceString.toCharArray()) {
            if (Character.isLetter(c)) {
                char base = Character.isLowerCase(c) ? 'a' : 'A';
                encryptedText.append((char) (((c - base + shift) % 26) + base));
            } else {
                encryptedText.append(c);
            }
        }
        return encryptedText.toString();
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

    private void testNothing(String testStringParameter, int testIntParameter) {
        // I didn't overpromise...
    }
}
