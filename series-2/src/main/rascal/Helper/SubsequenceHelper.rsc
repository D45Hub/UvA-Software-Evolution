module Helper::SubsequenceHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::\syntax::Java18;
import IO;
import Node;
import List;
import util::Math;
import Helper::Helper;
import Type;
import Boolean;
import Set;
import Location;

Type defaultType = Type::short();

private map[node subtree, str hash] hashes = ();

map[tuple[list[node] zNode, list[node] i] zList, str subsetResult] zeroSubsetResults = ();
map[tuple[list[node] oNode, list[node] j] oList, str subsetResult] oneSubsetResults = ();

map[node uNode, int uniqueNodes] uniqueNodes = ();

// One sequence is a list of statements. 
// This represents the list structure in the paper
/* 
{x=0; if(d>1) ... } hashcodes = 675, 3004
so e.g. [[[x=0;, if(d>1);]],[[y=1;, z= 2;]]]
*/ 
list[list[node]] getListOfSequences(list[Declaration] ast, list[tuple[loc, loc]] wholeCloneLocs, int minimumSequenceLengthThreshold, int cloneType) {
    list[list[node]] sequences = [];
    visit (ast) {
        /**
        * This block makes use of the https://www.rascal-mpl.org/docs/Rascal/Statements/Block/ 
        * statement in rascal which detects sequences, mostly separated by a ; 
        * 
        */ 
        case \block(list[Statement] statements): {
            /* You are putting the statements into a list of node -> Why temporal? */ 
            list[node] sequence = statements;

            if (size(statements) >= minimumSequenceLengthThreshold) {
                if(cloneType != 1) {
                    sequence = [normalizeIdentifiers(n) | n <- sequence];
                }
                bool isContained = false;
                for(wLoc <- wholeCloneLocs) {
                    isContained = any(node n <- sequence, isContainedIn(nodeFileLocation(n), wLoc<0>) || isContainedIn(nodeFileLocation(n), wLoc<1>));
                    if(isContained) {
                        break;
                    }
                }
                if(!isContained) {
                    sequences += [sequence]; // Sequences list.
                }
            }
        }
    }
    return sequences;
}

map[str, list[node]] getSubtrees(list[Declaration] asts, int nodeNumberThreshold, int lineThreshold, int cloneType) {
    map[str, list[node]] hashedTrees = ();

    visit (asts) {
        case node n: {
            if(cloneType != 1) {
                n = normalizeIdentifiers(n);
            }
            hash = md5Hash(toString(unsetRec(n)));
            loc nodeLoc = nodeFileLocation(n);
            if (nodeLoc != |unresolved:///| && (!isLeaf(n) || cloneType == 1) && nodeSize(n) >= nodeNumberThreshold && ((nodeLoc.end.line - nodeLoc.begin.line) + 1) >= lineThreshold) {
                hashedTrees[hash]?[] += [n];
            }
        }
    }
    return hashedTrees;
}

public list[tuple[node, node]] findClones(map[str, list[node]] subtrees) {
    list[tuple[node, node]] clonePairs = [];
    for (hash <- subtrees) {
        list[node] nodes = subtrees[hash];

        for (i <- nodes) {
            for (j <- nodes) {
                if (i.src? && j.src? && (i.src != j.src)) {
                    clonePairs = addClone(<i, j>, clonePairs);
                }
            }
        }
    }
    return clonePairs;
}

public int nodeSize(node subtree) {
    return arity(subtree) + 1;
}

