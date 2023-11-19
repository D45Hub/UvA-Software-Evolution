module Duplication::Duplication

import Ranking::Ranking;
import Volume::LOCVolume;

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import String;
import util::Math;
import List;

alias Size = int;
alias DuplicationRanking =  tuple[Ranking rankingType,
                                Size minDuplicationOfUnit,
                                Size maxDuplicationOfUnit];

alias DuplicationValue = tuple[DuplicationRanking duplicationRanking,
                                real duplicationPercentage];

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

str genStringHashCode(str input) {
    int hashCode = 7;
    list[int] inputCharacters = chars(input);

    for(character <- inputCharacters) {
        hashCode = hashCode*31 + character;
    }

    return toString(hashCode);
}

/* With this it could happen that say a 3 line code block from the end of one 
unit and a 3 line block from the beginning of another unit could form a false 
duplication block with a "real" block somewhere else.
This case is so improbable though, that we decided to omit it to preserve 
relative simplicity. */

list[str] getListOfHashes(M3 projectModel) {

    list[str] hashCodeLines = [];

    classMethods = methods(projectModel);
    classConstructors = constructors(projectModel);

    for(method <- classMethods) {

        str rawMethod = readFile(method);

        list[str] filteredLinesOfCode = getLOC(rawMethod);

        if(size(filteredLinesOfCode) < 6) {
            continue;
        }

        for (methodLine <- filteredLinesOfCode) {
            hashCodeLines += [(methodLine)];
        }
    }

    for(constructor <- classConstructors) {

        str rawConstructor = readFile(constructor);
        list[str] filteredLinesOfCodeConstructors = getLOC(rawConstructor);

        if(size(filteredLinesOfCodeConstructors) < 6) {
            continue;
        }

        for (constructorLine <- filteredLinesOfCodeConstructors) {
            hashCodeLines += [(constructorLine)];
        }
    }

    return hashCodeLines;
}

map[str, int] getDuplicatesOfProgram (list[str] linesOfCode) {
    i = 0;
    map[str,int] duplicatedFragments = ();

    while (i < size(linesOfCode) && (i+6) < size(linesOfCode)) {
        listForHashing = linesOfCode[i..i+6];
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


public DuplicationValue getDuplicationRankingValue(real percentageOfDuplication) {
    return <getDuplicationRanking(percentageOfDuplication), percentageOfDuplication>;
}

int getDuplicatedLines(M3 projectModel) {
    list[str] listOfHashes = getListOfHashes(projectModel);

    map[str, int] duplicationMap = getDuplicatesOfProgram(listOfHashes);
    int amountOfDuplicatedLines = 0;

    for(duplEntry <- duplicationMap) {
        amountOfDuplicatedLines += duplicationMap[duplEntry];
    }

    return amountOfDuplicatedLines;
}

real getDuplicationPercentage(int duplicatedLines, int overallLines) {
    real duplicationPercentage = toReal((duplicatedLines / toReal(overallLines)));
    return (toReal(duplicationPercentage) * 100.0);
} 

public DuplicationRanking getDuplicationRanking(real duplicationPercentage){
    DuplicationRanking resultRanking =  [ranking | ranking <- allDuplicationRankings,
                                (duplicationPercentage < ranking.maxDuplicationOfUnit
                                || ranking.maxDuplicationOfUnit == -1)][0];
    return resultRanking;
}

/**

    Alternative concept of the AST-based approach.

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