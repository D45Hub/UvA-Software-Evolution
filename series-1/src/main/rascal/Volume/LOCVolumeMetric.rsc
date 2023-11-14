module Volume::LOCVolumeMetric

import Volume::LOCVolume;
import Helper::ProjectHelper;

import List;
import String;

map[str, int] getVolumeMetric(projectModel) {
    str concatenatedProject = getConcatenatedProjectFile(projectModel);

    list[str] overAllLines = split("\n", concatenatedProject);
    list[str] codeLines = getLOC(concatenatedProject, true);
    list[str] nonBlankLines = [l | str l <- overAllLines, !isLineEmpty(l)];

    map[str, int] volumeMetrics = (
                    "Overall lines" : size(overAllLines),
                    "Actual Lines of Code" : size(codeLines),
                    "Blank lines":  size(overAllLines) - size(nonBlankLines),
                    "Comment Lines of Code":  size(nonBlankLines) - size(codeLines));

    return volumeMetrics;
}

