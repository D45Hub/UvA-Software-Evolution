module Volume::EmptyLineVolume

import MetricsHelper::LOCHelper;
import List;
import Ranking::Ranking;
import util::Math;
import IO;

alias EmptyLineRanking = tuple[Ranking rankingType,
                                int fromLinesPercentage,
                                int untilLinesPercentage];

// TODO THINK OF BETTER MEASUREMENTS... THIS IS JUST PROOF OF CONCEPT...
EmptyLineRanking excellentEmptyLineRanking = <excellent, 0, 10>;
EmptyLineRanking goodEmptyLineRanking = <good, 11, 20>;
EmptyLineRanking neutralEmptyLineRanking = <neutral, 21, 30>;
EmptyLineRanking negativeEmptyLineRanking = <negative, 31, 40>;
EmptyLineRanking veryNegativeEmptyLineRanking = <veryNegative, -1, -1>;

list[EmptyLineRanking] allEmptyLineRankings = [excellentEmptyLineRanking,
                                                goodEmptyLineRanking, 
                                                neutralEmptyLineRanking, 
                                                negativeEmptyLineRanking, 
                                                veryNegativeEmptyLineRanking];

int amountOfEmptyLines(list[str] codeLines) {
    // TODO FILTER OUT MULTI LINE COMMENTS CORRECTLY... AND ADD TO FINAL RETURN RESULT...
    list[str] filteredLines = [line | line <- codeLines, isRemovableCodeLine(line)];
    return size(filteredLines);
}

int getEmptyLinesPercentage(int emptyLinesAmount, int totalLOC) {
    real emptyLinesReal = toReal(emptyLinesAmount);
    real totalLOCReal = toReal(totalLOC);
    real emptyLinesPercentage = emptyLinesReal / totalLOCReal;

    return round(emptyLinesPercentage * 100.0);
}

public EmptyLineRanking getEmptyLineRanking(int averageEmptyLinesPercentage){
    EmptyLineRanking resultRanking = [ranking | ranking <- allEmptyLineRankings,
                                (averageEmptyLinesPercentage > ranking.fromLinesPercentage
                                && averageEmptyLinesPercentage < ranking.untilLinesPercentage 
                                || ranking.fromLinesPercentage == -1)][0];
    return resultRanking;
}

public EmptyLineRanking calculateEmptyLineRanking(list[str] codeLines) {
    int totalLOC = size(codeLines);
    int amountOfEmptyLines = amountOfEmptyLines(codeLines);
    int emptyLinesPercentage = getEmptyLinesPercentage(amountOfEmptyLines, totalLOC);

    return getEmptyLineRanking(emptyLinesPercentage);
}