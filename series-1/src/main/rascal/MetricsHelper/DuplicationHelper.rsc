module MetricsHelper::DuplicationHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import MetricsHelper::LOCHelper;

import IO;

import String;
import util::Math;
import Ranking::Ranking;

import List;

alias Size = int;
alias DuplicationRanking =  tuple[Ranking rankingType,
                                Size minDuplicationOfUnit,
                                Size maxDuplicationOfUnit];


DuplicationRanking excellentDuplicationRanking = <excellent, 0, 3>;
DuplicationRanking goodDuplicationRanking = <good, 3, 5>;
DuplicationRanking neutralDuplicationRanking = <neutral, 5, 10>;
DuplicationRanking negativeDuplicationRanking = <negative, 10, 20>;
DuplicationRanking veryNegativeDuplicationRanking = <veryNegative, 20, 100>;

list[DuplicationRanking] allDuplicationRankings = [excellentDuplicationRanking,
                                            goodDuplicationRanking,
                                            neutralDuplicationRanking,
                                            negativeDuplicationRanking,
                                            veryNegativeDuplicationRanking];


/**

    Write down the whole approach with hash comparison algorithm...

*/

/**

    Elaborate more into different duplication types.
    And language specific differences in sensibility of this metric and its evalution. I.e. Haskell.

*/

/**
list[node] getDuplicateMatches(AST ast1, AST ast2) {

    list[node] duplicateNodes = [];

    top-down-break visit(ast2) {
    case leaf(int n) => {
        if (n in ast1) {
            duplicateNodes += [n];
        }
    }
}

    top-down-break visit(ast2) {
        case leaf(int n) := ast1 : duplicateNodes += [n];
    }

    return duplicateNodes;
}


list[node] filterNodesByDuplicationSize(list[node] nodeList) {
    return [n | n <- nodeList, hasNExperssionSubnodes(n, 6)];
}


list[node] hasNExperssionSubnodes(node mainNode, int amount) {
    list[node] nodeChildren = getChildren(mainNode);
    
    int nodeExpressionAmount = 0;

    for (node child <- nodeChildren) {
        if(\expression := child) {
            nodeExpressionAmount += 1;
        }
    }

    return (nodeExpressionAmount >= amount);
} 
*/

str genStringHashCode(str input) {
    int hashCode = 7;
    list[int] inputCharacters = chars(input);

    for(character <- inputCharacters) {
        hashCode = hashCode*31 + character;
    }

    return toString(hashCode);
}


// With this it could happen that say a 3 line code block from the end of one unit and a 3 line block from the beginning of another unit could form a false duplication block with a "real" block somewhere else.
// This case is so improbable though, that we decided to omit it to preserve relative simplicity. 
list[str] getListOfHashes(M3 projectModel) {

    list[str] hashCodeLines = [];

    classMethods = methods(projectModel);
    classConstructors = constructors(projectModel);

    for(method <- classMethods) {

        str rawMethod = readFile(method);
        list[str] splitCodeLines = (split("\n", rawMethod))[1..];

        list[str] filteredLinesOfCode = getLinesOfCode(splitCodeLines);

        /**
        if(size(filteredLinesOfCode) < 6) {
            continue;
        }
        */

        for (methodLine <- filteredLinesOfCode) {
            hashCodeLines += [(methodLine)];
        }

        //println(hashCodeLines);
    }

    for(constructor <- classConstructors) {

        str rawConstructor = readFile(constructor);
        list[str] splitConstructorLines = (split("\n", rawConstructor))[1..];

        list[str] filteredLinesOfCodeConstructors = getLinesOfCode(splitConstructorLines);

        /*if(size(filteredLinesOfCodeConstructors) < 6) {
            continue;
        }*/

        for (constructorLine <- filteredLinesOfCodeConstructors) {
            hashCodeLines += [(constructorLine)];
        }
    }

    return hashCodeLines;
}



map[str, int] getDuplicatesOfProgram (list[str] linesOfCode) {
    i = 0;
    map[str,int] duplicatedFragments = ();

    while (i < size(linesOfCode) && (i+5) < size(linesOfCode)) {
        listForHashing = linesOfCode[i..i+5];
        hash = genStringHashCode(toString(listForHashing))[1..50];
        if (hash in duplicatedFragments) {
            duplicatedFragments[hash] = duplicatedFragments[hash] + 1;
        } else {
            duplicatedFragments[hash] = 1;
        }
        i = i + 1;
    }

    return (duplicate : duplicatedFragments[duplicate] | duplicate <- duplicatedFragments, duplicatedFragments[duplicate] > 1);
}



// TODO REFACTOR... This is shit.
list[list[str]] generateHashWindows(list[str] hashCodeLines) {

    list[list[str]] hashCodeWindows = [];
    int index = 0;
    int i = 0;
    int windowIndex = 0;
    int hashCodeLinesAmount = size(hashCodeLines);
    int maxWindowChunks = hashCodeLinesAmount / 6;

    while(i < 6) {

        while(windowIndex < maxWindowChunks){
            println("Window Index: " + toString(windowIndex));
            list[str] hashWindow = [];
            while(index < 6) {
                int hashCodeIndex = (windowIndex * 6 + index + i);

                if (hashCodeIndex < hashCodeLinesAmount){
                    str hash = hashCodeLines[hashCodeIndex];
                    hashWindow += [hash];
                }
                index += 1;
            }

            windowIndex += 1;
            index = 0;

            if(size(hashWindow) == 6) {
                hashCodeWindows += [hashWindow];
            }
        }

        i += 1;
        windowIndex = 0;
        index = 0;
    }


    return hashCodeWindows;
}

int getAmountOfDuplicates(list[list[str]] hashWindows) {

    int duplicateAmount = 0;

    for(hashWindow <- hashWindows) {

        hashWindows = hashWindows - [hashWindow];

        while(hashWindow in hashWindows) {
            hashWindows = hashWindows - [hashWindow];
            duplicateAmount += 1;
        }
    }

    return duplicateAmount;
}

DuplicationRanking getDuplicationRanking(M3 projectModel, int linesOfCode) {
    list[str] listOfHashes = getListOfHashes(projectModel);
    map[str, int] duplicationMap = getDuplicatesOfProgram(listOfHashes);
    int amountOfDuplicates = 0;

    for(duplEntry <- duplicationMap) {
        amountOfDuplicates += duplicationMap[duplEntry];
    }

    // It is okay to round down, since in any case the rating wouldn't be influenced anyways, if we were to use the float value.
    int percentageOfDuplication = ((amountOfDuplicates * 6) / linesOfCode) * 100;
    getDuplicationRanking(percentageOfDuplication);
}

public DuplicationRanking getDuplicationRanking(int duplicationPercentage){
    DuplicationRanking resultRanking =  [ranking | ranking <- allDuplicationRankings,
                                (duplicationPercentage < ranking.maxDuplicationOfUnit
                                || ranking.maxDuplicationOfUnit == -1)][0];
    return resultRanking;
}

public void formatDuplicationRanking(M3 projectModel, int linesOfCode) {
    DuplicationRanking ranking = getDuplicationRanking(projectModel, linesOfCode);
    println(ranking);
}