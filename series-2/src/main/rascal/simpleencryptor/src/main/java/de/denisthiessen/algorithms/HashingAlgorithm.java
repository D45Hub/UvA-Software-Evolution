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
    
        return String.valueOf(hashCode);
    }
	
	private void testMethod(String test1, String test2, String test3, String test4, String test5, String test6, String test7) {
		System.out.println("Hello World");
	}
}
