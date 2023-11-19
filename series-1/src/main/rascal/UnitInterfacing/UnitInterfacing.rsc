module UnitInterfacing::UnitInterfacing

import List;
import Map;
import util::Math;
import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;

import Ranking::Ranking;
import Ranking::RiskRanges;
import Volume::LOCVolumeMetric;
import Volume::LOCVolume;

list[RiskThresholdFloat] risks = [
						<excellent,-1,10.0,1.0,0>,
						<good,-1,14.4,3,0.8>,
						<neutral,-1,20,4,2>,
						<negative,-1,40,10,5>,
						<veryNegative,-1,-1,-1,-1>
					]; 

alias UnitInterfacingRanking = tuple[Ranking rankingType,
                                num moderateRisk,
                                num highRisk,
                                num veryHighRisk];

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



/* Definining values for the individual risks */

alias Risk = str;

alias UnitInterfacingComplexityValue = tuple[Declaration method, int unitInterfacingComplexity];
alias UnitInterfaceRiskProfile = tuple[Declaration method, Risk risk];
alias UnitInterfaceRiskOverview = map[str,int];

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
    interfacingValues += [complexityValue];

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

			Low risk: 0 - 2 method parameters.
			Moderate risk: 3 - 4 method parameters.
			High risk: 5 - 6 method parameters.
			Very high risk: 7 or more method parameters. 
		*/
		/* From SIG Paper .*/ 
		int compl = complexity.unitInterfacingComplexity;
		if(compl >= 0 && compl <= 2) {
			riskProfile += <complexity.method, "lowRisk">;
		} else if(compl >= 3 && compl <= 4) {
			riskProfile += <complexity.method, "moderateRisk">;
		} else if(compl >= 5 && compl <= 6) {
			riskProfile += <complexity.method, "highRisk">;
		} else {
			riskProfile += <complexity.method, "veryHighRisk">;
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
		int methodLOC = size(getLOC(rawMethod));

		riskOverview[profile.risk] += methodLOC;
	}

	return riskOverview;
} 

UnitInterfaceRiskOverview calculateRelativeRiskAmount(map[str, int] absoluteRiskAmount) {

	map[str, int] relativeRiskOverview = ("lowRisk" : 0, "moderateRisk" : 0, "highRisk" : 0, "veryHighRisk": 0);
	real overallLines = toReal((
						absoluteRiskAmount["lowRisk"]
	 					+ absoluteRiskAmount["moderateRisk"]
						+ absoluteRiskAmount["highRisk"]
						+ absoluteRiskAmount["veryHighRisk"]));
	
	for(riskKey <- absoluteRiskAmount) {
		real riskPercentage = toReal(toReal((absoluteRiskAmount[riskKey]) / toReal(overallLines)) * 100.0);
		int riskPercentageValue = round(riskPercentage);

		relativeRiskOverview[riskKey] += riskPercentageValue;
	}

	return relativeRiskOverview;
}


alias UnitRankingValues = tuple[Ranking rankingType,
                                real moderateRisk,
                                real highRisk,
                                real veryHighRisk];
					
UnitRankingValues excellentUnitRankingValues = <excellent,10.0,1.0,0.0>;
UnitRankingValues goodUnitRankingValues = <good,14.4,3.0,0.8>;
UnitRankingValues neutralUnitRankingValues = <neutral,20.0,4.0,2.0>;
UnitRankingValues negativeUnitRankingValues = <negative,40.0,10.0,5.0>;
UnitRankingValues veryNegativeUnitRankingValues = <veryNegative,-1.0,-1.0,-1.0>;


UnitRankingValues getUnitInterfacingRanking(UnitInterfaceRiskOverview riskRating) {


        int lowPercentage = riskRating["lowRisk"];
        int moderatePercentage = riskRating["moderateRisk"];
        int highPercentage = riskRating["highRisk"];
        int veryHighPercentage = riskRating["veryHighRisk"];

        if (veryHighPercentage <= 0 && highPercentage <= 1 && moderatePercentage <= 10) {
            return excellentUnitRankingValues;
        }
        if (veryHighPercentage <= 0.8 && highPercentage <= 3 && moderatePercentage <= 14.4) {
            return goodUnitRankingValues;
        }
        if (veryHighPercentage <= 2 && highPercentage <= 4 && moderatePercentage <= 20) {
            return neutralUnitRankingValues;
        }
        if (veryHighPercentage <= 5 &&highPercentage <= 10 && moderatePercentage <= 40) {
            return negativeUnitRankingValues;
        }
        return veryNegativeUnitRankingValues;

}



