module TreeComparison::SubtreeComparator

import List;
//import Real;

/* 
Algorithm according to the Bexter Paper

Step 1) Define a min mass (size of nodes) for the subtrees. 
Step 2) Generate Hashes for each of the subtrees (With a _bad_ hashfunctino)
Step 3) Insert the Hash + the content of the node into the respective bucket 
(if there is no respective bucket, create one)
Step 3) Start by comparing each hash in the buckets with a similarity function. 
Step 4) If the similarity is above a predefined threshold, add a new clone pair 
the clone list. 
*/ 

alias ClonePair = tuple[node nodeA, node nodeB];

/* 
Referring to Step 2 & 3 where we create hash buckets. 
We also need to define the mass of nodes to create equally sized thingies.
*/ 
public map[string, node] placingSubTreesInBuckets(ast, massOfNodes) {
        // TODO Implement
}

/* Referring to step 3*/ 
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

/*
For each subtree of i we have to check if it is in the clone pair is already present
if yes, remove it. Because we only want to keep the largest clones. 
Same applies for the 2nd subtree. 
In the end we need to add the new clone pair of i and j 
*/ 
public bool checkIfSubTreeIsInClone(ast, massOfNodes) {
        // TODO Implement
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