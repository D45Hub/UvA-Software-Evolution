module Helper::ProjectHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

// Provides all project file contents inside of a single string concatenated together.
str getConcatenatedProjectFile(M3 model) {
    set[loc] sourceFileLocations = files(model);
    return ("" | it + "\n" + readFile(l) | loc l <- sourceFileLocations);
}

