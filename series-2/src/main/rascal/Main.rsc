module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
ProjectLocation project = |project://series-2/src/main/rascal/simpleencryptor/|;

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
	list[tuple[int id, node n]] nodeWId = zip2([1..(size(projectNodes) + 1)], projectNodes);
	list[nodeDetailed] nodeWLocs = [ <id, nodeIc, nLoc, size> |
									<id,nodeI> <- nodeWId,
                                    nodeIc := (nodeI),
									nLoc := nodeFileLocation(nodeI),
									size := nodeSize(nodeI),
									size >= 6,
									nLoc != noLocation,
									(nLoc.end.line - nLoc.begin.line + 1) >= 6 ];

    list[NodeHashLoc] nodes = [<<hashSubtree(unsetRec(nodeWLoc.d), false), unsetRec(nodeWLoc.d)>, nodeWLoc.l> | nodeWLoc <- nodeWLocs, true];
	println("Nodes Finished lel");
    /**
    printDebug("Comparing nodes");
	int nodeItems = size(nodeWLoc);
	int counter = 0;
    minimalSimularity = 100.0;
    cloneDetectionResult results = <(),{}, ()>;

	for (nodeLA <- nodeWLoc) {	

		//Progress
		printDebug("<counter> / <nodeItems>");
		counter = counter + 1;
		
		//Compare with all nodes
		for (nodeLB <- nodeWLoc) {

			//Only comapre with biger items, otherwise duplicates
			if(nodeLA.id >= nodeLB.id)
				continue;
								
			//Compare different and valid locations
			if(nodeLA.l == nodeLB.l || nodeLA.l == noLocation || nodeLB.l == noLocation)
				continue;

			//When the node count difference is too much, the simulairty cannot be in the margin
			if( nodeLA.s > nodeLB.s || nodeLB.s == 0 || nodeLA.s == 0 || percent(nodeLA.s,nodeLB.s) < minimalSimularity)
				continue;

			//Do not compare when node is subnode of
			if(nodeLA.l.path == nodeLB.l.path && (nodeLA.l >= nodeLB.l || nodeLA.l <= nodeLB.l))
				continue; 				
				
			//Minimal similarity
			num similarity = minimalSimularity == 100.0 ? (nodeLA.d == nodeLB.d ? 100.0 : 0) : nodeSimilarity(nodeLA.d, nodeLB.d);
			
			//if(nodeLB.l.end.line - nodeLB.l.begin.line + 1 > 5 && nodeLA.l.end.line - nodeLA.l.begin.line + 1 > 5)
			//	iprintln("For (<similarity>): <(nodeLA.l)> - <(nodeLB.l)>");
			//iprintln("similarity: <similarity>");
			if(similarity < minimalSimularity)
				continue;
							
			//iprintln(nodeLA.d);
			//iprintln("#############");
			//iprintln(nodeLB.d);
			
			//Log items that are the same
			printDebug("Similarity: <similarity>");
			printDebug("Loc a: <nodeLA.l> Loc b: <nodeLB.l>");
			results.connections[nodeLA.id] = nodeLB.id;
		}
	}
	printDebug("End comparing nodes");

	//Add node details
	for(nodeI <- nodeWLoc) {
		results.nodeDetails += (nodeI.id:nodeI);
	}
		
	//remove subsumed clones
	results = removeSubsumedClones(results, minimalSimularity); 
			
 	//Determine what lines are duplicates
	//results.duplicateLines = getDuplicateLinesPerFile(model,results); 
    */
    list[CloneTuple] results = getClonePairs(nodes, 0.9);//getSubtreeClonePairs(nodes, 5, 1.0);

	println(size(results));

    str stopBenchmarkTime = stopBenchmark("benchmark");

    println(stopBenchmarkTime);

}

set[str] listToSet(list[str] myList) {
    return toSet(myList);
}


