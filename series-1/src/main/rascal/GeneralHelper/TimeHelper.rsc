module GeneralHelper::TimeHelper

import util::Benchmark;
import IO;
import util::Math;

public map[str, int] measures = ();

void printDebug(value arg){
	iprintln(arg);
}

void startMeasure(str measureKey){
	measures[measureKey] = realTime(); 
	printDebug("START: <measureKey>");
}

void stopMeasure(str measureKey){
	if(measureKey in measures == false){
		printDebug("Measure key not in storage.");
		return;
	}
	
	int measure = measures[measureKey];
	num seconds = toReal( realTime() - measure) / toReal(1000);
	
	printDebug("FINISHED: <measureKey> after <seconds>s");
}