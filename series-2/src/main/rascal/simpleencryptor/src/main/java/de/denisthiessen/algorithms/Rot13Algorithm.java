package de.denisthiessen.algorithms;

public class Rot13Algorithm implements IAlgorithm {

    public Rot13Algorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {
        StringBuilder sb = new StringBuilder();

        // Type 2 example clone (4)
        testNothing("Test", 1);
        testNothing("Hello", 5);
        testNothing("Please. Send. Help", 69);
        testNothing("I'm stuck in this array of characters", 420);

        for (int i = 0; i < sourceString.length(); i++) {
            char c = sourceString.charAt(i);
            if (c >= 'a' && c <= 'm')
                c += 13;
            else if (c >= 'A' && c <= 'M')
                c += 13;
            else if (c >= 'n' && c <= 'z')
                c -= 13;
            else if (c >= 'N' && c <= 'Z')
                c -= 13;
            sb.append(c);
        }

        // Type 2 example clone (2)
        int i = 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        System.out.println(i);
        
        return sb.toString();
    }

    private void testNothing(String testStringParameter, int testIntParameter) {
        // I didn't overpromise...
    }
}
