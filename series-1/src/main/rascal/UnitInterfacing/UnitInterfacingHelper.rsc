module UnitInterfacing::UnitInterfacingHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import List;

alias UnitInterfacingComplexityValue = tuple[Declaration method, int unitInterfacingComplexity];

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
    UnitInterfacingComplexityValue complexityValue = <m, parameterAmount>;
    unitInterfacingValues += [complexityValue];

    return interfacingValues;
}