module Ratings::Stability

import lang::java::m3::Core;
import lang::java::m3::AST;

import UnitInterfacing::UnitInterfacingHelper;
import Ranking::Ranking;

// Unit interfacing, Module Coupling

// TODO THINK ABOUT MODULE COUPLING THEN MAYBE ALSO DELETE PROJECTMODEL IF NOT NEEDED FROM PARAMS...
public Ranking getStabilityRanking(M3 projectModel, list[Declaration] methodUnits) {

    // TODO THINK ABOUT RATING...
    //list[UnitInterfacingComplexityValue] unitInterfacingValues = getUnitInterfacingValues(methodUnits);
    //list[Ranking] metricRankings = [unitInterfacingValues.rankingType];

    //return averageRanking(metricRankings);
    return undefined;
}