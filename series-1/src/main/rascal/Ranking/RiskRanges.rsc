module Ranking::RiskRanges

import Ranking::Ranking;

import util::Math;

// Risks are taken from the Paper 
alias RiskOverview = tuple[int low, int normal, int high, int veryHigh];

alias MaxRisk = tuple[Ranking rankLevel, int low, int normal, int high, int veryHigh];

public Ranking getScaleRating(RiskOverview risks, int totalItems, list[MaxRisk] MaxRisks) {

	RiskOverview rankingDiv = getRisksDiv(risks, totalItems);
    
	for(MaxRiskItem <- MaxRisks) { // For each 
		if((rankingDiv.low <= MaxRiskItem.low || MaxRiskItem.low == -1) &&
		   (rankingDiv.normal <= MaxRiskItem.normal || MaxRiskItem.normal == -1) &&
		   (rankingDiv.high <= MaxRiskItem.high || MaxRiskItem.high == -1) &&
		   (rankingDiv.veryHigh <= MaxRiskItem.veryHigh || MaxRiskItem.veryHigh == -1)) {
			return MaxRiskItem.rankLevel;
		} 
	}

	return veryNegative;
}

public RiskOverview getRisksDiv(RiskOverview riskCount, num totalMethods) {
	RiskOverview rankingDiv = <0,0,0,0>;
	rankingDiv.low = round(toRat(riskCount.low,1) * 100.0 / totalMethods); //TODO: to real. Round
	rankingDiv.normal = round(toRat(riskCount.normal,1) * 100.0 / totalMethods);
	rankingDiv.high = round(toRat(riskCount.high,1) * 100.0 / totalMethods);
	rankingDiv.veryHigh = round(toRat(riskCount.veryHigh,1) * 100.0 / totalMethods);
	
	return rankingDiv;
}

public str stringifyRiskOverview(RiskOverview risks){
	int total = risks.low + risks.normal + risks.high + risks.veryHigh;
	RiskOverview divs = getRisksDiv(risks, total);
	
	return "Low: <risks.low> (<divs.low>%), Normal: <risks.normal> (<divs.normal>%), High: <risks.high> (<divs.high>%), VeryHigh: <risks.veryHigh> (<divs.veryHigh>%)";
}