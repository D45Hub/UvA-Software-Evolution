module TreeComparison::SubtreeComparator

import List;
//import Real;

alias ClonePair = tuple[node nodeA, node nodeB];

public num nodeSimilarity(node comparedNodeA, node comparedNodeB) {
    list[node] nodeListA = []; //Get all subnodes here...
    list[node] nodeListB = []; // Here as well... :D

    list[node] sharedSubnodes = nodeListA & nodeListB;
    int sharedSubnodeAmount = size(sharedSubnodes);

    // TODO GUCK MAL OB NE LISTSUBTRACTION MACHBAR IST...
    // Dann könnt man sowas wie... nodeListA - sharedSubnodes, und auch für B machen...
    list[node] nonSharedSubnodesA = [n | n <- nodeListA, !(n in sharedSubnodes)];
    list[node] nonSharedSubnodesB = [n | n <- nodeListB, !(n in nonSharedSubnodesB)];

    int amountNonSharedSubnodesA = size(nonSharedSubnodesA);
    int amountNonSharedSubnodesB = size(nonSharedSubnodesB);

    num similarityScore = toReal((2*sharedSubnodeAmount) / (2*sharedSubnodeAmount + amountNonSharedSubnodesA + amountNonSharedSubnodesB));

    return similarityScore;
}


public list[ClonePair] getSubtreeClonePairs(node mainTree) {
    list[ClonePair] clonePairs = [];

// TODO HIER NOCH WEITER DAS MIT DEM GROßEN LOOP REIN...
    top-down-break visit(mainTree) {
        case leaf(int n)  => {
            if (n in ast1) {
                duplicateNodes += [n];
            }
        }

    return clonePairs;
}