module GeneralHelper::ProjectHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

str getConcatenatedProjectFile(M3 model) {
    set[loc] sourceFileLocations = files(model);
    return ("" | it + "\n" + readFile(l) | loc l <- sourceFileLocations);
}