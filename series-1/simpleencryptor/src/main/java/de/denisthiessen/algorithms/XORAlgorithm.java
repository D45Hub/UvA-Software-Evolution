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
        return encryptedText.toString();
    }
}