public list[tuple[node, node]] addClone(tuple[node, node] newPair, list[tuple[node, node]] clonePairs) {
    // Ignore the pair if one node is a subtree of another node
    if (isSubset(newPair[0], newPair[1]) || isSubset(newPair[1], newPair[0])) {
        return;
    }

    list[node] children1 = [n | node n <- getChildren(newPair[0])];
    list[node] children2 = [n | node n <- getChildren(newPair[1])];

    for (oldPair <- clonePairs) {
        // Check if the pair already exists in flipped form
        if (oldPair == <newPair[1], newPair[0]> || oldPair == <newPair[0], newPair[1]> ) {
            return clonePairs;
        }

        // Ignore the pair if it is a subset of an already existing pair
        if ((isSubset(oldPair[0], newPair[0]) && isSubset(oldPair[1], newPair[1])) || (isSubset(oldPair[0], newPair[1]) && isSubset(oldPair[1], newPair[0]))) {
            return clonePairs;
        }

        // If the current old pair is a subset of the current new pair. Remove it.
        if ((isSubset(newPair[0], oldPair[0]) && isSubset(newPair[1], oldPair[1])) || (isSubset(newPair[0], oldPair[1]) && isSubset(newPair[1], oldPair[0]))) {
            clonePairs -= oldPair;
        }
    }
    clonePairs += newPair;

    return clonePairs;
}

public bool isSubset(node tree1, node tree2) {
    visit(tree1) {
        case node n: if (n == tree2) {return true;}
    }
    return false;
}


map[str, list[list[node]]] createSequenceHashTable(list[Declaration] ast, list[tuple[node, node]] wholeClones, int minimumSequenceLengthThreshold, int cloneType) {
    map[str, list[list[node]]] hashTable = ();
    list[tuple[loc, loc]] wholeCloneLocs = [<nodeFileLocation(t<0>), nodeFileLocation(t<1>)> | t <- wholeClones];
    list[list[node]] sequences = getListOfSequences(ast, wholeCloneLocs, minimumSequenceLengthThreshold, cloneType);

    map[node, str] nodeHashMap = ();
    
    for (sequence <- sequences) {
        int sequenceSize = size(sequence);
        for (i <- [0..(sequenceSize - minimumSequenceLengthThreshold + 1)], j <- [i + minimumSequenceLengthThreshold..(sequenceSize + 1)]) {
            if ((j >= i + minimumSequenceLengthThreshold)) {
                list[node] subsequence = sequence[i..j];
                // hash every subsequence
                str subsequenceHash = "";
                for (n <- subsequence) {
                    if(n in nodeHashMap) {
                        subsequenceHash += nodeHashMap[n];
                    } else {
                        str nodeHash = hashNode(n);
                        nodeHashMap[n]?"" += nodeHash; 
                        subsequenceHash += nodeHash;
                    }
                    
                }
                str sequenceHash = md5Hash(subsequenceHash);

                if (sequenceHash in hashTable) {
                    hashTable[sequenceHash] += [subsequence];
                } else {
                    hashTable[sequenceHash] = [subsequence];
                }
            }
        }
    }
    return hashTable;
}

str hashNode(node n) {
    if (n in hashes) {
        return hashes[n];
    }

    hashes[n] = md5Hash(unsetRec(n));
    return hashes[n];
}

list[tuple[list[node], list[node]]] removeSequenceSubclones(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    set[tuple[list[node], list[node]]] cloneSet = toSet(clones);
    set[tuple[list[node], list[node]]] sequencesToRemove = {[s, s2] | s <- i, s2 <- j, {s, s2} in cloneSet || {s2, s} in cloneSet};
    return toList(cloneSet - sequencesToRemove);
}

bool canAddSequence(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    return all(pair <- clones, !(checkSubset(pair[0], pair[1], i, j))); 
}

bool checkSubset(list[node] zeroNode, list[node] oneNode, list[node] i, list[node] j) {
    bool zeroValue = false;
    bool oneValue = false;

    if(<zeroNode,i> in zeroSubsetResults) {
        zeroValue = fromString(zeroSubsetResults[<zeroNode,i>]);
    } else {
        zeroValue = isSubset(zeroNode, i);
        str zeroValueString = toString(zeroValue);
        zeroSubsetResults[<zeroNode,i>]?"" += zeroValueString;
    }

    if(zeroValue) {
        return true;
    }
    
    if(<oneNode,j> in oneSubsetResults) {
        oneValue = fromString(oneSubsetResults[<oneNode,j>]);
    } else {
        oneValue = isSubset(oneNode, j);
        str oneValueString = toString(oneValue);
        oneSubsetResults[<oneNode,j>]?"" += oneValueString;
    }

    return oneValue;    
}

