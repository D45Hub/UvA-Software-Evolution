module Tests::Volume::TestManYears

import Volume::ManYears;

bool assertMY(int lines, MYRanking expectedRanking){
	return getManYearsRanking(lines).rankingType == expectedRanking.rankingType;
}

test bool shouldBeExcellentMYRanking(){
	return 	assertMY(0, excellentMYRanking) && 
			assertMY(66000 - 1, excellentMYRanking) && 
			assertMY(66000, excellentMYRanking) == false;
}

test bool shouldBeGoodMYRanking(){
	return 	assertMY(66000, goodMYRanking) && 
			assertMY(246000 - 1, goodMYRanking);
}

test bool shouldBeNeutralMYRanking(){
	return 	assertMY(246000, neutralMYRanking) && 
			assertMY(665000 - 1, neutralMYRanking);
}

test bool shouldBeNegativeMYRanking(){
	return 	assertMY(665000, negativeMYRanking) && 
			assertMY(1310000 - 1, negativeMYRanking);
}

test bool shouldBeVeryNegativeMYRanking(){
	return 	assertMY(1310000, veryNegativeMYRanking) && 
			assertMY(99999999999, veryNegativeMYRanking);
}