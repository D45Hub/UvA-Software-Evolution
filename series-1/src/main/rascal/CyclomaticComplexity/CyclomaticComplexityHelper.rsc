module CyclomaticComplexity::CyclomaticComplexityHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import Ranking::RiskRanges;
import MetricsHelper::LOCHelper;

import IO;

/**

    Some random thoughts on why this is so hard to calculate, before I forget it all...

    - Highly programming language dependent: 
    There are more or less or even different types of flow-breaking structures.
    This makes the thresholds and rankings for different programming language different.

    - Even dependent on the version of the programming language itself:
    Some programming languages had control structures omitted or added upon their instruction set.
    This can have an effect on the cyclomatic complexity, either increasing it, or decreasing it, due to the difference in the number of control structures.

    - Dependency Injection.
    Since in dependency injection the main goal is to load in objects (and execute methods on them) in runtime,
    this makes calculating the real complexity of a function harder.
    Also we have the issue of measuring the complexity of the Dependency Injection library.
    Due to that it is very ambigous how the complexity of such a pattern could be measured. 

    - Should certain concepts be simplified before evaluation or not?
    Especially with more modern constructs, which are mostly syntactic sugar, how should these be handled in terms of complexity.
    With their most simplified variant or the variant which is currently in the source code but generates the same bytecode as the simplified one.

    - Events.
    It's hard to track what the final control flow is going to look like, which makes calculating the "real" complexity harder.

    Java Specifics, which make measuring the "real" cyclomatic complexity way harder...

    - Exact definition of a unit. 
    Java allows inner anonymous classes and methods. So these need to be taken into account.
    Especially with anonymous Thread declarations this becomes trickier to define.

    - Labelled statements. 
    This allows a kind-of "goto" structure in combination with "break[label]" and "continue[label]".
    -> Further branching out with this control statement and makes it harder to calculate the complexity of a label by itself.
    
    - Reflection.
    This allows to modify runtime attributes of classes, interfaces, fields, methods and also allows for loading in classes with given values.
    Similar to Dependency Injection this makes tracing the real control flow of a program way harder.

    - Proxy-ing.
    Same thing applies as with reflection. How does the real control flow look like?

    - JNI. (Java Native Interface)
    This built-in library allows to all native C code.
    That means, not only making the control flow harder to track, due to branching out to C source code.
    But also this means calculating, measuring and dealing with language-specific factors of other programming languages, considering cyclomatic complexity.

*/

alias CyclomaticComplexityValue = tuple[Declaration method, int cyclomaticComplexity];

public list[CyclomaticComplexityValue] cyclomaticLinesPerPartion(list[Declaration] declMethods) {
			
    list[CyclomaticComplexityValue] complexityValues = [];

	for(m <- declMethods) {
		
		//Base complexity is always 1. This is the function body.
		int result = 1;
		
		//Calculates the complexity by looking up the different conditional operators.
        // Reference https://www.rascal-mpl.org/docs/Library/lang/java/m3/AST/
		visit(m) {
            case \assert(_) : result += 1;
            case \assert(_,_) : result += 1;
            case \break() : result += 1;
            case \break(_) : result += 1;
            case \continue() : result += 1;
            case \continue(_) : result += 1;
	    	case \do(_,_) : result += 1;
	    	case \foreach(_,_,_) : result += 1;	
	    	case \for(_,_,_,_) : result += 1;
	  		case \for(_,_,_) : result += 1;
            // Rascal seems to miss the case "for(;;)" as well with only one operator. This would be included in here as well. Would be "\for(_,_)".
	  		case \if(_,_) : result += 1;
			case \if(_,_,_) : result += 1;
			case \case(_) : result += 1; // case:

            // "try" and "finally" are not included since they don't constitute as control flow structures.
            // Both blocks are always executed, unless an exception gets thrown, in which case the "catch" block gets executed.
			case \catch(_,_) : result += 1;	 //catch() {}
	   		case \while(_,_) : result += 1;	//while(_) x
            case \throw(_) : result += 1; // If assert is considered as control flow, then this I guess too... Unsure about that.
    		case \conditional(_, _, _): result += 1; //a ? c : d
    		case \infix(_, /^\|\||&&|^$/, _) : result += 1; //a && b. a || b. a ^ b. -> Other bitwise operators are excluded since they only modify a certain value. (And not change the control flow.)
    		}
        
        CyclomaticComplexityValue complexityValue = <m, result>;
        complexityValues += [complexityValue];

        // Question: Can multiple constructors with different arguments be considered as control-flow?
        // Then the "constructorCall" should also be considered in this visit as well.
	}
	
	return complexityValues;
}

public RiskOverview getCyclomaticComplexityRankings(list[Declaration] declMethods) {
    list[CyclomaticComplexityValue] complexityValues = cyclomaticLinesPerPartion(declMethods);

    int lowRisk = 0;
    int moderateRisk = 0;
    int highRisk = 0;
    int veryHighRisk = 0;

    for(complexity <- complexityValues) {
        int complexityValue = complexity.cyclomaticComplexity;
        loc rawMethodLoc = complexity.method.src;
        str rawMethod = readFile(rawMethodLoc);

        int linesOfMethod = getLinesOfCodeAmount(rawMethod);

        if(complexityValue >= 1 && complexityValue <= 10) {
            lowRisk += linesOfMethod;
        } else if(complexityValue >= 11 && complexityValue <= 20) {
            moderateRisk += linesOfMethod;
        } else if(complexityValue >= 21 && complexityValue <= 50) {
            highRisk += linesOfMethod;
        } else {
            veryHighRisk += linesOfMethod;
        }
    }

    return <lowRisk, moderateRisk, highRisk, veryHighRisk>;
}

public int getOverallLinesFromOverview(RiskOverview riskOverview){
    return (riskOverview.low + riskOverview.moderate + riskOverview.high + riskOverview.veryHigh);
}