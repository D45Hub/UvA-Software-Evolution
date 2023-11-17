module Tests::UnitInterfacing::TestUnitInterfacing

import UnitInterfacing::UnitInterfacing;
import lang::java::m3::Core;
import CyclomaticComplexity::CyclomaticComplexity;
import lang::java::m3::AST;
import Helper::ProjectHelper;
import IO;
import List;



test bool isLowInterfacing() {

	loc file = |project://series-1/src/main/test-code/UnitInterfacing/LowInterfacing.java|;
	list[Declaration] declarations = [ createAstFromFile(file, true) ]; 
	list[Declaration] methods = [];

	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	}
    // Unit Interfacing
	// Get all parameters
	allParamtersOfUnits = getUnitInterfacingValues(methods);
	// absolute lines of Code for Each category
	absoluteParameterCategories = getAbsolutRiskValues(allParamtersOfUnits);
	absoluteLinesOfCodePerCategorie = calculateAbsoluteRiskAmount(absoluteParameterCategories);
    println(absoluteLinesOfCodePerCategorie);
	relativeUnitAmounts = calculateRelativeRiskAmount(absoluteLinesOfCodePerCategorie);
	unitInterfaceRanking = getUnitInterfacingRanking(relativeUnitAmounts);

    println(absoluteLinesOfCodePerCategorie);

	return  relativeUnitAmounts["lowRisk"] != 0 &&
            relativeUnitAmounts["moderateRisk"] == 0 &&
            relativeUnitAmounts["highRisk"] == 0 && 
            relativeUnitAmounts["veryHighRisk"] == 0;
}
