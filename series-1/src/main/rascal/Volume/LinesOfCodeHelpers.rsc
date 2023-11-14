module Volume::LinesOfCodeHelpers

import String;
import IO;
import Configuration;
import List;

bool isOneLineComment(str line) {
	return /^(\s*\/\/)/ := line;
}

bool isLineEmpty(str line) {
	return /^\s*$/ := line;
}

bool isCurlyBracket(str line){
	return trim(line) == "{" || trim(line) == "}";
}

/*
 * Removes all multi line comments from a source code string.
 *
 * After experimenting with multiple regular expressions we decided to use:
 * \/\*[\s\S]*?\*\/
 * (Compare with: https://blog.ostermiller.org/find-comment)
 *
 */
str withoutMultiLineComments(str source){
	return visit(source){
   		case /\/\*[\s\S]*?\*\// => ""  
	};
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
str replaceStrings(str source){	
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

bool isCodeLine(str line, bool curlyBracketsAreCode){
	if(isLineEmpty(line)){
		return false;
	}
	
	if(isOneLineComment(line)){
		return false;
	}
	
	if(curlyBracketsAreCode == false && isCurlyBracket(line)){
		return false;
	}
	
	return true;
}

list[str] getCodeLines(str source) = getCodeLines(source, CURLY_BRACKETS_ARE_CODE);

list[str] getCodeLines(str source, bool curlyBracketsAreCode){
	source = "\n" + source + "\n";
	source = replaceStrings(source);
	source = withoutMultiLineComments(source);
	
  	list[str] codeLines = split("\n", source);
  	return [trim(l) | str l <- codeLines, isCodeLine(l, curlyBracketsAreCode)];
}

map[str,list[int]] getLinesMapping(list[str] lines){	
	map[str,list[int]] linesMapping = ();
	int i = 0;
	
	while(i < size(lines)){
		str l = lines[i];
		
		if(l in linesMapping == false){
			linesMapping[l] = [];
		}
		
		linesMapping[l] = linesMapping[l] + [i];
		i += 1;
	}
	
	return linesMapping;
}