package de.denisthiessen;

import de.denisthiessen.algorithms.CaesarAlgorithm;
import de.denisthiessen.algorithms.HashingAlgorithm;
import de.denisthiessen.algorithms.IAlgorithm;
import de.denisthiessen.algorithms.NoEncryptionAlgorithm;
import de.denisthiessen.algorithms.Rot13Algorithm;
import de.denisthiessen.algorithms.XORAlgorithm;

public class AlgorithmFactory {
    
    public static IAlgorithm getEncryptionAlgorithm(String algorithm) {
     
            switch(algorithm) {
                case "rot13": return new Rot13Algorithm();
                case "hash": return new HashingAlgorithm();
                case "xor": return new XORAlgorithm();
                case "caesar": return new CaesarAlgorithm();
                default : return new NoEncryptionAlgorithm();
            }
    }
}
