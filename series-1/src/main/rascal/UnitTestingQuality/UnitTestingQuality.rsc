module UnitTestingQuality::UnitTestingQuality
import lang::java::m3::Core;
import lang::java::m3::AST;
import String;
import List;
// Needed because of the unit testing part of two of the required ratings.
// For that we basically count the number of assert statements per method in a testClass
// We get the test classes from the test folder, since this is I believe a Java 
// convention that the stuff should be in a test folder

alias TestClasses = list[Declaration];
alias TestMethods = list[Declaration];

public list[loc] getTestFilesOfProject(list[loc] files) {

	list[loc] validFiles = [];
	for(int i <- [0 .. size(files)]) {
		loc file = files[i];
		
		if(isValidTestClass(file.path)) {
			validFiles += file;
		}
	}
	
	return validFiles;
}

public bool isValidTestClass(str file) {
	
	if(!contains(file, "/junit/")  ) {
		return false;
    }

	return true;
}



	


// Declarations are the ASTs from each class in the project.
// They are predefined with the file test filter (if it appears int he sourcecode.)
public TestClasses getTestClasses(list[loc] files) {
    list[Declaration] fileDeclarations = [ createAstFromFile(file, true) | file <- files]; 
    TestClasses classItems = [];
	for(int i <- [0 .. size(fileDeclarations)]) {
		classItems = classItems + [dec | /Declaration dec := fileDeclarations[i],
        dec is class && (contains(dec.src.path, "/junit/"))];
	}
    return classItems;
}

public int getAssertionForMethod(Declaration testClass) {

 	int assertions = 0;

	visit (testClass) {
        case \assert(_): assertions += 1;
        case \assert(_, _): assertions += 1;
        case \methodCall(_, /assert/, _): assertions += 1;
        case \methodCall(_, _, /assert/, _): assertions += 1;
    }
    
    return assertions;
}
