module Volume::ManYears

import util::Math;
import Ranking::Ranking;
import IO;
import List;
/**
Man Years are calculated based on the amount of lines of code 

+------+-----------+-------------+
| RANK |    MY     | JAVA - KLOC |
+------+-----------+-------------+
| ++   | 0 - 8     | 0 - 66      |
| +    | 8 - 30    | 66 - 246    |
| o    | 30 - 80   | 246 - 665   |
| -    | 80 - 160  | 655 - 1,310 |
| --   | > 160     | > 1,310     |
+------+-----------+-------------+

*/ 
alias KLOC = num; // Lines of Codes * 1000 
alias MY = num; // Man Year
alias MYRanking = tuple[Ranking rankingType, MY minYears,MY maxYears,KLOC minKLOC,KLOC maxKLOC];

/* Using the KLOC definition to convert properly, since we do not get KLOCs */ 
num convertLOCtoKLOC (num linesOfCode) = toReal(linesOfCode / 1000.0);

/* Mapping of the Man Years */

MYRanking excellentMYRanking = <excellent, 0, 8, 0, 66>;
MYRanking goodMYRanking = <good, 8, 30, 66, 246>;
MYRanking neutralMYRanking = <neutral, 30, 80, 246, 665>;
MYRanking negativeMYRanking = <negative, 80, 160, 655, 1310>;
MYRanking veryNegativeMYRanking = <veryNegative, 160, -1 , 1310, -1>;

list[MYRanking] allMYRankings = [excellentMYRanking, goodMYRanking,
                                neutralMYRanking, negativeMYRanking,
                                veryNegativeMYRanking];

/* Function to map the resulting man years to according rank*/

public MYRanking getManYearsRanking(int linesOfCode){
    MYRanking resultRanking =  [ranking | ranking <- allMYRankings,
                                (floor(convertLOCtoKLOC(linesOfCode)) < ranking.maxKLOC
                                || ranking.maxYears == -1)][0];
    return resultRanking;
}


public void formatRanking (int linesOfCode) {
    MYRanking manYearRankingResult = getManYearsRanking(linesOfCode);
    println("Lines of code " + toString(linesOfCode));
    println("Resulting ranking " + manYearRankingResult.rankingType.name);
}