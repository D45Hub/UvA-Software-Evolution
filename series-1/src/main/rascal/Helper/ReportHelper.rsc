module Helper::ReportHelper

import lang::csv::IO;
import Ranking::Ranking;
import Ranking::RiskRanges;
import IO;
import util::Math;

alias ResultRelation = rel[str metric, str rating, str result];

private ResultRelation resultRelation = {};

void writeCSVReport() {
    writeCSV(#ResultRelation, resultRelation, |project://series-1/src/main/rsc/output.csv|);
}

void addToReport(str metric, str rating, str result) {
    resultRelation += {<metric, rating, result>};
}

void addToReport(str metric, Ranking ranking, str result) {
    addToReport(metric, ranking.name, result);
}

void addToReport(str metric, RiskThreshold threshold, str result) {
    addToReport(metric, threshold.rankLevel, result);
}

void addToReport(str metric, str rating) {
    resultRelation += {<metric, rating, "">};
}

void addToReport(str metric, Ranking ranking) {
    addToReport(metric, ranking.name);
}

void addToReport(str metric, RiskThreshold threshold) {
    addToReport(metric, threshold.rankLevel);
}

void getLinesAndPercentagesPrint (str name, int linesOfCode, num percentages) {
    println(name + " "  + toString(linesOfCode) + " lines "
                        + "("+ toString(percentages)
                        + "%" + ")");

}