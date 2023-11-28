module Helper::CloneHelper
import Helper::ProjectHelper;
import Helper::Types;

public list[CloneTuple] getClonePairs(list[NodeHashLoc] hashedSubtrees, num similarityThreshold) {
    list[ClonePair] clonePairs = [];
    map[str, list[NodeLoc]] hashBuckets = placingSubTreesInBuckets(hashedSubtrees);
	findClones(hashBuckets, similarityThreshold);

    return _clonePairs;
}

void findClones(map[str, list[NodeLoc]] subtrees, real similarityThreshold bool type2=false) {
    int counter = 0;
    int sizeS = size(subtrees);
    for (hash <- subtrees) {
        counter += 1;
        list[NodeLoc] nodes = subtrees[hash];
        for (i <- nodes) {
            for (j <- nodes) {
                if (!type2 && i.l != j.l) {
                    addClone(<i.nodeLocNode, j.nodeLocNode>);
                }
                else if (i.l != j.l && toReal(nodeSimilarity(i.nodeLocNode, j.nodeLocNode)) >= similarityThreshold) {
                    addClone(<i.nodeLocNode, j.nodeLocNode>);
                }
            }
        }
    }
}

public void addClone(CloneTuple newPair) {
    // Ignore the pair if one node is a subtree of another node
    if (isNodeSubset(newPair.nodeA, newPair.nodeB) || isNodeSubset(newPair.nodeB, newPair.nodeA)) {
        return;
    }

    for (oldPair <- _clonePairs) {
        // Check if the pair already exists in flipped form
        if (oldPair == <newPair.nodeB, newPair.nodeA> || oldPair == newPair) {
            return;
        }

        // Ignore the pair if it is a subset of an already existing pair
        if ((isNodeSubset(oldPair.nodeA, newPair.nodeA) && isNodeSubset(oldPair.nodeB, newPair.nodeB)) || (isNodeSubset(oldPair.nodeA, newPair.nodeB) && isNodeSubset(oldPair.nodeB, newPair.nodeA))) {
            return;
        }

        // If the current old pair is a subset of the current new pair. Remove it.
        if ((isNodeSubset(newPair.nodeA, oldPair.nodeA) && isNodeSubset(newPair.nodeB, oldPair.nodeB)) || (isNodeSubset(newPair.nodeA, oldPair.nodeB) && isNodeSubset(newPair.nodeB, oldPair.nodeA))) {
            _clonePairs -= oldPair;
        }
    }
    _clonePairs += newPair;

    return;
}

