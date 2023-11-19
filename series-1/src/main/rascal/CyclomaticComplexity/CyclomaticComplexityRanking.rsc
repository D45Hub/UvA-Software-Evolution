module CyclomaticComplexity::CyclomaticComplexityRanking
import Ranking::Ranking;
import Ranking::RiskRanges;
import CyclomaticComplexity::CyclomaticComplexity;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import util::Math;
alias ComplexityValue = tuple[ComplexityRanking complexityRanking, RiskOverview complexityPercentages];

alias ComplexityRanking = tuple[Ranking rankingType,
                                int moderateRisk,
                                int highRisk,
                                int veryHighRisk];


alias ComplexityThreshholds = tuple[int min, int max];


ComplexityRanking excellentComplexityRanking = <excellent, 25, 0, 0>;
ComplexityRanking goodComplexityRanking = <good, 30, 5, 0>;
ComplexityRanking neutralComplexityRanking = <neutral, 40, 10, 0>;
ComplexityRanking negativeComplexityRanking = <negative, 50, 25, 5>;
ComplexityRanking veryNegativeComplexityRanking = <veryNegative, -1, -1, -1>;

map[str, int] getCyclomaticRiskRating(int linesOfCode, RiskOverview complexityTuple) {
    
    lowPercentageOfCode = round((toReal(complexityTuple.low) / toReal(linesOfCode)) * 100);
    mediumPercentageOfCode = round((toReal(complexityTuple.moderate) / toReal(linesOfCode)) * 100);
    highPercentageOfCode = round((toReal(complexityTuple.high) / toReal(linesOfCode)) * 100);
    veryHighPercentageOfCode = round((toReal(complexityTuple.veryHigh) / toReal(linesOfCode)) * 100);
    return (
        "low": lowPercentageOfCode,
        "moderate" : mediumPercentageOfCode,
        "high" : highPercentageOfCode,
        "veryHigh" : veryHighPercentageOfCode
    );
}

ComplexityRanking getCyclomaticRanking(RiskOverview riskRating, int linesOfCode) {

        int lowPercentage = round(toReal(riskRating.low) / toReal(linesOfCode) * 100);
        int moderatePercentage = round(toReal(riskRating.moderate) / toReal(linesOfCode) * 100);
        int highPercentage = round(toReal(riskRating.high) / toReal(linesOfCode) * 100);
        int veryHighPercentage = round(toReal(riskRating.veryHigh) / toReal(linesOfCode) * 100);

        if (veryHighPercentage <= negativeComplexityRanking.veryHighRisk
            && highPercentage <= negativeComplexityRanking.highRisk
            && moderatePercentage <= negativeComplexityRanking.moderateRisk) {
            return negativeComplexityRanking;
        }
        if (veryHighPercentage <= neutralComplexityRanking.veryHighRisk
            && highPercentage <= neutralComplexityRanking.highRisk
            && moderatePercentage <= neutralComplexityRanking.moderateRisk) {
            return neutralComplexityRanking;
        }
        if (veryHighPercentage <= goodComplexityRanking.veryHighRisk
            && highPercentage <= goodComplexityRanking.highRisk
            && moderatePercentage <= goodComplexityRanking.moderateRisk) {
            return goodComplexityRanking;
        }
        if (veryHighPercentage <= excellentComplexityRanking.veryHighRisk
            && highPercentage <= excellentComplexityRanking.highRisk
            && moderatePercentage <= excellentComplexityRanking.moderateRisk) {
            return excellentComplexityRanking;
        }
        return veryNegativeComplexityRanking;

}