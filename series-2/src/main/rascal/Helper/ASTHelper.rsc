module Helper::ASTHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import Prelude;

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    return getASTs(model);
}

list[Declaration] getASTs(M3 projectModel) {
    list[Declaration] asts = [createAstFromFile(f, true)
        | f <- files(projectModel.containment), isCompilationUnit(f)];
    return asts;
}

/* Ignoring the fact that we need a mass threshold for now and ignore leaves parameter*/ 
list[node] getNodesFromAST(list[Declaration] astToParse, int massThreshold) {
    list[node] visitedNodes = [];
    bottom-up visit (astToParse) {
        case node n : {
            if(size(getChildren(n)) >= massThreshold) {
                visitedNodes  += n;
            }
        }
        
    }
    println("visitednodes <visitedNodes>");
    println("size of nodes <size(visitedNodes)>");
    return visitedNodes;
}