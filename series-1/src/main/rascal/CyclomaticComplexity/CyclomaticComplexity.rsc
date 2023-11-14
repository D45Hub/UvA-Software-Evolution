module CyclomaticComplexity::CyclomaticComplexity
import CyclomaticComplexity::CyclomaticComplexityRanking;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;

import Ranking::RiskRanges;
import Volume::LOCVolume;

ComplexityThreshholds mid = <11,20>;
ComplexityThreshholds high = <21,50>;
ComplexityThreshholds veryHigh = <51,-1>;

/**
Determines, how many lines of code are in each category of risks 
*/
public RiskOverview getCyclomaticRiskOverview(list[loc] locMethods) {

    // How many lines of code are in one risk category.
	RiskOverview complexity = <0, 0, 0, 0>;
	
	for(m <- locMethods) {

		//Base complexity is always 1. This is the function body
		int result = 1;

		//Calculate in the method the complexity
		visit(createAstFromFile(m, true)) {
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
		if(result >= mid.min && result <= mid.max) {
			complexity.moderate += size(getLOC(readFile(m), false));
		} else if (result >= high.min && result <= high.max) {
			complexity.high  += size(getLOC(readFile(m), false));
		} else if (result >= veryHigh.min ) {
			complexity.veryHigh  += size(getLOC(readFile(m), false));
		} else {
			complexity.low  += size(getLOC(readFile(m), false));
		}
	}
	
	return complexity;
}