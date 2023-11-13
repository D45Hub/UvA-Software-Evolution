module Ratings::Stability

import lang::java::m3::Core;
import lang::java::m3::AST;

import UnitInterfacing::UnitInterfacingHelper;
import Ranking::Ranking;
import Ranking::RiskRanges;

// Unit interfacing, Module Coupling

// TODO THINK ABOUT MODULE COUPLING THEN MAYBE ALSO DELETE PROJECTMODEL IF NOT NEEDED FROM PARAMS...
public Ranking getStabilityRanking(M3 projectModel, list[Declaration] methodUnits) {

    // TODO THINK ABOUT RATING...
    RiskThreshold unitInterfacingRisk = generateRiskThreshold(methodUnits);

    return getStabilityRanking(unitInterfacingRisk);
}

public Ranking getStabilityRanking(RiskThreshold unitInterfacingRisk) {
    list[Ranking] metricRankings = [unitInterfacingRisk.rankLevel];

    return averageRanking(metricRankings);
}