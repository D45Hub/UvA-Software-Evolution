module Main

import lang::java::m3::Core;
import lang::java::m3::AST;

import IO;
import List;
import Set;
import String;
import Map;

int main(int testArgument=5) {
    println("argument: <testArgument>");
    return testArgument;
}

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}

int getNumberOfInterfaces(list[Declaration] asts){
    int interfaces = 0;
    visit(asts){
    case \interface(_, _, _, _): interfaces += 1;
    }
    return interfaces;
}

int getNumberOfForLoops(list[Declaration] asts){
    int forLoops = 0;
    visit(asts){
    case \for(_, _, _, _): forLoops += 1;
    }
    return forLoops;
}

tuple[int, list[str]] mostOccurringVariable(list[Declaration] asts) {

    map[str, int] locationMap = ();

    visit(asts){
        case \variable(name, _): {
            if(name in locationMap) {
                locationMap[name] += 1;
            } else {
                locationMap[name] = 1;
            }
        }
    }

    int maxVal = max([locationMap[key] | key <- domain(locationMap)]);

    list[str] mostOccurring = [name | name <- domain(locationMap), locationMap[name] == maxVal];

    return <maxVal, mostOccurring>;
}

// Or even using distribution function. :D
tuple[int, list[str]] mostOccurringNumber(list[Declaration] asts) {

    map[str, int] locationMap = ();

    visit(asts){
        case \number(str name): locationMap[name] ? 0 += 1;
    }

    int maxVal = max([locationMap[key] | key <- domain(locationMap)]);

    list[str] mostOccurring = [name | name <- domain(locationMap), locationMap[name] == maxVal];

    return <maxVal, mostOccurring>;
}

list[loc] findNullReturned(list[Declaration] asts){
    // := is pattern match operator which looks for this return thing.
    return [e.src | /\return(e:\null()) := asts];
}


/*tuple[int, list[str]] mostOccurringVariable(loc projectLocation){
    M3 model = createM3FromMavenProject(projectLocation);

    //println(model.containment);
    //list[Declaration] asts = getASTs(projectLocation);
    set[loc] numberOfVariables = {e | <e,_> <- model.declarations, isVariable(e)};
    map[loc, int] locationMap = ();

    for (loc location <- numberOfVariables) {
        if (locationMap[location] == null) {
            locationMap[location] = 0;
        }else {

        locationMap[location] = locationMap[location] + 5; //size([item | item <- numberOfVariables, item == location]);
        }
    }

    println(locationMap);
    list[str] testList = [];
    int testInt = 1;
    return <testInt, testList>;
}*/

/*tuple[int, list[str]] mostOccurringNumber(list[Declaration] asts){
    tuple[int amount, list[str] numbers] tuple = <0, ["string"]>;
    visit(asts){
    case int name(_,_): tuple += ;
    }
    return tuple;
}*/

test bool numberOfInterfaces() {
return getNumberOfInterfaces(getASTs(|file:///C:/SomeFilePath|)) == 1;
}