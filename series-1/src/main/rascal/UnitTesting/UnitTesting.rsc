module UnitTesting::UnitTesting

import Ranking::Ranking;

/**
Code Coverage based on the paper

+------+-----------+
| RANK |  Coverage | 
+------+-----------+
| ++   | 95 - 100% |
| +    | 80 - 95%  |
| o    | 60 - 80   | 
| -    | 20 - 60   | 
| --   | 0 - 20    | 
+------+-----------+

*/ 

alias TestCoverage = int;
alias TestCoverageRanking =  tuple[Ranking rankingType,
                                TestCoverage min,
                                TestCoverage max];

/* Mapping of the Test Coverage */

TestCoverageRanking excellentTCRanking = <excellent, 95, 100>;
TestCoverageRanking goodTCRanking = <good, 80, 95>;
TestCoverageRanking neutralTCRanking = <neutral, 60, 80>;
TestCoverageRanking negativeTCRanking = <negative, 20, 60>;
TestCoverageRanking veryNegativeTCRanking = <veryNegative, 0, 20>;
