module UnitSize::UnitSize

import Volume::LOCVolume;

import lang::java::m3::Core;
import lang::java::m3::AST;
import Ranking::Ranking;
import UnitSize::UnitSizeRanking;
import List;
import IO;
import String;
import util::Math;

alias UnitLengthTuple = tuple[loc method, int methodLOC];
alias UnitRiskCategory = tuple[int min, int max];
alias UnitSizeDistribution =  tuple[num moderateRisk,
                                num highRisk,
                                num veryHighRisk];
alias UnitAmountPercentage = tuple[num absoluteAmount, num relativeAmount];

UnitRiskCategory unitRiskLow = <1,15>;
UnitRiskCategory unitRiskModerate = <16,30>;
UnitRiskCategory unitRiskHigh = <30,60>;
UnitRiskCategory unitRiskVeryHigh = <61,-1>;

list[UnitLengthTuple] getAllUnitSizesOfProject(M3 projectModel) {

    list[UnitLengthTuple] unitLengthTuples = [];

    classMethods = methods(projectModel);
    classConstructors = constructors(projectModel);

    for(method <- classMethods) {
        str rawMethod = readFile(method);
        list[str] splitCodeLines = getLOC(rawMethod);

        unitLengthTuples += [<method, size(splitCodeLines)>];
    }

    for(constructor <- classConstructors) {
        str rawConstructor = readFile(constructor);
        list[str] splitConstructorLines = getLOC(rawConstructor);

        unitLengthTuples += [<constructor, size(splitConstructorLines)>];
    }

    return unitLengthTuples;
}

UnitSizeDistribution getAbsoluteUnitSizeDistribution(list[UnitLengthTuple] allSizes) {
    UnitSizeDistribution distribution = <0,0,0>;

    for (unit <- allSizes) {
        if (unit.methodLOC > unitRiskVeryHigh.min) {
            distribution.veryHighRisk += unit.methodLOC;
        }
        else if (unit.methodLOC >= unitRiskHigh.min && unit.methodLOC <= unitRiskHigh.max) {
            distribution.highRisk += unit.methodLOC;
        } 
        else if (unit.methodLOC >= unitRiskModerate.min && unit.methodLOC <= unitRiskModerate.max) {
            distribution.moderateRisk += unit.methodLOC;
        }
    }

    return distribution;
}

public UnitSizeDistribution getRelativeUnitSizeDistribution(UnitSizeDistribution distribution, int linesOfCode) {
    int percentageVeryHighRisk = round(( toReal(distribution.veryHighRisk) / toReal(linesOfCode) ) * 100);
    int percentageHighRisk = round(toReal(distribution.highRisk) / (toReal(linesOfCode)) * 100);
    int percentageModerateRisk = round(toReal(distribution.moderateRisk) /(toReal(linesOfCode)  ) * 100);

    return <percentageModerateRisk, percentageHighRisk, percentageVeryHighRisk>;
}

public void getUnitSizeDistribution(list[UnitLengthTuple] allSizes, int linesOfCode) {
    UnitSizeDistribution distribution = getAbsoluteUnitSizeDistribution(allSizes);
    UnitSizeDistribution relativeDistribution = getRelativeUnitSizeDistribution(distribution, linesOfCode);
}

public map[str, UnitAmountPercentage] calculateUnitSizeRankingValues(M3 projectModel, int linesOfCode) {
    list[UnitLengthTuple] unitSizes = getAllUnitSizesOfProject(projectModel);
    return calculateUnitSizeRankingValues(unitSizes, linesOfCode);
}

public map[str, UnitAmountPercentage] calculateUnitSizeRankingValues(list[UnitLengthTuple] unitSizes, int linesOfCode) {
    UnitSizeDistribution unitDistributions = getAbsoluteUnitSizeDistribution(unitSizes);
    UnitSizeDistribution relativeDistributions = getRelativeUnitSizeDistribution(unitDistributions, linesOfCode);

    UnitSizeRankingValues unitSizeRanking = getUnitSizeRanking(relativeDistributions);

    num lowRiskLines = linesOfCode - unitDistributions.moderateRisk - unitDistributions.highRisk - unitDistributions.veryHighRisk; 
    num lowRiskLinesPercentage = 100.0 - relativeDistributions.moderateRisk - relativeDistributions.highRisk - relativeDistributions.veryHighRisk; 

    UnitAmountPercentage lowAmountPercentage = <lowRiskLines, lowRiskLinesPercentage>;
    UnitAmountPercentage moderateAmountPercentage = <unitDistributions.moderateRisk, relativeDistributions.moderateRisk>;
    UnitAmountPercentage highAmountPercentage =  <unitDistributions.highRisk, relativeDistributions.highRisk>;
    UnitAmountPercentage veryHighAmountPercentage = <unitDistributions.veryHighRisk, relativeDistributions.veryHighRisk>;

    return (
        "low": lowAmountPercentage,
        "moderate" : moderateAmountPercentage,
        "high" : highAmountPercentage,
        "veryHigh" : veryHighAmountPercentage
    );
}