list[tuple[list[node], list[node]]] addSequenceClone(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    // if clones is empty, just add the pair
    if (size(clones) == 0) {
        clones = [<i, j>];
    } else {
        // check if the pair is already in clones, as is or as a subclone
        if (<j,i> in clones || <i,j> in clones) {
            return clones;
        }
        //clones = removeSequenceSubclones(clones, i, j);
        if (canAddSequence(clones, i, j)) {
            clones = removeSequenceSubclones(clones, i, j) + [<i, j>];
        }
    }

    return clones;
}

list[tuple[list[node], list[node]]] findSequenceClonePairs(map[str, list[list[node]]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[list[node], list[node]]] clones = [];
    map[str, real] similarityMap = ();
    set[str] processedPairs = {};

    // for each sequence i and j in the same bucket
	for (bucket <- hashTable) {	
        for (i <- hashTable[bucket], j <- hashTable[bucket] - [i]) {
            // ensure we are not comparing one thing with itself
                str iString = toString(i);
                str jString = toString(j);
                str listStr = iString + jString;
                str listStrRev = jString + iString;
                real comparison = 0.0;

                // Skip if pair has already been processed
                if (listStr in processedPairs) {
                    continue;
                }

                
                if (quickCheckBeforeSimilarity(i, j)) {
                    processedPairs += listStr;
                    continue;
                }

                if(listStr in similarityMap) {
                    comparison = similarityMap[listStr];
                } else if (listStrRev in similarityMap) {
                    comparison = similarityMap[listStrRev];
                } else {
                    comparison = similarity(i, j);
                    similarityMap[listStr]?0.0 = comparison;
                }
                
                // check if are clones
                if (((cloneType == 1 && comparison == 1.0) || ((cloneType == 2 || cloneType == 3)) && (comparison >= similarityThreshold))) {
                    clones = addSequenceClone(clones, i, j);
                }

                // Mark the pair as processed
                processedPairs += listStr;
        }	
    }
    return clones;
}

bool quickCheckBeforeSimilarity(list[node] i, list[node] j) {
    // Example: Check if the lengths of the sequences differ significantly
    int minLength = min(size(i), size(j));
    int maxLength = max(size(i), size(j));
    real lengthRatio = toReal(maxLength) / toReal(minLength);

    // If the length ratio is above a certain threshold, consider the sequences dissimilar
    return lengthRatio > 2.0;
}

real similarity(list[node] subtrees1, list[node] subtrees2) {
    list[real] SLR = [0.0, 0.0, 0.0];
    for (i <- [0..size(subtrees1)]) {
        tuple[int S, int L, int R] currentSLR = sharedUniqueNodes(subtrees1[i], subtrees2[i]);
        SLR[0] += toReal(currentSLR[0]);
        SLR[1] += toReal(currentSLR[1]);
        SLR[2] += toReal(currentSLR[2]);
    }

    real similarity = 2.0 * SLR[0] / (2.0 * SLR[0] + SLR[1] + SLR[2]);
    return similarity;
}

tuple[int S, int L, int R] sharedUniqueNodes(node subtree1, node subtree2) {
    map[node, int] nodeCounter = ();
    int shared = 0;
    int unique = 0;

    visit(subtree1) {
        case node n: nodeCounter[unsetRec(n)]?0 += 1;
    }
    visit(subtree2) {
        case node n: {
            node unset = unsetRec(n);
            int a = nodeCounter[unset]?0;
            if (a > 0) {
                shared += 2;
                nodeCounter[unset] -= 1;
            } else {
                unique += 1;
            }
        }
    }

    return <shared, unique, 0>;
}

