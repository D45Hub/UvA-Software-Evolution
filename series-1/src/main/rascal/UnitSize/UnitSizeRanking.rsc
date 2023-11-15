module UnitSize::UnitSizeRanking

import UnitSize::UnitSize;
import Ranking::Ranking;

alias UnitSizeRankingValues = tuple[Ranking rankingType,
                                num moderateRisk,
                                num highRisk,
                                num veryHighRisk];

// TODO Fill out with better metrics... Good = SIG Paper, 4 Star Rating.
UnitSizeRankingValues excellentUnitSizeRanking = <excellent, 50, 15, 3>;
UnitSizeRankingValues goodUnitSizeRanking = <good, 44.5, 20.3, 6.7>;
UnitSizeRankingValues neutralUnitSizeRanking = <neutral, 35, 25, 10>;
UnitSizeRankingValues negativeUnitSizeRanking = <negative, 30, 30, 15>;
UnitSizeRankingValues veryNegativeUnitSizeRanking = <veryNegative, -1, -1, -1>;

list[UnitSizeRankingValues] allUnitSizeRankings = [excellentUnitSizeRanking, 
                                                goodUnitSizeRanking, 
                                                neutralUnitSizeRanking, 
                                                negativeUnitSizeRanking, 
                                                veryNegativeUnitSizeRanking];

public UnitSizeRankingValues getUnitSizeRanking(UnitSizeDistribution relativeDistribution) {

    num moderatePercentage = relativeDistribution.moderateRisk;
    num highPercentage = relativeDistribution.highRisk;
    num veryHighPercentage = relativeDistribution.veryHighRisk;

    if (veryHighPercentage <= excellentUnitSizeRanking.moderateRisk && highPercentage <= excellentUnitSizeRanking.highRisk && moderatePercentage <= excellentUnitSizeRanking.moderateRisk) {
        return excellentUnitSizeRanking;
    }
    if (veryHighPercentage <= goodUnitSizeRanking.moderateRisk && highPercentage <= goodUnitSizeRanking.highRisk && moderatePercentage <= goodUnitSizeRanking.moderateRisk) {
        return goodUnitSizeRanking;
    }
    if (veryHighPercentage <= neutralUnitSizeRanking.moderateRisk && highPercentage <= neutralUnitSizeRanking.highRisk && moderatePercentage <= neutralUnitSizeRanking.moderateRisk) {
        return neutralUnitSizeRanking;
    }
    if (veryHighPercentage <= negativeUnitSizeRanking.moderateRisk && highPercentage <= negativeUnitSizeRanking.highRisk && moderatePercentage <= negativeUnitSizeRanking.moderateRisk) {
        return negativeUnitSizeRanking;
    }
    
    return veryNegativeUnitSizeRanking;
}