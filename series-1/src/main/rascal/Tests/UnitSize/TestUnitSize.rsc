module Tests::UnitSize::TestUnitSize

import Helper::ProjectHelper;

import lang::java::m3::AST;
import lang::java::m3::Core;


import UnitSize::UnitSize;
import UnitSize::UnitSizeRanking;
import Volume::LOCVolumeMetric;
import Volume::LOCVolume;
import Ranking::Ranking;
import Helper::ProjectHelper;

import List;
import String;
import util::Math;
import IO;

map[str, UnitAmountPercentage] getFileRiskValues(loc file) {
    Declaration model = createAstFromFile(file, true);
	
	list[Declaration] methods = [dec | /Declaration dec := model, dec is method || dec is constructor || dec is initializer];
	list[loc] methodLocations = [method.src | Declaration method <- methods];

    list[UnitLengthTuple] unitLengthTuples = [];
    
    for(loc methodLoc <- methodLocations) {
        str rawMethod = readFile(methodLoc);
        list[str] splitCodeLines = getLOC(rawMethod);

        unitLengthTuples += [<methodLoc, size(splitCodeLines)>];
    }

    list[str] codeLines = getLOC(readFile(file));
    return calculateUnitSizeRankingValues(unitLengthTuples, size(codeLines));
}

test bool shouldBeGoodUnitSize() {
    loc file = |project://series-1/src/main/test-code/UnitSize/UnitSizeLow.java|;
    map[str, UnitAmountPercentage] calculatedValues = getFileRiskValues(file);
    map[str, UnitAmountPercentage] referenceValues = ("high":<0,0>,"moderate":<17,77>,"low":<5,23.0>,"veryHigh":<0,0>);

	return calculatedValues == referenceValues;
}

 test bool shouldBeMediumUnitSize() {
 	loc file = |project://series-1/src/main/test-code/UnitSize/UnitSizeMedium.java|;
 	map[str, UnitAmountPercentage] calculatedValues = getFileRiskValues(file);
    map[str, UnitAmountPercentage] referenceValues = ("high":<32,94>,"moderate":<0,0>,"low":<2,6.0>,"veryHigh":<0,0>);

 	return calculatedValues == referenceValues;
}

 test bool shouldBeHighUnitSize() {
 	loc file = |project://series-1/src/main/test-code/UnitSize/UnitSizeHigh.java|;
 	map[str, UnitAmountPercentage] calculatedValues = getFileRiskValues(file);
    map[str, UnitAmountPercentage] referenceValues = ("high":<52,96>,"moderate":<0,0>,"low":<2,4.0>,"veryHigh":<0,0>);

 	return calculatedValues == referenceValues;
}

test bool shouldBeVeryHighSize() {
 	loc file = |project://series-1/src/main/test-code/UnitSize/UnitSizeVeryHigh.java|;
 	map[str, UnitAmountPercentage] calculatedValues = getFileRiskValues(file);
    map[str, UnitAmountPercentage] referenceValues = ("high":<0,0>,"moderate":<0,0>,"low":<2,2.0>,"veryHigh":<102,98>);

 	return calculatedValues == referenceValues;
}