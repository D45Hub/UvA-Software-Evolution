module Ranking::RiskRanges

import Ranking::Ranking;

import util::Math;

// Risks are taken from the Paper
alias RiskOverview = tuple[int low, int moderate, int high, int veryHigh];

// The thresholds for each of the ranking categories.
// Example in CC maximum relative volume 25% = moderate risk
alias RiskThreshold = tuple[Ranking rankLevel, int low, int moderate, int high, int veryHigh];

/** This function is used to get the risk name of a particular function 
important for Unit Sizing, Unit Interfacing and Cyclomatic complexity. 

*/
public Ranking getScaleRating(RiskOverview risks, int totalItems, list[RiskThreshold] RiskThresholds) {
	RiskOverview rankingDiv = getRisksDiv(risks, totalItems);
    
	for(RiskThresholdItem <- RiskThresholds) { // For each 
		if((rankingDiv.low <= RiskThresholdItem.low || RiskThresholdItem.low == -1) &&
		   (rankingDiv.moderate <= RiskThresholdItem.moderate || RiskThresholdItem.moderate == -1) &&
		   (rankingDiv.high <= RiskThresholdItem.high || RiskThresholdItem.high == -1) &&
		   (rankingDiv.veryHigh <= RiskThresholdItem.veryHigh || RiskThresholdItem.veryHigh == -1)) {
			return RiskThresholdItem.rankLevel;
		} 
	}

	return veryNegative;
}

public RiskOverview getRisksDiv(RiskOverview riskCount, num totalMethods) {
	RiskOverview rankingDiv = <0,0,0,0>;
	rankingDiv.low = round(toRat(riskCount.low,1) * 100.0 / totalMethods);
	rankingDiv.moderate = round(toRat(riskCount.moderate,1) * 100.0 / totalMethods);
	rankingDiv.high = round(toRat(riskCount.high,1) * 100.0 / totalMethods);
	rankingDiv.veryHigh = round(toRat(riskCount.veryHigh,1) * 100.0 / totalMethods);
	
	return rankingDiv;
}

public str stringifyRiskOverview(RiskOverview risks){
	int total = risks.low + risks.moderate + risks.high + risks.veryHigh;
	RiskOverview divs = getRisksDiv(risks, total);
	
	return "Low: <risks.low> (<divs.low>%), moderate: <risks.moderate> (<divs.moderate>%), High: <risks.high> (<divs.high>%), VeryHigh: <risks.veryHigh> (<divs.veryHigh>%)";
}