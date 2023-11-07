module UnitSize::UnitSize 

import Ranking::Ranking;
import GeneralHelper::ProjectHelper;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;

alias Size = num;
alias UnitSizeRanking =  tuple[Ranking rankingType,
                                Size minLineOfunit,
                                Size maxLinesOfUnit];
alias UnitLengthTuple = tuple[Declaration method, num methodLOC];


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

void getAllUnitSizesOfProject() {
    //TODO: Denis your turn
    println("In the end we should have the return type of list[UnitLengthTuple]");
}

UnitSizeRanking getResultingUnitSizeRanking(list[UnitLengthTuple] allMethodsOfProject) {
    // TODO: Finish
    return excellentUnitSizeRanking;
}