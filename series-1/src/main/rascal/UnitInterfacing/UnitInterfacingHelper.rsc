module UnitInterfacing::UnitInterfacingHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import Ranking::Ranking;
import Ranking::RiskRanges;

import List;
import Map;

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

/* This method calculates the overall percentage of methods lying in a category */
map[str, int] calculateRiskPercentages(map[str, int] absoluteRiskValues) {
	int overallMethods = size(absoluteRiskValues);
	map[str, int]  riskOverview = ("lowRisk" : 0, "mediumRisk" : 0, "highRisk" : 0, "veryHighRisk": 0);
	// TODO Finish function
	return riskOverview;

} 