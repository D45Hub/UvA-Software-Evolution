module Helper::Types

public alias ProjectLocation = loc;
public alias NodeHash = tuple[str nodeHash, node hashedNode];
public alias ClonePair = tuple[NodeHash nodeA, NodeHash nodeB];

alias NodeIdLocation = tuple[nodeId id, loc l];

alias nodeId = int;
alias nodeS = tuple[node d,int s];
alias nodeDetailed = tuple[nodeId id, node d, loc l, int s];
alias cloneDetectionResult = tuple[map[nodeId, nodeDetailed] nodeDetails, rel[nodeId f,nodeId s] connections, duplications duplicateLines];

alias OutputHeads = list[str];
alias OutputRow = list[str];
alias OutputRows = list[OutputRow];
alias HeadValue = tuple[str headVal, str val];

alias FileLineBounds = tuple[int fileStart, int fileEnd];
alias FileLineMapping = map[loc, FileLineBounds];
alias ProjectFileOptions = tuple[bool addPageBreakTokens];

alias duplications = map[str, set[int]];
alias commentRangs = tuple[int fromL, int fromC, int toL, int toC];
alias cloneDetectionResult = tuple[map[nodeId, nodeDetailed] nodeDetails, rel[nodeId f,nodeId s] connections, duplications duplicateLines];