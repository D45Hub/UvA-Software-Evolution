module Helper::ProjectHelper
import Helper::ASTHelper;

import lang::java::m3::Core;
import lang::java::m3::AST;

import Helper::Types;
import Helper::LOCHelper;
import Configuration;
import Prelude;
import Location;

// Provides all project file contents inside of a single string concatenated together.
str getConcatenatedProjectFile(M3 model) {
    set[loc] sourceFileLocations = files(model);
    return ("" | it + "\n" + readFile(l) | loc l <- sourceFileLocations);
}

map[loc fileLoc, MethodLoc method] getMethodLocs(M3 model) {
    methodObjects = methods(model);
    map[loc fileLoc, MethodLoc method] mapLocs = ();
    
    for(m <- methodObjects) {
        decl = getFirstFrom(model.declarations[m]);
        int beginDecl = decl.begin.line;
        int endDecl = decl.end.line;

        if(endDecl - beginDecl >= MASS_THRESHOLD) {
            int methodLoc = size(getLOC(readFile(m)));
            mapLocs += (decl: <m, methodLoc>);
        }   
    }
    return mapLocs;
}