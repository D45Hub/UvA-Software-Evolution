module UnitSize::UnitSize 

import Ranking::Ranking;
import GeneralHelper::ProjectHelper;

alias Size = num;
alias UnitSizeRanking =  tuple[Ranking rankingType,
                                Size minLineOfunit,
                                Size maxLinesOfUnit];


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



/* Function to map the resulting unit size. Get all units and their according
length and then average it and map it to a ranking. */
// public UnitSizeRanking getManYearsRanking(int linesOfCode){
//     UnitSizeRanking resultRanking =  [ranking | ranking <- allMYRankings,
//                                 (floor(convertLOCtoKLOC(linesOfCode)) < ranking.maxKLOC
//                                 || ranking.maxYears == -1)][0];
//     return resultRanking;
// }