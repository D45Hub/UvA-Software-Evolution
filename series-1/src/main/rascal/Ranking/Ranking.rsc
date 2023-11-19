module Ranking::Ranking

import util::Math;
import List;

/* An alias in Rascal is used to rename a "type" to something more meaningful 
In order to make our code more meaningful, we decided to use it.
c.f. https://www.rascal-mpl.org/docs/Rascal/Declarations/Alias/ 
The generic type of the ranking is derived from the paper itself
(see complexity ranking for e.g. in C. "Complexity per unit").
*/ 
alias Ranking = tuple[str name,int val];

/* To calculate an average score in the end, we use numbers from 0 - 4 and map 
them accordingly to the values from "veryNegative to excellent"*/ 
public Ranking excellent = <"++", 4>;
public Ranking good = <"+", 3>;
public Ranking neutral = <"o", 2>;
public Ranking negative = <"-", 1>;
public Ranking veryNegative = <"--", 0>;

public list[Ranking] allRankings = [excellent,
 									good,
									neutral,
									negative,
									veryNegative];

Ranking averageRanking(list[Ranking] rankings){
	if(rankings == []){
		return neutral;
	}
	int average = round(toReal(sum([r.val | r <- rankings]))
	 					/ toReal(size(rankings)));	
	return findRankingByValue(average);
}

/* The assertions are important to check for the validity of the request. since
we only have mappings from 0 - 4 we need to check for these bounds. The result of 
the mapping should be a singleton list. If this is not the case then the list is 
ambgious and there is an error in the implementation. */ 
Ranking findRankingByValue(int val){
	assert val >= 0 : "Ranking value must be \>= 0";
	assert val <= 4 : "Ranking value must be \<= 4";
	assert size([r | r <- [excellent, good, neutral, negative, veryNegative],
	 						r.val == val]) == 1 : "Ranking is ambigious";
	return [r | r <- [excellent, good, neutral, negative, veryNegative],
							r.val == val][0];
}
