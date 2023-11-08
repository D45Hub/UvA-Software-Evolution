module GeneralHelper::ReportHelper

import lang::csv::IO;


alias ResultRelation = rel[str metric,str result];

void getResultRelation (ResultRelation resultRelation) {
    writeCSV(#ResultRelation, resultRelation, |tmp:///ex1a.csv|);
}

