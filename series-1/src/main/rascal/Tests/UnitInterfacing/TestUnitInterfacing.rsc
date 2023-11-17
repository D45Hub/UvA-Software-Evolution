module Tests::UnitInterfacing::TestUnitInterfacing

import UnitInterfacing::UnitInterfacing;
import lang::java::m3::Core;
import CyclomaticComplexity::CyclomaticComplexity;
import lang::java::m3::AST;
import Helper::ProjectHelper;
import IO;
import List;


list [Declaration] getMethodsForUnitInterfacingTest(loc file) {
	list[Declaration] declarations = [ createAstFromFile(file, true) ]; 
	list[Declaration] methods = [];

	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	}

    return  methods;
} 

test bool isLowInterfacing() {
	loc file = |project://series-1/src/main/test-code/UnitInterfacing/LowInterfacing.java|;

    methods = getMethodsForUnitInterfacingTest(file);
	allParamtersOfUnits = getUnitInterfacingValues(methods);
	absoluteParameterCategories = getAbsolutRiskValues(allParamtersOfUnits);
	absoluteLinesOfCodePerCategorie = calculateAbsoluteRiskAmount(absoluteParameterCategories);
	relativeUnitAmounts = calculateRelativeRiskAmount(absoluteLinesOfCodePerCategorie);
	unitInterfaceRanking = getUnitInterfacingRanking(relativeUnitAmounts);

	return  relativeUnitAmounts["lowRisk"] != 0 &&
            relativeUnitAmounts["moderateRisk"] == 0 &&
            relativeUnitAmounts["highRisk"] == 0 && 
            relativeUnitAmounts["veryHighRisk"] == 0;
}

test bool isModerateInterfacing() {
	loc file = |project://series-1/src/main/test-code/UnitInterfacing/MediumInterfacing.java|;
    methods = getMethodsForUnitInterfacingTest(file);
	allParamtersOfUnits = getUnitInterfacingValues(methods);
	absoluteParameterCategories = getAbsolutRiskValues(allParamtersOfUnits);
	absoluteLinesOfCodePerCategorie = calculateAbsoluteRiskAmount(absoluteParameterCategories);
	relativeUnitAmounts = calculateRelativeRiskAmount(absoluteLinesOfCodePerCategorie);
	unitInterfaceRanking = getUnitInterfacingRanking(relativeUnitAmounts);

	return  relativeUnitAmounts["lowRisk"] == 0 &&
            relativeUnitAmounts["moderateRisk"] != 0 &&
            relativeUnitAmounts["highRisk"] == 0 && 
            relativeUnitAmounts["veryHighRisk"] == 0;
}

test bool isHighUnitInterfacing() {
	loc file = |project://series-1/src/main/test-code/UnitInterfacing/HighInterfacing.java|;
    methods = getMethodsForUnitInterfacingTest(file);
	allParamtersOfUnits = getUnitInterfacingValues(methods);
	absoluteParameterCategories = getAbsolutRiskValues(allParamtersOfUnits);
	absoluteLinesOfCodePerCategorie = calculateAbsoluteRiskAmount(absoluteParameterCategories);
	relativeUnitAmounts = calculateRelativeRiskAmount(absoluteLinesOfCodePerCategorie);
	unitInterfaceRanking = getUnitInterfacingRanking(relativeUnitAmounts);

	return  relativeUnitAmounts["lowRisk"] == 0 &&
            relativeUnitAmounts["moderateRisk"] == 0 &&
            relativeUnitAmounts["highRisk"] != 0 && 
            relativeUnitAmounts["veryHighRisk"] == 0;
}