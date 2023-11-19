module Ranking::RiskRanges

import Ranking::Ranking;

// Risks are taken from the Paper
alias RiskOverview = tuple[int low, int moderate, int high, int veryHigh];
alias RiskOverviewFloat = tuple[num low, num moderate, num high, num veryHigh];

// The thresholds for each of the ranking categories.
// Example in CC maximum relative volume 25% = moderate risk
alias RiskThreshold = tuple[Ranking rankLevel, int low, int moderate, int high, int veryHigh];
alias RiskThresholdFloat = tuple[Ranking rankLevel, num low, num moderate, num high, num veryHigh];

