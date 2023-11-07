module UnitSize::UnitSize 

import Ranking::Ranking;
import GeneralHelper::ProjectHelper;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;
import String;

alias Size = num;
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



num sumOfList(list[num] listOfNumbers, int sizeOfList) {
    if (sizeOfList == 0) {
        return 0;
    }
        return listOfNumbers[sizeOfList - 1]
        + sumOfList(listOfNumbers, sizeOfList - 1);
}
   
 
num calculateAverageUnitSize (list[UnitLengthTuple] allMethodsOfProject) {
    list[num] allSizes =  [method[1] | method <- allMethodsOfProject];
    num average = sumOfList(allSizes, size(allSizes)) / size(allMethodsOfProject);
    return average;
}

list[UnitLengthTuple] getAllUnitSizesOfProject(M3 projectModel) {

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

UnitSizeRanking getResultingUnitSizeRanking(list[UnitLengthTuple] allMethodsOfProject) {
    // TODO: Finish
    return excellentUnitSizeRanking;
}