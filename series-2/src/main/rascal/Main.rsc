module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
ProjectLocation project = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/smallsql/|;

private list[CloneTuple] _clonePairs = [];
private int count = 0;
alias NodeHashLoc = tuple[NodeHash nHash, loc nodeLoc];
alias CloneTuple = tuple[node nodeA, node nodeB];

void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);

    list[Declaration] projectAST = getASTs(project);
    list[node] projectNodes = getNodesFromAST(projectAST);

	printDebug("Adding node details");
	int massThreshold = 6;

    list[NodeHashLoc] nodes = generateNodeHashLocations(projectNodes, massThreshold);
	println("Nodes Finished lel");
    list[CloneTuple] results = getClonePairs(nodes, 1.0);

	println(size(results));

    str stopBenchmarkTime = stopBenchmark("benchmark");

    println(stopBenchmarkTime);

}

public list[NodeHashLoc] generateNodeHashLocations(list[node] projectNodes, int massThreshold) {
    list[NodeHashLoc] nodeHashLocations = [];

    for(projectNode <- projectNodes) {
        loc projectNodeLocation = nodeFileLocation(projectNode);

        if(projectNodeLocation != noLocation) {
            node unsetRecNode = unsetRec(projectNode);
            str hashedProjectNode = hashSubtree(unsetRecNode, false);

            int nodeLineDifference = projectNodeLocation.end.line - projectNodeLocation.begin.line + 1;

            // TODO Find out if this is relevant or not...
            bool areNodeLinesInThreshold = nodeLineDifference >= massThreshold;
            bool isNodeSizeInThreshold = nodeSize(projectNode) >= massThreshold;
            
            if(areNodeLinesInThreshold && isNodeSizeInThreshold) {
                nodeHashLocations += <<hashedProjectNode, unsetRecNode>, projectNodeLocation>;
            }
        }
    }

    return nodeHashLocations;
}

public bool locationIsValid(loc location){
	return location.scheme != "unresolved"; 
}

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
		println("size of nodes <size(nodes)>");
        for (i <- nodes) {
            for (j <- nodes) {
				println("Similarity: <nodeSimilarity(i.nodeLocNode, j.nodeLocNode)>, Equal: <i.l != j.l>");
                if (!type2 && i.l != j.l) {
                    addClone(<i.nodeLocNode, j.nodeLocNode>);
					println(size(_clonePairs));
                }
                else if (i.l != j.l && toReal(nodeSimilarity(i.nodeLocNode, j.nodeLocNode)) >= similarityThreshold) {
					println("here");
                    addClone(<i.nodeLocNode, j.nodeLocNode>);
                }
            }
        }
    }
    //return _clonePairs;
}

public void addClone(CloneTuple newPair) {
    // Ignore the pair if one node is a subtree of another node
    if (isSubset(newPair.nodeA, newPair.nodeB) || isSubset(newPair.nodeB, newPair.nodeA)) {
        return;
    }

    list[node] children1 = [n | node n <- getChildren(newPair.nodeA)];
    list[node] children2 = [n | node n <- getChildren(newPair.nodeB)];

    for (oldPair <- _clonePairs) {
        // Check if the pair already exists in flipped form
        if (oldPair == <newPair.nodeB, newPair.nodeA> || oldPair == newPair) {
            return;
        }

        // Ignore the pair if it is a subset of an already existing pair
        if ((isSubset(oldPair.nodeA, newPair.nodeA) && isSubset(oldPair.nodeB, newPair.nodeB)) || (isSubset(oldPair.nodeA, newPair.nodeB) && isSubset(oldPair.nodeB, newPair.nodeA))) {
            return;
        }

        // If the current old pair is a subset of the current new pair. Remove it.
        if ((isSubset(newPair.nodeA, oldPair.nodeA) && isSubset(newPair.nodeB, oldPair.nodeB)) || (isSubset(newPair.nodeA, oldPair.nodeB) && isSubset(newPair.nodeB, oldPair.nodeA))) {
            _clonePairs -= oldPair;
        }
    }
    _clonePairs += newPair;

    return;
}

bool isSubset(node tree1, node tree2) {
	nodeString1 = toString(tree1);
	nodeString2 = toString(tree2);

	if(nodeString1 ==  nodeString2) {
		return false;
	}

    return contains(nodeString1, nodeString2);
}

public map[str, list[NodeLoc]] placingSubTreesInBuckets(list[NodeHashLoc] nodeHashList) {
        set[str] nodeHashes = toSet([nodeHash.nHash.nodeHash | nodeHash <- nodeHashList, true]);
        map[str, list[NodeLoc]] hashBuckets = ();

        for(hash <- nodeHashes) {
            list[NodeHashLoc] nodesHashesWithSameHashes = [h | h <- nodeHashList, h.nHash.nodeHash == hash];
            list[NodeLoc] nodesWithSameHashes = [<i.nHash.hashedNode, i.nodeLoc> | i <- nodesHashesWithSameHashes, true];
            hashBuckets = hashBuckets + (hash: nodesWithSameHashes);
        }
        return hashBuckets;
}