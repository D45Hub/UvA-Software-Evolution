module NodeHelpers::NodeHelpers

/* A module to have some helpers for node ttypes*/

/* Determining the size of a subtree, needed for the mass threshold */ 
public int nodeSize(node subtree) {
	int size = 0;
	visit (subtree) {
		case node _ : size += 1;
	}
	return size;
}