module CyclomaticComplexity::CyclomaticComplexity
import CyclomaticComplexity::CyclomaticComplexityRanking;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import util::Math;

import Ranking::RiskRanges;
import Volume::LOCVolume;
import UnitSize::UnitSize;
ComplexityThreshholds mid = <11,21>;
ComplexityThreshholds high = <21,50>;
ComplexityThreshholds veryHigh = <50,-1>;
/**
Determines, how many lines of code are in each category of risks 
*/
public RiskOverview getCyclomaticRiskOverview(list[UnitLengthTuple] allMethodTuples) {

    // How many lines of code are in one risk category.
	RiskOverview complexity = <0, 0, 0, 0>;
	
	for(m <- allMethodTuples) {
		ast = createAstFromFile(m.method, true);
		//Base complexity is always 1. This is the function body
		int result = 1;
		//Calculate in the method the complexity
		visit(ast) {
	    	case \do(_,_) : result += 1;
	    	case \foreach(_,_,_) : result += 1;	
	    	case \for(_,_,_,_) : result += 1;
	  		case \for(_,_,_) : result += 1;
	  		case \if(_,_) : result += 1;
			case \if(_,_,_) : result += 1;
			case \case(_) : result += 1; // case:
			case \catch(_,_) : result += 1;	 //catch() {}
	   		case \while(_,_) : result += 1;	//while(_) x
    		case \conditional(_, _, _): result += 1; //a ? c : d
    		case \infix(_, /^\|\||&&$/, _) : result += 1; //a && b. a || b
    		}

		// After you calculated the possible complexity for one unit, you need
        // to add it into the correct risk category.
		// Because we need to divide the stuff in the end, we use the size.

		int linesOfMethod = m.methodLOC;
		println("lines of method");
		println(linesOfMethod);
		if(result >= 1 && result <= 10) {
            complexity.low += linesOfMethod;
        } else if(result >= 11 && result <= 20) {
             complexity.moderate += linesOfMethod;
        } else if(result >= 21 && result <= 50) {
             complexity.high += linesOfMethod;
        } else if(result > 51) {
             complexity.veryHigh += linesOfMethod;
        }
	

	}
	
	println("returning complexity low");
	println(toReal(complexity.low) / toReal(24050));
	println("returning complexity medium");
	println(complexity.moderate);
	println(toReal(complexity.moderate) / toReal(24050));
	println("returning complexity high");
	println(toReal(complexity.high) / toReal(24050));

	println("returning complexity veryHigh");
	println(toReal(complexity.veryHigh) / toReal(24050));


	return complexity;
}