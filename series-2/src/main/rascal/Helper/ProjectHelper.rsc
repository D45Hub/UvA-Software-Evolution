module Helper::ProjectHelper
import Helper::ASTHelper;


public list [node] prepareProjectForAnalysis(loc project) {
    list[Declaration] projectAST = getASTs(project);
    list[node] projectNodes = getNodesFromAST(projectAST);
    return projectNodes;
}

public bool locationIsValid(loc location){
	return location.scheme != "unresolved"; 
}