module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import NodeHelpers::NodeHelpers;
import TreeComparison::SubtreeComparator;

int main(int testArgument=0) {
    M3 model = createM3FromMavenProject(|file:///loc/|);
    list[Declaration] asts = [createAstFromFile(f, true)
        | f <- files(model.containment), isCompilationUnit(f)];
    list[ClonePair] subtree = getSubtreeClonePairs(asts, 3, 50.0);
    println(subtree);
    println("argument: <testArgument>");
    return testArgument;
}
