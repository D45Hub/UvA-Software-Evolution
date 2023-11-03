module MetricsHelper::LOCHelper

import String;
import List;

bool isCurlyBracketLine(str rawCodeLine) {
    return /^\s*\{\s*$/ := rawCodeLine || /^\s*\}\s*$/ := rawCodeLine;
}

bool isEmptyLine(str rawCodeLine) {
    return /^\s*$/ := rawCodeLine;
}

bool isSingleLineComment(str rawCodeLine) {
    return /^(\s*\/\/)/ := rawCodeLine;
}

bool isRemovableCodeLine(str rawCodeLine) {
    return isCurlyBracketLine(rawCodeLine) || isEmptyLine(rawCodeLine) || isSingleLineComment(rawCodeLine);
}

str removeMultiLineComments(str rawSourceCode){
	return visit(rawSourceCode){
   		case /\/\*[\s\S]*?\*\// => ""  
	};
}

list[str] getLinesOfCode(str rawSourceCode) {

    str codeWithoutMultiLineComments = removeMultiLineComments(rawSourceCode);
    list[str] splitCodeLines = split("\n", rawSourceCode);

    return [trim(line) | str line <- splitCodeLines, !isRemovableCodeLine(line)];
}

int getLinesOfCodeAmount(str rawSourceCode) {
    return size(getLinesOfCode(rawSourceCode));
}