module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
ProjectLocation project = |file:///Users/ekletsko/Downloads/smallsql0.21_src|;

void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);

    list[Declaration] projectAST = getASTs(project);
    list[node] projectNodes = getNodesFromAST(projectAST);

	printDebug("Adding node details");
	list[tuple[int id, node n]] nodeWId = zip2([1..(size(projectNodes) + 1)], projectNodes);
	list[nodeDetailed] nodeWLoc = [ <id, unsetRec(nodeIc), nLoc, size> |
									<id,nodeI> <- nodeWId,
                                    nodeIc := (nodeI),
									nLoc := nodeFileLocation(nodeI),
									size := nodeSize(nodeI),
									size >= 5,
									nLoc != noLocation,
									(nLoc.end.line - nLoc.begin.line + 1) >= 5 ];
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

	println(results);

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