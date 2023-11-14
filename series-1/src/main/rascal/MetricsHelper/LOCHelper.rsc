module MetricsHelper::LOCHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import GeneralHelper::ProjectHelper;

import String;
import List;
import IO;

/**

    Currently not implemented but kept in mind:

        - How are import statements counted towards LOC metric? 
        You could just insert the whole library into the source code.
        Or you could do multiple import statements VS a wildcard one. I.e. import Math.Add; import Math.Subtract; -> import Math.*
        Is an import even really a functional LOC?

        - How should the "package" statement be counted towards the LOC metric?
        Is it really a functional line of code or just "syntactic sugar" to make the file work?

        - Is an annotation a LOC? If so, how should multi-line annotations be handled? As one line? Or multiple ones?

        - How should labelled statements be handled, especially with the label declaration?

        - How should shorthand notations or multi-line string concatenations be handled?
        Should everything be in it's shortest form possible?

        Example: 
        MyObj myObj = null;
            if (a != null) {
            myObj = a.myObj;
        }

        Should this be 1 LOC because you could write it as... MyObj myObj = a?.myObj;

        Or this:

        System.out.println("Hello" 
                            + "World");

        -> System.out.println("HelloWorld");

        - When we look at LOC of a certain method unit. 
        Should abstract local object implementations (or local classes) be counted towards the method or of that unit itself?

        - How should Java JNI usage be counted towards this, since you can have C-Code be executed from Java code natively?
        This then opens up the entire rabbithole of, cross programming language specifics and specialized features from other languages.

        - Should, say a JSON file be counted towards this metric, since it could have an effect on the control flow, due to reflection.

*/

// This regex also checks for cases such as e.g. System.out.println("{}") 
bool isCurlyBracketLine(str rawCodeLine) {
    str trimmedLine = trim(rawCodeLine);
    return trimmedLine == "{" || trimmedLine == "}";
}

bool isEmptyLine(str rawCodeLine) {
    str trimmedLine = trim(rawCodeLine);
    return isEmpty(trimmedLine);
}

// This regex also checks for cases such as e.g. System.out.println("//") or System.out.println("/* */")
bool isSingleLineComment(str rawCodeLine) {
    str trimmedLine = trim(rawCodeLine);
    return startsWith(trimmedLine, "//");
}

bool isRemovableCodeLine(str rawCodeLine) {
    return isCurlyBracketLine(rawCodeLine) || isEmptyLine(rawCodeLine) || isSingleLineComment(rawCodeLine);
}

bool isCommentLine (str rawCodeLine) {
    return startsWith("//", rawCodeLine) || startsWith("/**", rawCodeLine) ||
    endsWith("*/", rawCodeLine) ||  startsWith("*", rawCodeLine);
}

str removeMultiLineComments(str rawSourceCode){
	return visit(rawSourceCode){
   		case /\/\*[\s\S]*?\*\// => ""  
	};
}

list[str] getAllCodeLines(list[str] rawSourceCodeLines) {
    println(size(rawSourceCodeLines));
    return rawSourceCodeLines;
}

list[str] getLinesOfComments(list[str] rawSourceCodeLines) {
    return [line | str line <- rawSourceCodeLines, isCommentLine(line)];
}

list[str] getLinesOfCurlyBraces(list[str] rawSourceCodeLines) {
    return [line | str line <- rawSourceCodeLines, (startsWith(line, "{") || endsWith(line, "}")) ];
}

list[str] getEmptyLines(list[str] rawSourceCodeLines) {
    return [line| str line <- rawSourceCodeLines, isEmpty(line)];
}

map[str, int] getVolumeMetric(projectModel) {
    str concatenatedProject = getConcatenatedProjectFile(projectModel);
    list[str] splitLine = split("\n",concatenatedProject );
    list[str] trimmedCodeLines = [trim(line) | line <- splitLine]; 


    allLines = getAllCodeLines(trimmedCodeLines);
    comments = getLinesOfComments(trimmedCodeLines);
    curlyBraces = getLinesOfCurlyBraces(trimmedCodeLines);
    emptyLines = getEmptyLines(trimmedCodeLines);

    map[str, int] volumeMetrics = ("Overall Lines of Code" : size(allLines),
                    "Comment Lines of Code":  size(comments),
                    "Curly Braces Lines of Code" : size(curlyBraces),
                    "Empty Lines of Code": size(emptyLines),
                    "Actual Lines of Code": (size(allLines) - size(comments)) - size(curlyBraces) - size(emptyLines));

    return volumeMetrics;
}

int getAmountOfCodeLines(list[str] codeLines) {
    return size(codeLines);
}



list[str] getLinesOfCode(list[str] rawSourceCodeLines) {
    str codeWithoutMultiLineComments1 = removeMultiLineComments(toString(rawSourceCodeLines));
    list[str] splitCodeLines1 = split("\n", codeWithoutMultiLineComments1);

    return [trim(line) | str line <- splitCodeLines1, !isRemovableCodeLine(line)];
}

list[str] getLinesOfCode(str rawSourceCode) {

    str codeWithoutMultiLineComments = removeMultiLineComments(rawSourceCode);
    list[str] splitCodeLines = split("\n", rawSourceCode);

    return [trim(line) | str line <- splitCodeLines, !isRemovableCodeLine(line)];
}

list[str] getLinesOfCode(M3 projectModel) {
    str concatenatedProject = getConcatenatedProjectFile(projectModel);
    return getLinesOfCode(concatenatedProject);
}

int getLinesOfCodeAmount(str rawSourceCode) {
    return size(getLinesOfCode(rawSourceCode));
}

int getLinesOfCodeAmount(M3 projectModel) {
    str concatenatedProject = getConcatenatedProjectFile(projectModel);
    return getLinesOfCodeAmount(concatenatedProject);
}
