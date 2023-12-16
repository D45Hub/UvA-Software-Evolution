package de.denisthiessen.algorithms;

public class HashingAlgorithm implements IAlgorithm {

    public HashingAlgorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {
        int hashCode = 7;
        char[] inputCharacters = sourceString.toCharArray();
    
        for(char character : inputCharacters) {
            hashCode = hashCode*31 + ((int)character);
        }

        // Type 2 example clone (2)
        int i = 5;
        i += 5;
        i += 3;
        i -= 4;
        i = 3;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        System.out.println(i);
    
        return String.valueOf(hashCode);
    }

    private void type3TestFunction() {
        // Type 3 example clone (3)
        int y = 12;
        y += 6;
        y += 3;
        y -= 2;
        y += 8;
        y = 1;
        y += 4;
        y += 2;
        y += 93;
        System.out.println(y);
    }
}
