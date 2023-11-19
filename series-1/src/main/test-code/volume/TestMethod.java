
public class TestMethod {
    /* 
    We should get some lines of code and don't count the declaration and 
    comments.
    */ 
    public void method1(int one, int two, int three, int four,
									int five, int six) {
		System.out.println("1");
        System.out.println("2");
        System.out.println("3");
        System.out.println("4");
        System.out.println("5");
        System.out.println("6");
        System.out.println("/* You should still count me */ ")
	}

    public void method2(int one, int two, int three, int four,
									int five) {
		System.out.println("1");
        System.out.println("2");
        System.out.println("3");
        System.out.println("4");
        System.out.println("5");
        System.out.println("6");
        System.out.println("// And me as well. ")

	}

}

