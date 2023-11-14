module Ranking::Ranking

import util::Math;
import List;

/* An alias in Rascal is used to rename a "type" to something more meaningful 
In order to make our code more meaningful, we decided to use it.
c.f. https://www.rascal-mpl.org/docs/Rascal/Declarations/Alias/ 
The generic type of the ranking is derived from the paper itself (see complexity ranking
for e.g. in C. "Complexity per unit"). In order to sort the 
*/ 
alias Ranking = tuple[str name,int val];

/* 
To be able to provide the concrete ranking limits, we declare another type with the 
ranking and the lower and upper bounds (e.g. for a ++ rank in duplication it is 0 - 3 %)
*/ 
alias RankingLimits = tuple[Ranking ranking, num lower, num upper];

/* To calculate an average score in the end, we use numbers from 0 - 4 and map 
them accordingly to the values from "veryNegative to excellent"*/ 
public Ranking excellent = <"++", 4>;
public Ranking good = <"+", 3>;
public Ranking neutral = <"o", 2>;
public Ranking negative = <"-", 1>;
public Ranking veryNegative = <"--", 0>;

Ranking averageRanking(list[Ranking] rankings){
	if(rankings == []){
		return neutral;
	}
	int average = round(toReal(sum([r.val | r <- rankings])) / toReal(size(rankings)));	
	return findRankingByValue(average);
}

/* The assertions are important to check for the validity of the request. since
we only have mappings from 0 - 4 we need to check for these bounds. The result of 
the mapping should be a singleton list. If this is not the case then the list is 
ambgious and there is an error in the implementation. */ 
Ranking findRankingByValue(int val){
	assert val >= 0 : "Ranking value must be \>= 0";
	assert val <= 4 : "Ranking value must be \<= 4";
	assert size([r | r <- [excellent, good, neutral, negative, veryNegative], r.val == val]) == 1 : "Ranking is ambigious";
	return [r | r <- [excellent, good, neutral, negative, veryNegative], r.val == val][0];
}

str rankingToString(Ranking ranking){
	return ranking.name;
}

/* Get the overall Ranking for the piece of code */ 
RankingLimits getRankingLimits(num rankingValue, list[RankingLimits] rankings){
	assert size(rankings) > 0: "You have to provide at least one bound ranking";
	list[RankingLimits] validRankings =  [ranking | ranking <- rankings, round(rankingValue) < ranking.upper];
	return last(validRankings);
}

/* Giving the grade for the whole sysem */ 
