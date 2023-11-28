module Helper::ASTHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import Helper::NodeHelper;
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
list[node] getNodesFromAST(list[Declaration] astDeclarations) {
    list[node] nodeList = [];

	for(dec <- astDeclarations) {
		nodeList += nodeToNodeList(dec);
	}
	return nodeList;
}

public list[node] nodeToNodeList(node iNode) {
	list[node] nodeList = [];
	visit (iNode) {
		case node x: {
			nodeList += x;
		}
	}

	return nodeList;
}
/* Ignoring the fact that we need a mass threshold for now and ignore leaves parameter*/ 
list[node] getNodesFromAST(node rootNode, int massThreshold) {
    list[node] visitedNodes = [];
    bottom-up visit (rootNode) {
        case node n : {
            if(size(getChildren(n)) >= massThreshold) {
                visitedNodes  += n;
            }
        }
        
    }
    return visitedNodes;
}