public cloneDetectionResult removeSubsumedClones(cloneDetectionResult result, real minimalSimularity){
	set[nodeId] duplicateNodeIds = carrier(result.connections);

	map[nodeId, nodeDetailed] nodeDetails = (nodeId: result.nodeDetails[nodeId] | nodeId <- result.nodeDetails, nodeId in duplicateNodeIds);
	
	map[nodeId, nodeDetailed] flagForRemovalNodes = findIncludedClones(nodeDetails);
	
	rel[nodeId f, nodeId s] connections = result.connections;
	
	//Add transitive relations (transitive closure) for clones that are not type 3
	if(minimalSimularity == 100.0){
		connections = connections+;
	}

	rel[nodeId f, nodeId s] filteredConnections = {<c.f,c.s> | c <- connections, c.f notin flagForRemovalNodes || c.s notin flagForRemovalNodes};
	
	set[nodeId] filteredNodeIds = carrier(filteredConnections);
	
	if(minimalSimularity == 100.0){
		filteredConnections = filteredConnections+;
	}
	
	
	map[nodeId, nodeDetailed] filteredNodes = (id: nodeDetails[id] | nodeId id <- nodeDetails, id in filteredNodeIds);

	return <filteredNodes, filteredConnections, result.duplicateLines>;
}

public map[nodeId, nodeDetailed] findIncludedClones(map[nodeId, nodeDetailed] nodeDetails){
	return (id: nodeDetails[id] | nodeId id <- nodeDetails, isIncludedInAny(nodeDetails[id], nodeDetails));
}

public bool isIncludedInAny(nodeDetailed nodeA, map[nodeId, nodeDetailed] otherNodes){	
	return any(nodeId idB <- otherNodes, 
			nodeA.id != otherNodes[idB].id &&
			nodeA.l.path == otherNodes[idB].l.path &&
			nodeA.l <= otherNodes[idB].l
		);
}

public bool locationIsValid(loc location){
	return location.scheme != "unresolved"; 
}

public list[CloneTuple] getClonePairs(list[NodeHashLoc] hashedSubtrees, num similarityThreshold) {
    list[ClonePair] clonePairs = [];
    map[str, list[NodeLoc]] hashBuckets = placingSubTreesInBuckets(hashedSubtrees);
	println(size(hashBuckets));

	findClones(hashBuckets, 1.0);

    return _clonePairs;
}

void findClones(map[str, list[NodeLoc]] subtrees, real similarityThreshold,
                bool print=false, bool type2=false) {
    int counter = 0;
    int sizeS = size(subtrees);

    for (hash <- subtrees) {
        counter += 1;
        if (print) {
            println("Hash <counter> / <sizeS>. <hash>");
        }

        list[NodeLoc] nodes = subtrees[hash];
		//println(nodes);

        for (i <- nodes) {
			//iprintln(i);
            for (j <- nodes) {
				println("Similarity: <nodeSimilarity(i.nodeLocNode, j.nodeLocNode)>, Equal: <i.l != j.l>");
                if (!type2 && i.l != j.l) {
                    addClone(<i.nodeLocNode, j.nodeLocNode>, print=print);
					println(size(_clonePairs));
                }
                else if (i.l != j.l && toReal(nodeSimilarity(i.nodeLocNode, j.nodeLocNode)) >= similarityThreshold) {
					println("here");
                    addClone(<i.nodeLocNode, j.nodeLocNode>, print=print);
                }
				//println(size(_clonePairs));
            }
        }
    }
    //return _clonePairs;
}

public void addClone(CloneTuple newPair, bool print=false) {
    // Ignore the pair if one node is a subtree of another node
    if (isSubset(newPair.nodeA, newPair.nodeB) || isSubset(newPair.nodeB, newPair.nodeA)) {
        return;
    }

    list[node] children1 = [n | node n <- getChildren(newPair.nodeA)];
    list[node] children2 = [n | node n <- getChildren(newPair.nodeB)];

    for (oldPair <- _clonePairs) {
		println(oldPair);
		println(newPair);
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
    return contains(toString(tree1), toString(tree2));
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