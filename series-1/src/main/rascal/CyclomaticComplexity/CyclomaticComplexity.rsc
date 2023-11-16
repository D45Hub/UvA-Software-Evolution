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

public int getCyclomaticComplexity(Declaration method) {
	int result = 1;
		//Calculate in the method the complexity
	visit(method) {
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
	return result;
}
/**
Determines, how many lines of code are in each category of risks 
*/
public RiskOverview getCyclomaticRiskOverview(list[Declaration] methods) {

    // How many lines of code are in one risk category.
	RiskOverview complexity = <0, 0, 0, 0>;
	
	for(m <- methods) {
		//Base complexity is always 1. This is the function body

		// After you calculated the possible complexity for one unit, you need
        // to add it into the correct risk category.
		// Because we need to divide the stuff in the end, we use the size.
		result = getCyclomaticComplexity(m);

		int linesOfMethod = size(getLOC(readFile(m.src)));

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

	return complexity;
}