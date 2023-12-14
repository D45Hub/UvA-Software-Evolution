module Helper::OutputHelper

import Helper::Types;
import IO;
import String;
import util::Math;
import List;

void writeJSONFile(loc outputFileLocation,
                list[DuplicationResult] results,
                str projectName,
                int projectLOC,
                int duplicatedLines,
                int cloneClassesAmount,
                DuplicationResult biggestCloneClass,
                int massThreshold,
                real similarityThreshold) {
    real duplicatedLinePercentage = getDuplicationPercentage(projectLOC, duplicatedLines);
    int biggestCloneClassLOC = getLargestCloneClassLOC(biggestCloneClass);

    str jsonContent = "{
    
    \"projectName\": \"<projectName>\", 
    \"projectLOC\": <projectLOC>, 
    \"duplicatedLines\": <duplicatedLines>, 
    \"duplicatedLinePercentage\": <duplicatedLinePercentage>, 
    \"numberOfCloneClasses\": <cloneClassesAmount>, 
    \"biggestCloneLOC\": <biggestCloneClassLOC>, 
    \"biggestCloneClass\": <size(biggestCloneClass)>, 
    \"massThreshold\": <massThreshold>,
    \"similarityThreshold\": <similarityThreshold * 100.0>,

    \"clonePairs\": 
     [";

    for(duplicationResult <- results) {
        jsonContent += getJSONContentOfResult(duplicationResult);
    }

    jsonContent = jsonContent[0..(size(jsonContent) - 1)];
    jsonContent += "]}";
    
    writeFile(outputFileLocation, jsonContent);
}

str getJSONContentOfResult(DuplicationResult duplicationResult) {
    str content = "[";

    for(DuplicationLocation duplicationLocation <- duplicationResult) {
        content += getJSONContentOfLocation(duplicationLocation);
    }

    content = content[0..(size(content) - 1)];

    content += "],";

    return content;
}

str getJSONContentOfLocation(DuplicationLocation duplicationLocation) {
    str content = "{";

    content += "\"id\": \"<duplicationLocation.uuid>\",";
    content += "\"filePath\": \"<duplicationLocation.filePath>\",";
    content += "\"methodName\": \"<duplicationLocation.methodName>\",";
    content += "\"methodLOC\": <duplicationLocation.methodLoc>,";
    content += "\"startLine\": <duplicationLocation.startLine>,";
    content += "\"endLine\": <duplicationLocation.endLine>,";
    content += "\"base64Content\": \"<duplicationLocation.base64Content>\"},";

    return content;
}

void writeMarkdownResult(loc outputFileLocation,
                list[DuplicationResult] results,
                str projectName,
                int projectLOC,
                int duplicatedLines,
                int cloneClassesAmount,
                DuplicationResult biggestCloneClass,
                int massThreshold,
                real similarityThreshold) {

    real duplicatedLinePercentage = getDuplicationPercentage(projectLOC, duplicatedLines);
    int biggestCloneClassLOC = getLargestCloneClassLOC(biggestCloneClass);

    str outputMarkdown = "# Report for: \"<projectName>\"

|                                     | Value                         |
|-------------------------------------|-------------------------------|
| Project Lines of Code               | <projectLOC>                  |
| Duplicated Lines (in blocks)        | <duplicatedLines>             |
| Duplicated Line Percentage          | <duplicatedLinePercentage>    |
| Number of Clone Classes             | <cloneClassesAmount>          |
| Biggest Clone Class                 | <size(biggestCloneClass)>     |
| Lines of Code (Biggest Clone Class) | <biggestCloneClassLOC>        |
| Mass Threshold                      | <massThreshold>               |
| Similarity Threshold                | <similarityThreshold * 100.0> |\n\n";

    map[str fileName, list[DuplicationLocation] locations] filteredDuplicationResults = ();

    for(DuplicationResult res <- results) {
        for(DuplicationLocation l <- res) {
            filteredDuplicationResults[l.filePath]?[] += [l];
        }
    }

    outputMarkdown = insertFileTables(filteredDuplicationResults, outputMarkdown);

    writeFile(outputFileLocation, outputMarkdown);
}

str insertFileTables(map[str fileName, list[DuplicationLocation] locations] filteredDuplicationResults, str outputMarkdown) {
    str locationFileTableHeader = getLocationTableHeader(); 

    int locationIndex = 1;
    for(str locationFileName <- filteredDuplicationResults) {
        str locationFileHeading = "# Clones from \"<locationFileName>\"\n";
        
        outputMarkdown += locationFileHeading;
        outputMarkdown += locationFileTableHeader;

        for(DuplicationLocation l <- filteredDuplicationResults[locationFileName]) {
            outputMarkdown += getLocTableLine(locationIndex, l);
            locationIndex += 1;
        }
        locationIndex = 1;
        outputMarkdown += "\n";
    }

    return outputMarkdown;
}

str getLocTableLine(int locationIndex, DuplicationLocation duplicationLocation) {
    return "| <locationIndex> | <duplicationLocation.filePath> | <duplicationLocation.methodName> | <duplicationLocation.startLine> | <duplicationLocation.endLine> | \n";
}

str getLocationTableHeader() {
    str locationFileTableHeader = "|                 | File path                      | Method name                      | Clone start line                | Clone end line                |
|-----------------|--------------------------------|----------------------------------|---------------------------------|-------------------------------| \n";
    return locationFileTableHeader;
}

real getDuplicationPercentage(int projectLOC, int duplicatedLines) {
    return toReal(toReal(duplicatedLines) / toReal(projectLOC)) * 100.0;
}

int getLargestCloneClassLOC(DuplicationResult biggestCloneClass) {
    // Doesn't matter from which we base our LOC generation from.
    DuplicationLocation biggestCloneClassLocation = <"", "", "", "", 0, 0, 0, "">;
    
    if(biggestCloneClass != []) {
        biggestCloneClassLocation = biggestCloneClass[0];
    }
    int biggestCloneClassLOC = biggestCloneClassLocation.endLine - biggestCloneClassLocation.startLine;
    return biggestCloneClassLOC;
}