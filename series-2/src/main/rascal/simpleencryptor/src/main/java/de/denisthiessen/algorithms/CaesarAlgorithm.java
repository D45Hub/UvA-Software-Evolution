package de.denisthiessen.algorithms;

public class CaesarAlgorithm implements IAlgorithm {

    public CaesarAlgorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {
        int shift = 42;

        System.out.println("Hey");
        System.out.println("Hey");
        System.out.println("Hey");
        System.out.println("Hey");
        System.out.println("Hey");
        System.out.println("Hey");
        System.out.println("Hey");
        System.out.println("Hey");
        System.out.println("Hey");

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
    
}
