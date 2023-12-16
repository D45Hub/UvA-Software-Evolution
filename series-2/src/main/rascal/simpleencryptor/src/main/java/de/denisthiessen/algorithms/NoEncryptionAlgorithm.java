package de.denisthiessen.algorithms;

public class NoEncryptionAlgorithm implements IAlgorithm {

    public NoEncryptionAlgorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {
        return sourceString;
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
