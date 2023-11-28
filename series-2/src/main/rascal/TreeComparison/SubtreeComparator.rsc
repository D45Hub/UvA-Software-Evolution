module TreeComparison::SubtreeComparator

import Helper::Helper;
import Prelude;
import util::Math;
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

/* 
Referring to Step 2 & 3 where we create hash buckets. 
We also need to define the mass of nodes to create equally sized thingies.
*/ 
public map[str, list[node]] placingSubTreesInBuckets(list[NodeHash] nodeHashList) {
        set[str] nodeHashes = toSet([nodeHash.nodeHash | nodeHash <- nodeHashList, true]);
        map[str, list[node]] hashBuckets = ();

        for(hash <- nodeHashes) {
            list[NodeHash] nodesHashesWithSameHashes = [h | h <- nodeHashList, h.nodeHash == hash];
            //println(nodesHashesWithSameHashes);
            list[node] nodesWithSameHashes = [i.hashedNode | i <- nodesHashesWithSameHashes, true];
            hashBuckets = hashBuckets + (hash: nodesWithSameHashes);
        }
        return hashBuckets;
}

/* Referring to step 3*/ 
public num nodeSimilarity(node comparedNodeA, node comparedNodeB) {
    nodeListA = getSubNodesList(comparedNodeA);
    nodeListB = getSubNodesList(comparedNodeB);

    sharedSubnodes = nodeListA & nodeListB;
    real sharedSubnodeAmount = toReal(size(sharedSubnodes));

    // TODO GUCK MAL OB NE LISTSUBTRACTION MACHBAR IST...
    // Dann könnt man sowas wie... nodeListA - sharedSubnodes, und auch für B machen...
    nonSharedSubnodesA = [n | n <- nodeListA, !(n in sharedSubnodes)];
    nonSharedSubnodesB = [n | n <- nodeListB, !(n in sharedSubnodes)];

    real amountNonSharedSubnodesA = toReal(size(nonSharedSubnodesA));
    real amountNonSharedSubnodesB = toReal(size(nonSharedSubnodesB));

    num similarityScore = toReal((2*sharedSubnodeAmount) / (2*sharedSubnodeAmount + amountNonSharedSubnodesA + amountNonSharedSubnodesB));

    return similarityScore;
}

/*
For each subtree of i we have to check if it is in the clone pair is already present
if yes, remove it. Because we only want to keep the largest clones. 
Same applies for the 2nd subtree. 
In the end we need to add the new clone pair of i and j. This function refers to the
"isMember" in the Paper. 
*/ 
public bool isSubClone(node subtree, node clone) {
    subtreeStr = toString(subtree);
    cloneStr = toString(clone);
    return contains(cloneStr, subtreeStr);
}

public bool isMember(list[ClonePair] clonePairs, NodeHash subtree) {
    list[ClonePair] clonePairMembers = [pair | pair <- clonePairs, pair.nodeA == subtree.hashedNode || pair.nodeB == subtree.hashedNode];
    int clonePairMembersAmount = size(clonePairMembers);
    return clonePairMembersAmount > 0;
}

/* If we detect that a subtree is smaller than the proposed clone, we need to 
remove it rom the initial clone pair list (type nodehash node) */ 
public list[ClonePair] removeClonePair(ClonePair clonePair, list[ClonePair] listOfClones) {
    matchingCloneList = [element | element <- listOfClones, clonePair.nodeA.nodeHash == clonePair.nodeA.nodeHash];
    assert size(matchingCloneList) == 1;
    updatedList = delete(listOfClones, indexOf(listOfClones, matchingCloneList[0] ));
    return updatedList;
}

public list[ClonePair] getSubtreeClonePairs(list[node] mainTree, int massThreshold, num similarityThreshold) {
    list[ClonePair] clonePairs = [];
    list[NodeHash] clones = [];

    list[NodeHash] hashedSubtrees = getNSizedHashedSubtrees(mainTree, massThreshold);
    map[str, list[node]] hashBuckets = placingSubTreesInBuckets(hashedSubtrees);
    //iprint(hashBuckets);
    for(NodeHash i <- hashedSubtrees) {

        list[node] sameNodeHashElements = [bucket | bucket <- hashBuckets[i.nodeHash], toString(bucket) != toString(i.hashedNode)];

        for(node j <- sameNodeHashElements) {
            num similarity = nodeSimilarity(i.hashedNode, j);

            if(similarity > similarityThreshold) {

                list[NodeHash] subtreesI = [ possibleTree | possibleTree <- hashedSubtrees, possibleTree.nodeHash == i.nodeHash ];
                list[NodeHash] subtreesJ = [ possibleTree | possibleTree <- hashedSubtrees, possibleTree.nodeHash == j.nodeHash ];

                for(NodeHash s <- subtreesI) {
                    bool isNodeMember = isMember(clonePairs, s);

                    if(isNodeMember) {
                        clonePairs = removeClonePair(<i, <i.nodeHash, j>>, clonePairs);
                    }
                }

                for(NodeHash s <- subtreesJ) {
                    bool isNodeMember = isMember(clonePairs, s);

                    if(isNodeMember) {
                        clonePairs = removeClonePair(<i, <i.nodeHash, j>>, clonePairs);
                    }
                }

                // Unsure about if this is a correct approach for handling clone removal. (See paper...)
                //clonePairs = filterSubtreeHashInClonePairs(subtreesI, subtreesJ, clonePairs);
                //iprint(clonePairs);
                clonePairs += [<i, <i.nodeHash, j>>];
            }
        }
    }

// TODO HIER NOCH WEITER DAS MIT DEM GROßEN LOOP REIN...
/*
    top-down-break visit(mainTree) {
        case leaf(int n)  => {
            if (n in ast1) {
                duplicateNodes += [n];
            }
        }
*/

    return clonePairs;
}

list[ClonePair] filterSubtreeHashInClonePairs(list[NodeHash] nodeHashesA, list[NodeHash] nodeHashesB, list[ClonePair] clonePairs) {
    list[ClonePair] filteredClonePairs = [];

    for(pair <- clonePairs) {
        if((pair notin nodeHashesA) || (pair notin nodeHashesB)) {
            filteredClonePairs += [pair];
        }
    }

    return filteredClonePairs;
} 