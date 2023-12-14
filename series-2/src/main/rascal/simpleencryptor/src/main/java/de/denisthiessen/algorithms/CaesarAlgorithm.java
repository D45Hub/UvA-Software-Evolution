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

    public void printHey() {
        test.track("ye");

        int i = 15;
        i += 3;
        i += 5;
        i += 2;
        i += 2;
        i += 2;
        i += 2;
        i += 2;
        i += 2;
    }

    private void test() {
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
    } 
}
