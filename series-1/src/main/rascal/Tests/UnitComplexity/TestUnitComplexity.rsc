module Tests::UnitComplexity::TestUnitComplexity


import lang::java::m3::Core;
import CyclomaticComplexity::CyclomaticComplexity;
import lang::java::m3::AST;
import Helper::ProjectHelper;
import IO;


test bool lowComplexityTest(){
	loc file = |project://series-1/src/main/test-code/CyclomaticComplexity/LowCyclomaticComplexity.java|;

	Declaration declaration = createAstFromFile(file, true);
	lowComplexity = getCyclomaticComplexity(declaration);
    println(lowComplexity);
	return lowComplexity == 24;
}

test bool moderateComplexityTest(){
	loc file = |project://series-1/src/main/test-code/CyclomaticComplexity/MediumCyclomaticComplexity.java|;

	Declaration declaration = createAstFromFile(file, true);
	lowComplexity = getCyclomaticComplexity(declaration);
    println(lowComplexity);
	return lowComplexity == 24;
}

test bool highComplexityTest(){
	loc file = |project://series-1/src/main/test-code/CyclomaticComplexity/HighCyclomaticComplexity.java|;

	Declaration declaration = createAstFromFile(file, true);
	lowComplexity = getCyclomaticComplexity(declaration);
    println(lowComplexity);
	return lowComplexity == 24;
}

test bool veryHighComplexityTest(){
	loc file = |project://series-1/src/main/test-code/CyclomaticComplexity/VeryHighCyclomaticComplexity.java|;

	Declaration declaration = createAstFromFile(file, true);
	lowComplexity = getCyclomaticComplexity(declaration);
    println(lowComplexity);
	return lowComplexity == 24;
}
