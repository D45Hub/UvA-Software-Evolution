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