module Helper::Types

public alias ProjectLocation = loc;
public alias NodeHash = tuple[str nodeHash, node hashedNode];
public alias ClonePair = tuple[NodeHash nodeA, NodeHash nodeB];
public alias CloneTuple = tuple[node nodeA, node nodeB];
public alias NodeLoc = tuple[node nodeLocNode, loc l];
public alias NodeHashLoc = tuple[NodeHash nHash, loc nodeLoc];

public alias DuplicationLocation = tuple[str uuid, str filePath, str methodName, int startLine, int endLine];
public alias DuplicationResult = list[DuplicationLocation];