module Volume::LOCVolume

import String;
import Configuration;

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

/*
 * Removes all multi line comments from a source code string.
 *
 * After experimenting with multiple regular expressions we decided to use:
 * \/\*[\s\S]*?\*\/
 * (Compare with: https://blog.ostermiller.org/find-comment)
 *
 */
str replaceMultiLineComments(str source) {
    
	return visit(source){
   		case /\/\*[\s\S]*?\*\// => ""  
	};
/**
This not work...
    while (contains(source, "/\\*") && contains(source, "*\\")) {
        int startIndex = indexOf(chars("/\\*"), source);
        int endIndex = indexOf(chars("*\\"), source) + 2;
        source = source[0..startIndex] + source[endIndex..size(source)];
    }
    return source;*/
}

/**
 * Replace strings with "S"
 *
 * Example of a problematic code without this replace string options:
 * System.out.println("Hello wolrd \/*"
 *		+ "asdasd"
 *		+ "asd*\/asdsdasd"
);	"Hello world \/*" --> "Hello world COMMENT_START_TOKEN"
 */
str replaceStringEdgeCase(str source){	
	return visit(source){
   		case /"<match:.*>"/ => "<replaceStringContent(match)>"
	};
}

/**
* replaceStringContent use this construct instead of replacing a string directly with 
* regex since its much faster.
* 
* Slow regex alternative would be: 
* return visit(source){
   		case /"<stringstart:.*><commentstart:\/\*><stringend:.*>"/ => "\"<stringstart><COMMENT_START_TOKEN><stringend>\""
   		case /"<stringstart:.*><commentend:\*\/><stringend:.*>"/ => "\"<stringstart><COMMENT_END_TOKEN><stringend>\""
	};
**/
str replaceStringContent(str stringContent){
	if(contains(stringContent, "/*") || contains(stringContent, "*/")){
		return visit(stringContent){
			case /<stringstart:.*><commentstart:\/\*><stringend:.*>/ => "\"<stringstart><COMMENT_START_TOKEN><stringend>\""
			case /<stringstart:.*><commentend:\*\/><stringend:.*>/ => "\"<stringstart><COMMENT_END_TOKEN><stringend>\""
		}
	}
	
	return stringContent;
}

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

list[str] getLOC(str source) = getLOC(source, CURLY_BRACKETS_ARE_CODE);

list[str] getAllLOC(str source) {
	source = "\n" + source + "\n";
  	list[str] codeLines = split("\n", source);
  	return [trim(l) | str l <- codeLines];

}
list[str] getLOC(str source, bool areCurlyBracketsAreCode){
	source = "\n" + source + "\n";
	source = replaceStringEdgeCase(source);
	source = replaceMultiLineComments(source);
	
  	list[str] codeLines = split("\n", source);
  	return [trim(l) | str l <- codeLines, isLineCodeLine(l, areCurlyBracketsAreCode)];
}
