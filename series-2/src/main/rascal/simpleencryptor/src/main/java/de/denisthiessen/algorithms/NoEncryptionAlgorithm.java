package de.denisthiessen.algorithms;

public class NoEncryptionAlgorithm implements IAlgorithm {

    public NoEncryptionAlgorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {
        return sourceString;
    }
}
