package de.denisthiessen;

import java.util.Scanner;

import de.denisthiessen.algorithms.IAlgorithm;

public class App 
{
    public static void main( String[] args )
    {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter your encryption algorithm: ");
        String algorithm = scanner.nextLine();

        System.out.print("Enter your source text: ");
        String sourceText = scanner.nextLine();

        scanner.close();

        IAlgorithm encryptionAlgorithm = AlgorithmFactory.getEncryptionAlgorithm(algorithm);
        String encryptedText = encryptionAlgorithm.executeAlgorithm(sourceText);

        System.out.println(encryptedText);
    }
}
