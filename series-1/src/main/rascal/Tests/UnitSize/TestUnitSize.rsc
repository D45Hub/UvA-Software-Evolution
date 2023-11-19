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

test bool shouldBeExcellentUnitSize() {
	//loc file = |project://series-1/src/main/test-code/UnitSize/UnitSizeVeryHigh.java|;
    loc file = |project://series-1/src/main/test-code/Volume/TestMethod.java|;
    model = createM3FromFile(file);
	list[str] codeLines = getLOC(readFile(file));
    unitSizeRankingValues = calculateUnitSizeRankingValues(model, size(codeLines));
    return false;
	//return unitSizeRankingValues.rankingType == excellentUnitSizeRanking.rankingType;
}

// test bool shouldBeGoodUnitSize() {
// 	loc file = |project://uva-software-evolution/src/resources/series1/test-code/testQuality/QualityVeryHigh.java|;
// 	UnitSizeRankingValues risk = getFileRisk(file);

// 	return risk.rankingType == goodUnitSizeRanking.rankingType;
// }

// test bool shouldBeNeutralUnitSize() {

// 	loc file = |project://uva-software-evolution/src/resources/series1/test-code/testQuality/QualityNormal.java|;
// 	UnitSizeRankingValues risk = getFileRisk(file);

// 	return risk.rankingType == neutralUnitSizeRanking.rankingType;
// }

// test bool shouldBeNegativeUnitSize() {

// 	loc file = |project://uva-software-evolution/src/resources/series1/test-code/testQuality/QualityLow.java|;
// 	UnitSizeRankingValues risk = getFileRisk(file);

// 	return risk.rankingType == negativeUnitSizeRanking.rankingType;
// }
	
// test bool shouldBeVeryNegativeUnitSize() {

// 	loc file = |project://series-1/src/main/test-code/UnitSize/UnitSizeVeryHigh.java|;
// 	UnitSizeRankingValues risk = getFileRisk(file);

// 	return risk.rankingType == veryNegativeUnitSizeRanking.rankingType;
// }