public node normalizeIdentifiers(node nodeItem) {

	return visit(nodeItem) {
        case \enum(_, implements, constants, body) => \enum("enum", implements, constants, body)
		case \enumConstant(_, args, cls) => \enumConstant("enumConstant", args, cls)
		case \enumConstant(_, args) => \enumConstant("enumConstant", args)
		case \class(_, ext, imp, bod) => \class("class", ext, imp, bod)
		case \interface(_, ext, imp, bod) => \interface("interface", ext, imp, bod)
		case \method(_, _, a, b, c) => \method(defaultType, "method", a, b, c)
		case \method(Type a,str b,list[Declaration] c,list[Expression] d) => \method(a,b,c,d)
		case \constructor(_, pars, expr, impl) => \constructor("constructor", pars, expr, impl)
		case \variable(_,ext) => \variable("variable",ext)
		case \variable(_,ext, ini) => \variable("variable",ext,ini)
        case \variables(_, fragments) => \variables(defaultType, fragments)
		case \typeParameter(_, list[Type] ext) => \typeParameter("typeParameter",ext)
		case \annotationType(_, bod) => \annotationType("annotationType", bod)
		case \annotationTypeMember(_, _) => \annotationTypeMember(defaultType, "annotationTypeMember")
		case \annotationTypeMember(_, _, def) => \annotationTypeMember(defaultType, "annotationTypeMember", def)
		case \parameter(_, _, ext) => \parameter(defaultType, "parameter", ext)
		case \vararg(_, _) => \vararg(defaultType, "vararg")
		case \characterLiteral(_) => \characterLiteral("a")
        case \field(_, fragments) => \field(defaultType, fragments)
		case \fieldAccess(is, _) => \fieldAccess(is, "fa")
        case \fieldAccess(is, ex, _) => \fieldAccess(is, ex, "fa")
		case \methodCall(is, _, arg) => \methodCall(is, "methodCall", arg)
		case \methodCall(is, expr, _, arg) => \methodCall(is, expr, "methodCall", arg)
        case \methodCall(is, _, \stringLiteral(_)) => \methodCall(is, expr, "methodCall", \stringLiteral("str"))
		case \number(_) => \number("1")
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("str")
        case \stringConstant(_) => \stringConstant("str")
        case \infix(lhs, _, rhs) => \infix(lhs, "=", rhs)
        case \postfix(operand, _) => \postfix(operand, "=")
        case \prefix(_, operand) => \prefix("=", operand)
		case \type(_) => \type(defaultType)
		case \simpleName(_) => \simpleName("simpleName")
		case \markerAnnotation(_) => \markerAnnotation("markerAnnotation")
		case \normalAnnotation(_, memb) => \normalAnnotation("normalAnnotation", memb)
		case \memberValuePair(_, vl) => \memberValuePair("memberValuePair", vl)
		case \singleMemberAnnotation(_, vl) => \singleMemberAnnotation("singleMemberAnnotation", vl)
		case \break(_) => \break("break")
		case \continue(_) => \continue("continue")
		case \label(_, bdy) => \label("label", bdy)
        case \assignment(lhs, _, rhs) => \assignment(lhs, "=", rhs)
        case \newObject(expr, _, args, class) => \newObject(expr, defaultType, args, class)
        case \newObject(_, args, class) => \newObject(defaultType, args, class)
        case \newObject(_, args) => \newObject(defaultType, args)
        case \newArray(_, dimensions, init) => \newArray(defaultType, dimensions, init)
        case \newArray(_, dimensions) => \newArray(defaultType, dimensions)
        case \cast(_, expression) => \cast(defaultType, expression)
        case \instanceOf(leftSide, _) => \instanceOf(leftSide, defaultType)
		case Type _ => defaultType
		case Modifier _ => lang::java::m3::AST::\public()
	}
}