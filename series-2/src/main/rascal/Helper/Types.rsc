module Helper::Types

public alias ProjectLocation = loc;
public alias NodeHash = tuple[str nodeHash, node hashedNode];
public alias ClonePair = tuple[NodeHash nodeA, NodeHash nodeB];
public alias CloneTuple = tuple[node nodeA, node nodeB];
public alias NodeLoc = tuple[node nodeLocNode, loc l];
public alias NodeHashLoc = tuple[NodeHash nHash, loc nodeLoc];

public alias MethodLoc = tuple[loc methodLocation, int methodLoc];

public alias DuplicationLocation = tuple[str uuid, str filePath, str fileUri, str methodName, int methodLoc, int startLine, int endLine, str base64Content];
public alias DuplicationResult = list[DuplicationLocation];

public alias LocationLines = tuple[int lineFrom, int lineTo];

public alias CloneConnections = lrel[str,str];
public alias TransitiveCloneConnections = list[tuple[str, str]];