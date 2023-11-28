module Helper::BenchmarkHelper


import util::Benchmark;
import IO;
import util::Math;

public map[str, int] measures = ();

void printDebug(value arg){
	iprintln(arg);
}

str startBenchmark(str benchmarkKey){
	measures[benchmarkKey] = realTime(); 
	printDebug("START: <benchmarkKey>");
	return toString(measures[benchmarkKey]);
}

str stopBenchmark(str benchmarkKey){
	if(benchmarkKey in measures == false){
		printDebug("Measure key not in storage.");
		return;
	}
	
	int measure = measures[benchmarkKey];
	num seconds = toReal( realTime() - measure) / toReal(1000);
	
	printDebug("FINISHED: <benchmarkKey> after <seconds>s");
	return toString(realTime());
}