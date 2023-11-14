module Volume::LOCVolumeMetric

import Volume::LOCVolume;

map[str, int] getVolumeMetric(projectModel) {
    str concatenatedProject = getConcatenatedProjectFile(projectModel);

    list[str] allLines = getLOC(concatenatedProject, true);
    list[str] comments = [ comment | comment <- allLines, isLineOneLineComment(comment)];
    list[str] emptyLines = [emptyLine | emptyLine <- allLines, isLineEmpty(emptyLine)];

    map[str, int] volumeMetrics = ("Overall Lines of Code" : size(allLines),
                    "Single Comment Lines of Code":  size(comments),
                    "Empty Lines of Code": size(emptyLines),
                    "Actual Lines of Code": (size(allLines) - size(comments)) - size(curlyBraces) - size(emptyLines));

    return volumeMetrics;
}

