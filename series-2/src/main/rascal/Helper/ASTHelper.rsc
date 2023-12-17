module Helper::ASTHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import Helper::NodeHelpers;
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
