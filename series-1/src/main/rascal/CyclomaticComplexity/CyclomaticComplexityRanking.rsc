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

        if (veryHighPercentage <= 5 && highPercentage <= 15 && moderatePercentage <= 50) {
            return negativeComplexityRanking;
        }
        if (veryHighPercentage <= 0 && highPercentage <= 10 && moderatePercentage <= 40) {
            return neutralComplexityRanking;
        }
        if (veryHighPercentage <= 0 && highPercentage <= 5 && moderatePercentage <= 30) {
            return goodComplexityRanking;
        }
        if (veryHighPercentage <= 0 && highPercentage <= 0 && moderatePercentage <= 25) {
            return excellentComplexityRanking;
        }
        return veryNegativeComplexityRanking;

}