module Helper::LOCHelper

import String;
import Configuration;

// Filtering functions for the different types of irrelevant lines of code.

bool isLineOneLineComment(str rawLine) {
	str trimmedLine = trim(rawLine);
    return startsWith(trimmedLine, "//");
}

bool isLineEmpty(str rawLine) {
	return isEmpty(trim(rawLine));
}

bool isLineCurlyBracket(str rawLine){
	str trimmedLine = trim(rawLine);
	return trimmedLine == "{" || trimmedLine == "}";
}

/** 
	We prune the initial raw source code from multi-line comments first.
	This is due to the fact that we could include all other possible comment or non comment patterns
	inside multi-line comments. So therefore we need to remove them to do further analysis.

	We use regex to filter multi-line comments out, since this proved to be the (for us) 
	easiest and most intuitive method.

	This doesn't allow us to track the amount of multi-line comments though. 

 	(Reference: https://blog.ostermiller.org/find-comment)
 
 */
str pruneMultiLineComments(str source) {
    
	return visit(source){
   		case /\/\*[\s\S]*?\*\// => ""  
	};

/**
	Alternative non-regex based approach, we couldn't get to work.
	This would allow us to track the amount of multi-line comments though,
	with tracking the amount of loop iterations.

    while (contains(source, "/\\*") && contains(source, "*\\")) {
        int startIndex = indexOf(chars("/\\*"), source);
        int endIndex = indexOf(chars("*\\"), source) + 2;
        source = source[0..startIndex] + source[endIndex..size(source)];
    }
    return source;*/
}

/**
	Replace strings with "S", to remove problematic scenarios with multi-line string concatenation
	and (multi-line) comment inclusion.

	Example:

	System.out.println("Hello you \/*"
		+ "blablabla"
		+ "bla*\/ye"
	);	

	This gets replaced with:
	"Hello world \/*" --> "Hello world COMMENT_START_TOKEN"
 */
str replaceMultiLineStringComments(str source){	
	return visit(source){
   		case /"<match:.*>"/ => "<replaceStringTokenContent(match)>"
	};
}

/**
	We replace the corresponding edge-case with a specialized comment token.
	With this token, we can then normally go through the rest of our "empty line" pruning.
 
	Slower regex-based alternative could be: 
	
 	return visit(source){
   		case /"<stringstart:.*><commentstart:\/\*><stringend:.*>"/ => "\"<stringstart><COMMENT_START_TOKEN><stringend>\""
   		case /"<stringstart:.*><commentend:\*\/><stringend:.*>"/ => "\"<stringstart><COMMENT_END_TOKEN><stringend>\""
	};

*/
str replaceStringTokenContent(str stringContent){
	if(contains(stringContent, "/*") || contains(stringContent, "*/")){
		return visit(stringContent){
			case /<stringstart:.*><commentstart:\/\*><stringend:.*>/ => "\"<stringstart><COMMENT_START_TOKEN><stringend>\""
			case /<stringstart:.*><commentend:\*\/><stringend:.*>/ => "\"<stringstart><COMMENT_END_TOKEN><stringend>\""
		}
	}
	
	return stringContent;
}

// Line filtering.
bool isLineCodeLine(str line, bool areCurlyBracketsAreCode){
	if(isLineEmpty(line)){
		return false;
	}
	
	if(isLineOneLineComment(line)){
		return false;
	}
	
	if(areCurlyBracketsAreCode == false && isLineCurlyBracket(line)){
		return false;
	}
	
	return true;
}

// Functions to calculate the amount of code lines.
// With the corresponding distinctions, whether singular curly brackets can be considered as LOC.
list[str] getLOC(str source) = getLOC(source, CURLY_BRACKETS_ARE_CODE);

list[str] getAllLOC(str source) {
	source = "\n" + source + "\n";
  	list[str] codeLines = split("\n", source);
  	return [trim(l) | str l <- codeLines];

}
list[str] getLOC(str source, bool areCurlyBracketsAreCode){
	source = "\n" + source + "\n";
	//source = replaceMultiLineStringComments(source);
	//source = pruneMultiLineComments(source);
	
  	list[str] codeLines = split("\n", source);
  	return [trim(l) | str l <- codeLines, isLineCodeLine(l, areCurlyBracketsAreCode)];
}
