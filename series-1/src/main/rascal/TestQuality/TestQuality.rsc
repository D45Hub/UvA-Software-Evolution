module TestQuality::TestQuality

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Ranking::Ranking;

import IO;

import Set;
import List;
import String;

import util::Math;

public RiskThreshold veryPositiveTestCases = <excellent, 300, -1>;
public RiskThreshold positiveTestCases = <good, 200, 300>;
public RiskThreshold neutralTestCases = <neutral, 100, 200>;
public RiskThreshold negativeTestCases = <negative, 50, 100>;
public RiskThreshold veryNegativeTestCases = <veryNegative, 0, 50>;

/* Basic Idea: Regex to get all classes inside the reserved directory "test" 
and then check the assertion statement in each method. but this metric is not 
very clean. */ 

private int getAssertions(Declaration testClass) {
 
 	int assertions = 0;

	visit (testClass) {
        case \assert(_): assertions += 1;
        case \assert(_, _): assertions += 1;
        case \methodCall(_, /assert/, _): assertions += 1;
        case \methodCall(_, _, /assert/, _): assertions += 1;
    }
    
    return assertions;
}

