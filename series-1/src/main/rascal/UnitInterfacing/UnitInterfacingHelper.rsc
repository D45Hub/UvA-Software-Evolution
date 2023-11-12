module UnitInterfacing::UnitInterfacingHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import Ranking::Ranking;
import Ranking::RiskRanges;
import MetricsHelper::LOCHelper;

import List;
import Map;
import util::Math;
import IO;

/* 
In case the metric is more relevant at the unit level, we make use of so-called
quality profiles. TÜVit Paper
*/ 

/* On the left hand side a ranking is proproposed. the 4 values in the tuple represent
the maximum thresholds of low - moderate - high - very high risks which the unit parameters
regarding to a whole computer program can have. So e.g. to get an "excellent" ranking
in unit interfacing, you are only allowed to have 25% percent of unit interfaces in the moderate
risk categories. Everything else should be 0 or in the low risk (which is calculated as the remainder
of the others) */ 

/* 
From TÜVit Paper: 
For each category, the relative volumes are computed by summing the lines of 
code of the units that fit in that category, and dividing by the total
lines of code in all units
*/ 

list[RiskThreshold] risks = [<excellent,-1,25,0,0>,
						<good,-1,30,5,0>,
						<neutral,-1,40,10,0>,
						<negative,-1,50,25,5>,
						<veryNegative,-1,-1,-1,-1>
					]; 


/* Definining values for the individual risks */

alias Risk = str;

alias UnitInterfacingComplexityValue = tuple[Declaration method, int unitInterfacingComplexity];
alias UnitInterfaceRiskProfile = tuple[Declaration method, Risk risk];

list[UnitInterfacingComplexityValue] getUnitInterfacingValues(list[Declaration] methodUnits) {

    list[UnitInterfacingComplexityValue] unitInterfacingValues = [];

	for (m <- methodUnits) {
        visit(m) {
            case \method(_,_, list[Declaration] parameters,_): {
                unitInterfacingValues = addToInterfacingValues(unitInterfacingValues, m, size(parameters));
	         }
	        case \method(_,_, list[Declaration] parameters,_,_): {
	      	    unitInterfacingValues = addToInterfacingValues(unitInterfacingValues, m, size(parameters));
	        }
	        case \constructor(_, list[Declaration] parameters,_,_): {
	        	unitInterfacingValues = addToInterfacingValues(unitInterfacingValues, m, size(parameters));
	        }
        }
    }

    return unitInterfacingValues;
}

list[UnitInterfacingComplexityValue] addToInterfacingValues(list[UnitInterfacingComplexityValue] currentUnitInterfacingValues, Declaration methodUnit, int parameterAmount) {
    list[UnitInterfacingComplexityValue] interfacingValues = currentUnitInterfacingValues;
    UnitInterfacingComplexityValue complexityValue = <methodUnit, parameterAmount>;
    unitInterfacingValues += [complexityValue];

    return interfacingValues;
}

list[UnitInterfaceRiskProfile] getAbsolutRiskValues(list[UnitInterfacingComplexityValue] methodComplexities) {

	list[UnitInterfaceRiskProfile] riskProfile = [];

	for(complexity <- methodComplexities) {
		/**
			Since research on how unit interfacing ratings,
			especially with concrete values mentioned is basically non-existent,
			we created our own thresholds.

			These are loosely based on the "Deriving Metric Thresholds from Benchmark Data"
			paper, their evaluated metric distribution, box plot per risk category,
			and personal experience from Java programming, in equal fashion.

			With this we arrive at the following risk ratings for Java unit interfacing.

			Low risk: 0 and 1 method parameters.
			Moderate risk: 2 and 3 method parameters.
			High risk: 4 to 6 method parameters.
			Very high risk: 7 or more method parameters. 
		*/
		int compl = complexity.unitInterfacingComplexity;
		if(compl == 0 || compl == 1) {
			riskProfile += <complexity.method, lowRisk>;
		} else if(compl == 2 || compl == 3) {
			riskProfile += <complexity.method, moderateRisk>;
		} else if(compl >=4 && compl <= 6) {
			riskProfile += <complexity.method, highRisk>;
		} else {
			riskProfile += <complexity.method, veryHighRisk>;
		}
	}

	return riskProfile;
}

/* This method calculates the overall percentage of methods lying in a category */
map[str, int] calculateAbsoluteRiskAmount(list[UnitInterfaceRiskProfile] riskProfiles) {

	map[str, int] riskOverview = ("lowRisk" : 0, "moderateRisk" : 0, "highRisk" : 0, "veryHighRisk": 0);

	for(profile <- riskProfiles) {
		loc rawMethodLoc = profile.method.src;
        str rawMethod = readFile(rawMethodLoc);
		int methodLOC = getLinesOfCodeAmount(rawMethod);

		riskOverview[profile.risk] += methodLOC;
	}

	return riskOverview;
} 

map[str, int] calculateRelativeRiskAmount(map[str, int] absoluteRiskAmount) {

	map[str, int] relativeRiskOverview = ("lowRisk" : 0, "moderateRisk" : 0, "highRisk" : 0, "veryHighRisk": 0);
	real overallLines = toReal((absoluteRiskAmount["lowRisk"] + absoluteRiskAmount["moderateRisk"] + absoluteRiskAmount["highRisk"] + absoluteRiskAmount["veryHighRisk"]));
	
	for(riskKey <- absoluteRiskAmount) {
		real riskPercentage = toReal((absoluteRiskAmount[riskKey] / overallLines) * 100.0);
		int riskPercentageValue = round(riskPercentage);

		relativeRiskOverview[riskKey] += riskPercentageValue;
	}

	return relativeRiskOverview;
}

RiskThreshold calculateRiskThreshold(map[str, int] relativeRiskAmount) {

	list[RiskThreshold] resultRisks = [risk | risk <- risks,
                                (risk.moderate >= relativeRiskAmount["moderateRisk"]
                                && risk.high >= relativeRiskAmount["highRisk"]
								&& risk.veryHigh >= relativeRiskAmount["veryHighRisk"]) 
                                || risk.veryHigh == -1];

    resultRisks = sort(resultRisks, bool (RiskThreshold a, RiskThreshold b) { return a.rankLevel.val > b.rankLevel.val; });
    return resultRisks[0];
}

public RiskThreshold generateRiskThreshold(list[Declaration] methodUnits) {
	list[UnitInterfacingComplexityValue] methodComplexities = getUnitInterfacingValues(methodUnits);
	list[UnitInterfaceRiskProfile] absoluteRiskValues = getAbsolutRiskValues(methodComplexities);
	map[str, int] relativeRiskValues = calculateRelativeRiskAmount(absoluteRiskValues);

	return calculateRiskThreshold(relativeRiskValues);
}

public void formatRiskThreshold(list[Declaration] methodUnits) {
	RiskThreshold riskThreshold = generateRiskThreshold(methodUnits);
	println(riskThreshold);
}