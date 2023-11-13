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

alias RemovedMultiLineComments = tuple[str filteredSourceCode, int amountCommentsRemoved];

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

str removeMultiLineComments(str rawSourceCode){
	return visit(rawSourceCode){
   		case /\/\*[\s\S]*?\*\// => ""  
	};
}

RemovedMultiLineComments removeMultiLineCommentsWithAmountTrack(str rawSourceCode){

    // This does not work... We need to filter out the multi lines while also keeping track of the amount of multi line comments removed.
    int removedMultiLineComments = 0;
	str filteredSourceCode = visit(rawSourceCode){
   		case x:/\/\*[\s\S]*?\*\//: {x = ""; removedMultiLineComments += 1;}
	};

    return <filteredSourceCode, removedMultiLineComments>;
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