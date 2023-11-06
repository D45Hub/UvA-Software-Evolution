module GeneralHelper::ProjectHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

str getConcatenatedProjectFile(M3 model) {
    set[loc] sourceFileLocations = files(model);
    return ("" | it + "\n" + readFile(l) | loc l <- sourceFileLocations);
}

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

list[Declaration] getProjectUnits(list[Declaration] declMethods) {

    list[Declaration] projectUnits = [];

    for(m <- declMethods) {
        visit(m) {
            case \method(_,_,_,_) : projectUnits += [m];
            case \method(_,_,_,_,_) : projectUnits += [m];
            case \constructor(_,_,_,_) : projectUnits += [m];
        }
    }

    return projectUnits;
}