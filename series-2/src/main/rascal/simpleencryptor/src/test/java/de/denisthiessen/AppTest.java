package de.denisthiessen;

import static org.junit.Assert.assertTrue;

import org.junit.Test;

import de.denisthiessen.algorithms.IAlgorithm;

/**
 * Unit test for simple encryptor.
 */
public class AppTest 
{
    @Test
    public void testCasesarCipher()
    {
        IAlgorithm encryptionAlgorithm = AlgorithmFactory.getEncryptionAlgorithm("caesar");
        String encryptedText = encryptionAlgorithm.executeAlgorithm("Helloworld");
        System.out.println(encryptedText);

        assertTrue(encryptedText.equals("Xubbemehbt"));
    }

    @Test
    public void testXorCipher()
    {
        IAlgorithm encryptionAlgorithm = AlgorithmFactory.getEncryptionAlgorithm("xor");
        String encryptedText = encryptionAlgorithm.executeAlgorithm("test");
        System.out.println(encryptedText);
        String expectedText = new String(new byte[]{7, 0, 16, 6});

        assertTrue(encryptedText.equals(expectedText));
    }

    @Test
    public void testHashingCipher()
    {
        IAlgorithm encryptionAlgorithm = AlgorithmFactory.getEncryptionAlgorithm("hash");
        String encryptedText = encryptionAlgorithm.executeAlgorithm("Helloworld");

        assertTrue(encryptedText.equals("775124327"));
    }

    @Test
    public void testRot13Cipher()
    {
        IAlgorithm encryptionAlgorithm = AlgorithmFactory.getEncryptionAlgorithm("rot13");
        String encryptedText = encryptionAlgorithm.executeAlgorithm("Helloworld");

        assertTrue(encryptedText.equals("Uryybjbeyq"));
    }

    @Test
    public void testNoCipher()
    {
        IAlgorithm encryptionAlgorithm = AlgorithmFactory.getEncryptionAlgorithm("nocipher");
        String encryptedText = encryptionAlgorithm.executeAlgorithm("Helloworld");

        assertTrue(encryptedText.equals("Helloworld"));
    }
}
