module Configuration

public bool CURLY_BRACKETS_ARE_CODE = true;

public int DUPLICATION_THRESHOLD = 6;
public bool DUPLICATON_USE_PRUNING = true;
public bool DUPLICATON_COUNT_ORIGINALS = true;
public bool DUPLICATON_RESPECT_FILE_PAGE_BREAKS = true;

public str UNIQUE_LINES_TOKEN = "%%%|||RASCAL_UNIQUE_LINES|||%%%%";
public str COMMENT_START_TOKEN = "%%%|||RASCAL_COMMENT_START|||%%%";
public str COMMENT_END_TOKEN = "%%%|||RASCAL_COMMENT_END|||%%%";
public str PAGE_BREAK_TOKEN = "%%%|||RASCAL_PAGE_BREAK|||%%%%";

public str TEST_CLASS_KEYWORD = "TestCase";

public loc CSV_OUTPUT = |file:///tmp/output.csv|;

public bool DEBUG_MODE = true;