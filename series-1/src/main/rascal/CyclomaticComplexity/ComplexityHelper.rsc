module CyclomaticComplexity::ComplexityHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import CyclomaticComplexity::CyclomaticComplexityHelper;
import Ranking::RiskRanges;
import Ranking::Ranking;
import util::Math;
import IO;
import List;

alias ComplexityRanking = tuple[Ranking rankingType,
                                int moderateRisk,
                                int highRisk,
                                int veryHighRisk];

ComplexityRanking excellentComplexityRanking = <excellent, 25, 0, 0>;
ComplexityRanking goodComplexityRanking = <good, 30, 5, 0>;
ComplexityRanking neutralComplexityRanking = <neutral, 40, 10, 0>;
ComplexityRanking negativeComplexityRanking = <negative, 50, 15, 5>;
ComplexityRanking veryNegativeComplexityRanking = <veryNegative, -1, -1, -1>;

list[ComplexityRanking] allComplexityRankings = [excellentComplexityRanking,
                                            goodComplexityRanking,
                                            neutralComplexityRanking,
                                            negativeComplexityRanking,
                                            veryNegativeComplexityRanking];

public ComplexityRanking getOverallComplexityRating(RiskOverview riskOverview) {

    real overallLines = toReal(getOverallLinesFromOverview(riskOverview));

    real moderatePercentage = toReal((riskOverview.moderate / overallLines));
    real highPercentage = toReal((riskOverview.high / overallLines));
    real veryHighPercentage = toReal((riskOverview.veryHigh / overallLines));

    int moderatePercentageValue = round(moderatePercentage * 100.0);
    int highPercentageValue = round(highPercentage * 100.0);
    int veryHighPercentageValue = round(veryHighPercentage * 100.0);

    // Why I needed to do this... I don't know. At this point I am giving up mentally...
    list[ComplexityRanking] resultRankings = [ranking | ranking <- allComplexityRankings,
                                (ranking.moderateRisk >= moderatePercentageValue 
                                && ranking.highRisk >= highPercentageValue && veryHighPercentageValue == 0) 
                                || ranking.veryHighRisk == -1];

    resultRankings = sort(resultRankings, bool (ComplexityRanking a, ComplexityRanking b) { return a.rankingType.val > b.rankingType.val; });
    ComplexityRanking resultRanking = resultRankings[0];
                                
    return resultRanking;
}

public void formatComplexityRanking(list[Declaration] declMethods) {
    RiskOverview riskOverview = getCyclomaticComplexityRankings(declMethods);
    ComplexityRanking ranking = getOverallComplexityRating(riskOverview);

    println(ranking);
}