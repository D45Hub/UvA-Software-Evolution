module MetricsHelper::DuplicationHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import Node;

/**

    Write down the whole approach with hash comparison algorithm...

*/

/**

    Elaborate more into different duplication types.
    And language specific differences in sensibility of this metric and its evalution. I.e. Haskell.

*/

list[node] getDuplicateMatches(AST ast1, AST ast2) {

    list[node] duplicateNodes = [];

    top-down-break visit(ast2) {
    case leaf(int n) => {
        if (n in ast1) {
            duplicateNodes += [n];
        }
    }
}

    /**
    top-down-break visit(ast2) {
        case leaf(int n) := ast1 : duplicateNodes += [n];
    }
    */

    return duplicateNodes;
}


list[node] filterNodesByDuplicationSize(list[node] nodeList) {
    return [n | n <- nodeList, hasNExperssionSubnodes(n, 6)];
}


list[node] hasNExperssionSubnodes(node mainNode, int amount) {
    list[node] nodeChildren = getChildren(mainNode);
    
    int nodeExpressionAmount = 0;

    for (node child <- nodeChildren) {
        if(\expression := child) {
            nodeExpressionAmount += 1;
        }
    }

    return (nodeExpressionAmount >= amount);
} 
