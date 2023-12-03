package de.denisthiessen.algorithms;

public class HashingAlgorithm implements IAlgorithm {

    public HashingAlgorithm() {

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
	
	private void testMethod(String test1, String test2, String test3, String test4, String test5, String test6, String test7) {
		System.out.println("Hello World");
	}

    public void printHey() {
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
        System.out.println("1");
    }
}
