module Helper::ASTHelperTest 

import Helper::Helper;
import Prelude;

test bool massThresholdShouldBeRespected(){
    result = [];

    for(int n <- [0 .. 3]) {
	result += size(getNodesFromAST("5175w"($2012-09-30T22:17:59.000+00:00$,"𒌟"),n));
    }
    
    return size(result) == 3 && all(n <- result, n == 1);
}