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

alias Size = int;
alias UnitSizeRanking =  tuple[Ranking rankingType,
                                Size minLineOfunit,
                                Size maxLinesOfUnit];

alias UnitLengthTuple = tuple[loc method, int methodLOC];

alias UnitSizeValue = tuple[UnitSizeRanking unitSizeRanking, int averageUnitSizeLOC];

alias UnitRiskCategory = tuple[int min, int max];

/* How many lines are in which category*/ 
alias UnitSizeRiskRanking = tuple[Ranking rankingType,
                                UnitSizeDistribution unitSizeDistribution];

alias UnitSizeDistribution =  tuple[num moderateRisk,
                                num highRisk,
                                num veryHighRisk];

UnitRiskCategory unitRiskLow = <1,15>;
UnitRiskCategory unitRiskModerate = <16,30>;
UnitRiskCategory unitRiskHigh = <30,60>;
UnitRiskCategory unitRiskVeryHigh = <61,-1>;

UnitSizeRanking excellentUnitSizeRanking = <excellent, 1, 15>;
UnitSizeRanking goodUnitSizeRanking = <good, 16, 40>;
UnitSizeRanking neutralUnitSizeRanking = <neutral, 21, 30>;
UnitSizeRanking negativeUnitSizeRanking = <negative, 30, 50>;
UnitSizeRanking veryNegativeUnitSizeRanking = <veryNegative, 50, -1>;

alias UnitAmountPercentage = tuple[num absoluteAmount, num relativeAmount];

list[UnitSizeRanking] allUnitSizeRankings = [excellentUnitSizeRanking,
                                            goodUnitSizeRanking,
                                            neutralUnitSizeRanking,
                                            negativeUnitSizeRanking,
                                            veryNegativeUnitSizeRanking];

int calculateAverageUnitSize (list[UnitLengthTuple] allMethodsOfProject) {
    list[int] allSizes =  [method[1] | method <- allMethodsOfProject];
    int average = sum(allSizes) / size(allMethodsOfProject);
    return average;
}

int calculateAverageUnitSizeFromProject(M3 projectModel) {
    allMethods = getAllUnitSizesOfProject(projectModel);
    return calculateAverageUnitSize(allMethods);
}

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

public UnitSizeRanking getUnitSizeRanking(int averageUnitSizeLOC){
    UnitSizeRanking resultRanking =  [ranking | ranking <- allUnitSizeRankings,
                                (averageUnitSizeLOC < ranking.maxLinesOfUnit
                                || ranking.maxLinesOfUnit == -1)][0];
    return resultRanking;
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

UnitSizeRanking calculateUnitSizeRanking(M3 projectModel) {
    int average = calculateAverageUnitSizeFromProject(projectModel);
    return getUnitSizeRanking(average); 
}

public UnitSizeValue calculateUnitSizeRankingValues(M3 projectModel) {
    int average = calculateAverageUnitSizeFromProject(projectModel);
    return <getUnitSizeRanking(average), average>; 
}

public void formatUnitSizeRanking(M3 projectModel) {
    UnitSizeValue rankingValue = calculateUnitSizeRankingValues(projectModel);
    println(rankingValue);
}

public map[str, UnitAmountPercentage] calculateUnitSizeRankingValues(M3 projectModel, int linesOfCode) {
    list[UnitLengthTuple] unitSizes = getAllUnitSizesOfProject(projectModel);
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