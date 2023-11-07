module UnitSize::UnitSize 

import Ranking::Ranking;
import GeneralHelper::ProjectHelper;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;
import String;

alias Size = int;
alias UnitSizeRanking =  tuple[Ranking rankingType,
                                Size minLineOfunit,
                                Size maxLinesOfUnit];
alias UnitLengthTuple = tuple[loc method, int methodLOC];


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



int sumOfList(list[int] listOfintbers, int sizeOfList) {
    if (sizeOfList == 0) {
        return 0;
    }
        return listOfintbers[sizeOfList - 1]
        + sumOfList(listOfintbers, sizeOfList - 1);
}
   
 
int calculateAverageUnitSize (list[UnitLengthTuple] allMethodsOfProject) {
    list[int] allSizes =  [method[1] | method <- allMethodsOfProject];
    int average = sumOfList(allSizes, size(allSizes)) / size(allMethodsOfProject);
    return average;
}

list[UnitLengthTuple] getAllUnitSizesOfProject(M3 projectModel) {

    // TODO REFACTOR :D 
    list[UnitLengthTuple] unitLengthTuples = [];

    classMethods = methods(projectModel);
    classConstructors = constructors(projectModel);

    for(method <- classMethods) {
        str rawMethod = readFile(method);
        list[str] splitCodeLines = (split("\n", rawMethod))[1..];

        unitLengthTuples += [<method, size(splitCodeLines)>];
    }

    for(constructor <- classConstructors) {
        str rawConstructor = readFile(constructor);
        list[str] splitConstructorLines = (split("\n", rawConstructor))[1..];

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

public void formatUnitSizeRanking(M3 projectModel) {
    allMethods = getAllUnitSizesOfProject(projectModel);
    average = calculateAverageUnitSize(allMethods);
    ranking = getUnitSizeRanking(average); 
    println(ranking);
}