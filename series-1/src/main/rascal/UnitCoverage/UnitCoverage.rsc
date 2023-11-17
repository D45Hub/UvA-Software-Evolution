module UnitCoverage::UnitCoverage

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

/**

    Unit test coverage is an interesting metric since most of the time it's a good measure on your general test coverage and what needs to be added.

    The problem is though, that, especially with projects with larger parts of generated code,
    it can be hard to receive a good rating though.
    For this kind of code tests are most likely not needed, since it has been automatically generated.
    But still it is oftentimes tracked alongside with the manually written code, which definitely needs testing.
    So therefore the presented view from unit testing is a bit skewed.

    But as the paper stated, calculating this method is not trivial.
    This is due to the necessity of tracking the executed code lines and instructions.
    Not only do here the problems from tracking what a line of code do play a role here,
    but also the problems of tracking executed lines of code and non-executed code branches.
    Dependent on the programming language used, this may become a lot harder.
    (For example, with functional programming languages, since control flow is harder to track there.)

    One really simple approach to do this in Java, for example would be to artificially add a "logging" statement after each line of code.
    Then you could track which logging statements are executed and which are not.
    From there on you can calculate the coverage. 
    This has the same problems though, especially with tracking "lines of code", since this presumes that every statement has been written in one line.

    This would be pretty hard to implement in Rascal.
    So we didn't. (We got better stuff to do.)

    Therefore we took a similar approach to the paper and used an external library. (Jacoco)
    Using this library we can generate a CSV file automatically. (Either via CMD or Maven or whatever you prefer.)
    From there on we can use the calculated metrics to calculate a final rating based on the values given from the paper.
    (Either from a project-wide perspective or per unit.)

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

    TestCoverageRanking resultRanking = [ranking | ranking <- allCoverageRankings,
                                (missedLinePercentage <= ranking.max && missedLinePercentage >= ranking.min)][0];

    println("Coverage Percentage: " + toString(missedLinePercentage));

    return resultRanking;
}

void formatOverallStatistics(loc csvSource) {
    LineStatistics groupedStatistics = getGroupedStatistics(csvSource);
    TestCoverageRanking ranking = getCoverageRanking(groupedStatistics);

    println(groupedStatistics.className);
    println("Lines Missed: " + toString(groupedStatistics.linesMissed));
    println("Lines Covered: " + toString(groupedStatistics.linesCovered));
    println(ranking);
} 

void formatClassStatistics(loc csvSource) {
    list[LineStatistics] classStatistics = getLineStatistics(csvSource);
    list[TestCoverageRanking] ranking = [];

    println("Class specific statistics");

    for(classStats <- classStatistics) {
        TestCoverageRanking ranking = getCoverageRanking(classStats);
        println(classStats.className);
        println("Lines Missed: " + toString(classStats.linesMissed));
        println("Lines Covered: " + toString(classStats.linesCovered));
        println(ranking);
        println("");
    }
}