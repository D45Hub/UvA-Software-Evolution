module CyclomaticComplexity::CyclomaticComplexityRanking
import Ranking::Ranking;
import Ranking::RiskRanges;
import CyclomaticComplexity::CyclomaticComplexity;
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
ComplexityRanking negativeComplexityRanking = <negative, 50, 15, 5>;
ComplexityRanking veryNegativeComplexityRanking = <veryNegative, -1, -1, -1>;

map[str, int] getCyclomaticRiskRating(list[loc] locMethods) {
    
    map[str, int] complexityRating = ();
    complexityTuple = getCyclomaticRiskOverview(locMethods); 
    linesOfCode = complexityTuple.low + complexityTuple.moderate + complexityTuple.high + complexityTuple.veryHigh;

    lowPercentageOfCode = round((toReal(complexityTuple.low) / toReal(linesOfCode)) * 100);
    mediumPercentageOfCode = round((toReal(complexityTuple.moderate) / toReal(linesOfCode)) * 100);
    highPercentageOfCode = round((toReal(complexityTuple.high) / toReal(linesOfCode)) * 100);
    veryHighPercentageOfCode = round((toReal(complexityTuple.veryHigh) / toReal(linesOfCode)) * 100);

    return (
        "low": lowPercentageOfCode,
        "medium" : mediumPercentageOfCode,
        "high" : highPercentageOfCode,
        "veryHigh" : veryHighPercentageOfCode
    );
}

ComplexityRanking getCyclomaticRanking(map[str, int] riskRating) {
        if (riskRating["veryHigh"] <= 5 && riskRating["high"] <= 15 && riskRating["moderate"] <= 50) {
            return negativeComplexityRanking;
        }
        if (riskRating["veryHigh"] <= 0 && riskRating["high"] <= 10 && riskRating["moderate"] <= 40) {
            return neutralComplexityRanking;
        }
        if (riskRating["veryHigh"] <= 0 && riskRating["high"] <= 5 && riskRating["moderate"] <= 30) {
            return goodComplexityRanking;
        }
        if (riskRating["veryHigh"] <= 0 && riskRating["high"] <= 0 && riskRating["moderate"] <= 25) {
            return excellentComplexityRanking;
        }
        return veryNegativeComplexityRanking;

}