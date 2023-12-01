module Helper::OutputHelper

import Helper::Types;
import IO;
import String;

void writeJSONFile(loc outputFileLocation, list[DuplicationResult] results) {
    str jsonContent = "{\"projectResults\": {
    
    \"projectName\": \"test\", 
    \"projectLOC\": \"test\", 
    \"duplicatedLines\": \"test\", 
    \"duplicatedLinePercentage\": \"test\", 
    \"numberOfCloneClasses\": \"test\", 
    \"biggestCloneLocation\": \"test\", 
    \"biggestCloneLOC\": \"test\", 
    \"biggestCloneClass\": \"test\", 

    \"clonePairs\": 
     [";

    for(duplicationResult <- results) {
        jsonContent += getJSONContentOfResult(duplicationResult);
    }

    jsonContent = jsonContent[0..(size(jsonContent) - 1)];
    jsonContent += "]}}";
    writeFile(outputFileLocation, jsonContent);
}

str getJSONContentOfResult(DuplicationResult duplicationResult) {
    str content = "{\"duplication\": [";

    content += getJSONContentOfLocation(duplicationResult[0]);
    content += "<getJSONContentOfLocation(duplicationResult[1])>";

    content = content[0..(size(content) - 1)];

    content += "]},";

    return content;
}

str getJSONContentOfLocation(DuplicationLocation duplicationLocation) {
    str content = "{";

    content += "\"filePath\": \"<duplicationLocation.filePath>\",";
    content += "\"methodName\": \"<duplicationLocation.methodName>\",";
    content += "\"startLine\": <duplicationLocation.startLine>,";
    content += "\"endLine\": <duplicationLocation.endLine>,";
    content += "\"cloneType\": \"<duplicationLocation.cloneType>\"},";

    return content;
}