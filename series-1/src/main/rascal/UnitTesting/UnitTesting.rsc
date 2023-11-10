module UnitTesting::UnitTesting

import Ranking::Ranking;
import lang::csv::IO;
import IO;
import util::Math;

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

alias LineStatistics = tuple[str className, int linesMissed, int linesCovered];

/* Mapping of the Test Coverage */

TestCoverageRanking excellentTCRanking = <excellent, 95, 100>;
TestCoverageRanking goodTCRanking = <good, 80, 95>;
TestCoverageRanking neutralTCRanking = <neutral, 60, 80>;
TestCoverageRanking negativeTCRanking = <negative, 20, 60>;
TestCoverageRanking veryNegativeTCRanking = <veryNegative, 0, 20>;

list[TestCoverageRanking] allCoverageRankings = [excellentTCRanking,
                                            goodTCRanking,
                                            neutralTCRanking,
                                            negativeTCRanking,
                                            veryNegativeTCRanking];

list[LineStatistics] getLineStatistics(loc csvSource) {
    list[LineStatistics] lineStats = [];

    csvFileContent = readCSV(#rel[str GROUP, str PACKAGE, str CLASS, int INSTRUCTION_MISSED, int INSTRUCTION_COVERED, int BRANCH_MISSED, int BRANCH_COVERED, int LINE_MISSED, int LINE_COVERED, int COMPLEXITY_MISSED, int COMPLEXITY_COVERED, int METHOD_MISSED, int METHOD_COVERED], csvSource);

    for (csvLine <- csvFileContent) {
        str className = csvLine.PACKAGE + csvLine.CLASS;
        LineStatistics stats = <className, csvLine.LINE_MISSED, csvLine.LINE_COVERED>;
        lineStats += [stats];
    }

    return lineStats;
}

LineStatistics getGroupedStatistics(loc csvSource) {
    list[LineStatistics] lineStats = getLineStatistics(csvSource);

    int totalLinesMissed = 0;
    int totalLinesCovered = 0;

    for (stats <- lineStats) {
        totalLinesMissed += stats.linesMissed;
        totalLinesCovered += stats.linesCovered;
    }

    return <"Overall Statistics: ", totalLinesMissed, totalLinesCovered>;
}

TestCoverageRanking getCoverageRanking(LineStatistics stats) {

    real linesMissed = toReal(stats.linesCovered);

    // This is always above zero since the tool filters out any empty methods.
    real trackedLines = toReal((stats.linesMissed + stats.linesCovered));
    real missedPercentage = linesMissed / trackedLines;

    int missedLinePercentage = round(missedPercentage * 100.0);

    println(missedLinePercentage);
    TestCoverageRanking resultRanking = [ranking | ranking <- allCoverageRankings,
                                (missedLinePercentage <= ranking.max && missedLinePercentage >= ranking.min)][0];
    return resultRanking;
}

void formatOverallStatistics(loc csvSource) {
    LineStatistics groupedStatistics = getGroupedStatistics(csvSource);
    TestCoverageRanking ranking = getCoverageRanking(groupedStatistics);

    println(groupedStatistics.className);
    println(ranking);
} 

void formatClassStatistics(loc csvSource) {
    list[LineStatistics] classStatistics = getLineStatistics(csvSource);
    list[TestCoverageRanking] ranking = [];

    for(classStats <- classStatistics) {
        TestCoverageRanking ranking = getCoverageRanking(classStats);
        println(classStats.className);
        println(ranking);
        println("");
    }
}