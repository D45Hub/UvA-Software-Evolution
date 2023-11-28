module TreeComparison::CloneSubsumption


import List;
import Map;
import IO;
import Relation;

/**
	Step1: Find included clones --> list of clones that may be deleted
	Step2: Get connections for clones to delete
	Step3: Only delete clones and their connections if both clones are marked as "to delete"
**/