package de.denisthiessen.algorithms;

public class Rot13Algorithm implements IAlgorithm {

    public Rot13Algorithm() {

    }

    @Override
    public String executeAlgorithm(String sourceString) {
        StringBuilder sb = new StringBuilder();

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
        
        return sb.toString();
    }
}
