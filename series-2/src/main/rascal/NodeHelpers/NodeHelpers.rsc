module NodeHelpers::NodeHelpers

import HashingHelper::HashingHelper;

/* A module to have some helpers for node ttypes*/

alias NodeHash = tuple[str nodeHash, node n];

/* Determining the size of a subtree, needed for the mass threshold */ 
public int nodeSize(node subtree) {
	int size = 0;
	visit (subtree) {
		case node _ : size += 1;
	}
	return size;
}

public list[node] getSubNodesList(node rootNode) {
	list[node] subNodeList = [];
	visit (rootNode) {
		case node n: {
			subNodeList += n;
		}
	}
	return subNodeList;
}

public list[NodeHash] getNSizedHashedSubtrees(node rootNode, int minSubtreeSize) {
	list[NodeHash] subNodeList = [];

	bottom-up visit (rootNode) {
        case node n: {
            if(nodeSize(n) >= minSubtreeSize) {
				subNodeList += [<hashSubtree(n), n>];
			}
        }
    }
    return subNodeList;
}