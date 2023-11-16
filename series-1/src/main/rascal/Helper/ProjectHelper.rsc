module Helper::ProjectHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

// Provides all project file contents inside of a single string concatenated together.
str getConcatenatedProjectFile(M3 model) {
    set[loc] sourceFileLocations = files(model);
    return ("" | it + "\n" + readFile(l) | loc l <- sourceFileLocations);
}


list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    return getASTs(model);
}

list[Declaration] getASTs(M3 projectModel) {
    list[Declaration] asts = [createAstFromFile(f, true)
        | f <- files(projectModel.containment), isCompilationUnit(f)];
    return asts;
}

/** 
    A unit in Java consists of methods in any kind.
    This means we include every type of method, which we can visit, as well as constructors.

    Potential Threads to validity:

    - Anonymous Class and Method creation inside of other units. (As well as Lambda Statements...)
    - The Reflection API, especially the method object included in there.
*/ 
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

list[Declaration] getProjectUnits(M3 model) {
    list[Declaration] asts = getASTs(model);
    return getProjectUnits(asts);
}