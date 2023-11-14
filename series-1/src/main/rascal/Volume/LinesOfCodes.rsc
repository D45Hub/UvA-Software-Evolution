module Volume::LinesOfCodes

import Volume::LinesOfCodeHelpers;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import util::FileSystem;
import Set;
import IO;
import String;
import List;

alias KLOC = num;
alias LinesOfCodeStats = map[str,int];
alias LocationsLineOfCodeStats = map[loc,LinesOfCodeStats];

/**
 * Sums up all the lines of code stats for many locations.
 * 
 */
int getLocsForLocations (list[loc] locations){
	list[str] lines = getCodeLinesFromFiles(locations);
	return size(lines);
}

/**e
 * Get lines of code stats for many locations.
 * 
 * Maps the location to a map of LOC statistics:
 * 
 * |java+compilationUnit:///src/../TestClass.java|:("all":28,"code":9,"blank":4,"comments":15),
 * |java+compilationUnit:///src/../TestClass2.java|:("all":28,"code":9,"blank":4,"comments":15)
 */
LocationsLineOfCodeStats getLocStatsForLocations (list[loc] locations){
	LocationsLineOfCodeStats mapping = (); 
	
	for(loc location <- locations){
		str content = readFile(location);
		mapping[location] = getLocStats(content);
	}
	
	return mapping;
}

/**
 * Get lines of code stats for a string of code.
 *
 */
LinesOfCodeStats getLocStats (str code) {
	code = "\n" + code + "\n";
	code = replaceStrings(code);
	
    list[str] allLines = split("\n", code);
    list[str] nonBlankLines = [l | str l <- allLines, !isLineEmpty(l)];
  	list[str] codeLines = split("\n", withoutMultiLineComments(code));
  	codeLines = [l | str l <- codeLines, !isLineEmpty(l) && !isOneLineComment(l)];
  	
  	return ("text": size(allLines),
  			"code": size(codeLines),
  			"blank": size(allLines) - size(nonBlankLines), 
  			"comments": size(nonBlankLines) - size(codeLines)
  			);
}

