module Main

import lang::java::m3::Core;
import MetricsHelper::LOCHelper;
import Volume::ManYears;

int main(int testArgument=0) {

    M3 model = createM3FromMavenProject(|file:///C:/SomeFilePath|);
    int linesOfCode = getLinesOfCodeAmount(model);
    MYRanking manYearRanking = getManYearsRanking(linesOfCode);

    formatRanking(linesOfCode);
    return testArgument;
}
