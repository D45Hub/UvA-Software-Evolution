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
        list[str] splitCodeLines = split("\n", rawMethod); // first line is omitted bv. function declaration
        list[str] trimmedCodeLines = [ trim(codeLine) | codeLine <- splitCodeLines];
        list[str] filteredLinesOfCode = [codeLine | codeLine <- trimmedCodeLines , !startsWith(codeLine, "//")
                                                                            && !startsWith(codeLine, "/*")
                                                                            && !startsWith(codeLine, "/**")
                                                                            && !startsWith(codeLine,"*")
                                                                            && !endsWith(codeLine, "*/") ];

        /** According to the current definition there is no point in comparing methods with less than 6 l ines of code,
        so we skip it.  */ 
        if(size(filteredLinesOfCode) < 6) {
            continue;
        }
        
        for (methodLine <- filteredLinesOfCode) {
            hashCodeLines += [(methodLine)];
        }
    }

    // for(constructor <- classConstructors) {

    //     str rawConstructor = readFile(constructor);
    //     list[str] splitConstructorLines = (split("\n", rawConstructor))[1..];

    //     list[str] filteredLinesOfCodeConstructors = getLinesOfCode(splitConstructorLines);

    //     /*if(size(filteredLinesOfCodeConstructors) < 6) {
    //         continue;
    //     }*/

    //     for (constructorLine <- filteredLinesOfCodeConstructors) {
    //         hashCodeLines += [(constructorLine)];
    //     }
    // }

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

    return (duplicate : duplicatedFragments[duplicate] | duplicate <- duplicatedFragments, duplicatedFragments[duplicate] > 2);
}


DuplicationRanking getDuplicationRanking(M3 projectModel, int linesOfCode) {
    list[str] listOfHashes = getListOfHashes(projectModel);
    map[str, int] duplicationMap = getDuplicatesOfProgram(listOfHashes);
    println("duplication map");
    println(duplicationMap);
    int amountOfDuplicates = 0;

    for(duplEntry <- duplicationMap) {
        amountOfDuplicates += duplicationMap[duplEntry];
    }

    // It is okay to round down, since in any case the rating wouldn't be influenced anyways, if we were to use the float value.
    int percentageOfDuplication = ((amountOfDuplicates * 6) / linesOfCode) * 100;
    return getDuplicationRanking(percentageOfDuplication);
}

public DuplicationRanking getDuplicationRanking(int duplicationPercentage){
    println("duplicationPercentage");
    println(duplicationPercentage);
    DuplicationRanking resultRanking =  [ranking | ranking <- allDuplicationRankings,
                                (duplicationPercentage < ranking.maxDuplicationOfUnit
                                || ranking.maxDuplicationOfUnit == -1)][0];
    return resultRanking;
}

public void formatDuplicationRanking(M3 projectModel, int linesOfCode) {
    DuplicationRanking ranking = getDuplicationRanking(projectModel, linesOfCode);
    println(ranking);
}