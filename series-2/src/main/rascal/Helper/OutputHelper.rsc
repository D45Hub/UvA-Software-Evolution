module Helper::OutputHelper

import Helper::Types;
import IO;
import String;
import util::Math;
import List;

void writeJSONFile(loc outputFileLocation, list[DuplicationResult] results, str projectName, int projectLOC, int duplicatedLines, int cloneClassesAmount, DuplicationResult biggestCloneClass, int massThreshold, real similarityThreshold) {
    real duplicatedLinePercentage = toReal(toReal(duplicatedLines) / toReal(projectLOC)) * 100.0;

    // Doesn't matter from which we base our LOC generation from.
    DuplicationLocation biggestCloneClassLocation = biggestCloneClass[0];
    int biggestCloneClassLOC = biggestCloneClassLocation.endLine - biggestCloneClassLocation.startLine;

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