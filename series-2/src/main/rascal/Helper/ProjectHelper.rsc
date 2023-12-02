module Helper::ProjectHelper
import Helper::ASTHelper;

import lang::java::m3::Core;
import lang::java::m3::AST;


public list [node] prepareProjectForAnalysis(loc project) {
    list[Declaration] projectAST = getASTs(project);
    return prepareASTNodesForAnalysis(projectAST);
}

public list [node] prepareProjectForAnalysis(list[Declaration] projectAST) {
    list[node] projectNodes = getNodesFromAST(projectAST);
    return projectNodes;
}

public bool locationIsValid(loc location){
	return location.scheme != "unresolved"; 
}

// Provides all project file contents inside of a single string concatenated together.
str getConcatenatedProjectFile(M3 model) {
    set[loc] sourceFileLocations = files(model);
    return ("" | it + "\n" + readFile(l) | loc l <- sourceFileLocations);
}