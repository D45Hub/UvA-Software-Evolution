module UnitSize::UnitSize

import Volume::LOCVolume;

import lang::java::m3::Core;
import lang::java::m3::AST;
import Ranking::Ranking;
import List;
import IO;
import String;

alias Size = int;
alias UnitSizeRanking =  tuple[Ranking rankingType,
                                Size minLineOfunit,
                                Size maxLinesOfUnit];

alias UnitLengthTuple = tuple[loc method, int methodLOC];

alias UnitSizeValue = tuple[UnitSizeRanking unitSizeRanking, int averageUnitSizeLOC];

// TODO find paper or standard on how long a method has to be in Java
UnitSizeRanking excellentUnitSizeRanking = <excellent, 0, 15>;
UnitSizeRanking goodUnitSizeRanking = <good, 16, 20>;
UnitSizeRanking neutralUnitSizeRanking = <neutral, 21, 30>;
UnitSizeRanking negativeUnitSizeRanking = <negative, 30, 50>;
UnitSizeRanking veryNegativeUnitSizeRanking = <veryNegative, 50, -1>;

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