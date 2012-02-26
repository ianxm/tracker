package tracker;

using Lambda;
import neko.Lib;
import neko.Sys;
import neko.FileSystem;
import utils.Utils;

class Main
{
    public static var NO_DATA = -9999;
    private static var VERSION = "v0.6";

    private var dbFile     :String;
    private var metrics    :List<String>;
    private var range      :Array<String>;
    private var val        :Float;
    private var cmd        :Command;
    private var valType    :ValType;
    private var groupType  :GroupType;
    private var fname      :String;
    private var tail       :Int;

    public function new()
    {
        cmd = null;
        groupType = DAY;
        valType = TOTAL;
        metrics = new List<String>();
        range = [null, null];
    }

    public function run()
    {
        try {
            parseArgs();
            setDefaults();

            var worker = new Tracker(dbFile, metrics, range);
            switch (cmd)
            {
            case INIT:       worker.init();
            case INFO:       worker.info();
            case INCR:       worker.incr(val);
            case SET:        worker.set(val);
            case REMOVE:     worker.remove();
            case CSV_EXPORT: worker.exportCsv(fname);
            case CSV_IMPORT: worker.importCsv(fname);
            default:         worker.view(cmd, groupType, valType, tail);
            }
            worker.close();
        } catch ( e:Dynamic ) {
            Lib.println("ERROR: " + e);
            //Lib.println(haxe.Stack.toString(haxe.Stack.exceptionStack()));
        }
    }

    private function parseArgs()
    {
        var args = Sys.args();
        while( args.length>0 )
        {
            var arg = args.shift();
            switch( arg )
            {
            case "init":        cmd = INIT;
            case "info":        cmd = INFO;

            case "incr":        { cmd = INCR; val = Std.parseFloat(args.shift()); }
            case "set":         { cmd = SET; val = Std.parseFloat(args.shift()); }
            case "rm":          cmd = REMOVE;

            case "cal":         cmd = CAL;
            case "log":         cmd = LOG;
            case "export":      cmd = CSV_EXPORT;
            case "import":      { cmd = CSV_IMPORT; fname = args.shift(); }
            case "records":     cmd = RECORDS;
            case "streaks":     cmd = STREAKS;
            case "graph":       throw "graphs have not been implemented yet";

            case "-d":                                  // date range
                {
                    arg = args.shift();
                    var dateFix = function(ii) {
                        return switch(ii){
                        case "today":     Utils.dayStr(Date.now());
                        case "yesterday": Utils.dayStr(Utils.dayShift(Date.now(),-1));
                        default:          Utils.dayStr(ii);
                        }
                    }
                    if( arg.indexOf("..")!=-1 )
                        range = arg.split("..").map(dateFix).array();
                    else
                    {
                        var date = dateFix(arg);
                        range = [date, date];
                    }
                }
            case "-o":        fname = args.shift();         // save image file
            case "--all":     metrics.add("*");             // select all metrics
            case "--min":     throw "the min option has not been implemented yet";
            case "--repo":    dbFile = args.shift();        // set filename
            case "-v",
                "--version":  printVersion();
            case "-h",
                "--help",
                "help":       printHelp();

            case "-day":      groupType = DAY;
            case "-week":     groupType = WEEK;
            case "-month":    groupType = MONTH;
            case "-year":     groupType = YEAR;
            case "-full":     groupType = FULL;

            case "-total":    valType = TOTAL;
            case "-count":    valType = COUNT;
            case "-avg":      valType = AVG;
            case "-percent":  valType = PERCENT;

            default:                                        // else assume it is a metric
                if( StringTools.startsWith(arg, "-") )
                {
                    tail = Std.parseInt(arg.substr(1));     // see if its a tail arg
                    if( tail == null )
                        throw "unrecognized option: " + arg;
                }
                else
                    metrics.add(arg);
            }
        }
    }

    // set defaults after args have been processed
    private function setDefaults()
    {
        if( cmd == null )
            throw "a command must be specified (try -h for help)";

        if( cmd == SET && Math.isNaN(val) )                 // check that set has a val
            throw "set must be followed by a number";

        if( cmd == INCR && Math.isNaN(val) )                // check that incr has a val
            throw "incr must be followed by a number";

        if( metrics.isEmpty() && cmd!=INIT && cmd!=CSV_IMPORT ) // list metrics if no metrics specified
            cmd = INFO;

                                                            // fix range if not specified
        if( range[0] == null && ( cmd==INCR || cmd==SET || cmd==REMOVE ) )
            range[0] = Utils.dayStr(Date.now());
        if( range[1] == null )
            range[1] = Utils.dayStr(Date.now());

        if( cmd == CAL )                                    // always cal by full month
        {
            var r0 = (range[0]==null) ? Utils.day(Date.now()) : Utils.day(range[0]);
            var r1 = Utils.day(range[1]);
            range[0] = Utils.dayStr(new Date(r0.getFullYear(), r0.getMonth(), 1, 0, 0, 0));
            range[1] = Utils.dayStr(new Date(r1.getFullYear(), r1.getMonth()+1, 0, 0, 0, 0));
        }

        if( dbFile == null )                                // use default repo
            dbFile = Sys.environment().get("HOME") + "/.tracker.db";

        if( fname != null )
            if( cmd == GRAPH )
                Lib.println("saving graph to: " + fname);
            else if( cmd == CSV_IMPORT )
                Lib.println("reading: " + FileSystem.fullPath(fname));
            else if( cmd == CSV_EXPORT )
                Lib.println("writing csv to: " + fname);
    }

    private static function printVersion()
    {
        Lib.println("tracker "+ VERSION);
        Sys.exit(0);
    }

    private static function printHelp()
    {
        Lib.println("tracker "+ VERSION);
        Lib.println("
usage: tracker command [options] [metric [metric..]]

    if no date range is specified, the range is all days. 
    if no metric is given, tracker will list all metrics found.

commands:
  general:
    init           initialize a repository
    info           list existing metrics and date ranges
    help           show help

  modify repository:
    incr VAL       increment a value
    set VAL        set a value
    rm             remove occurrences

  import/export:
    export         export data to csv format
                   this will write to stdout unless -o is given
    import FILE    import data from a csv file
                   with the columns: date,metric,value

  reporting:
    log            view log of occurrences
    cal            show calendar
    records        show high and low records
    streaks        show consecutive days with or without occurrences
    graph          draw graph (requires gnuplot)
  
options:
  general:
    -d RANGE       specify date range (see RANGE below)
    -o FILE        write graph image to a file
    -N             limit output to the last N items
                   this affects 'streaks' and the log commands
    --all          select all existing metrics
    --repo FILE    specify a repository filename
    --min VAL      min threshold to count as an occurrence
    -v, --version  show version
    -h, --help     show help

  date groupings for reports:
    (these are only used by the 'log' and 'graph' commands)
    -day           each day is separate (default)
    -week          group weeks together
    -month         group months together
    -year          group years together
    -full          group the full date range together

  values in reports:
    -total         total values (default)
    -count         count of occurrences
    -avg           average values by duration
    -percent       show values as the percent of occurrence of duration

RANGE:
  DATE         only the specified date
  DATE..       days from the given date until today
  ..DATE       days from the start of the data to the specified date
  DATE..DATE   days between specified dates (inclusive)

DATE:
  today        specify day is today (default)
  yesterday    specify day is yesterday
  YYYY-MM-DD   specify a date
  
examples:
  > tracker init
               initialize the default repository

  > tracker incr today bikecommute
               increments bikecommute metric for today

  > tracker rm bikecommute
               remove all bikecommute occurrences

  > tracker log -d 2012-01-01.. bikecommute
               show a log of all bikecommute occurrences since jan 1, 2012 

  > tracker set -d yesterday --val 2 jogging
               set jogging occurrence to 2 for yesterday

  > tracker cal -d 2012-01-01.. wastedtime
               show wastedtime calendars for each month from jan 2012
               untill the current month
");
        Sys.exit(0);
    }

    public static function main()
    {
        new Main().run();
    }
}

enum Command
{
    INIT;                                                   // initialize a db file
    INFO;                                                   // metrics list and duration
    INCR;                                                   // increment a day
    SET;                                                    // set the value for a day
    REMOVE;                                                 // clear a value for a day
    CAL;                                                    // show calendar
    LOG;                                                    // show log by day
    CSV_EXPORT;                                             // export to csv
    CSV_IMPORT;                                             // import from csv
    RECORDS;                                                // view report
    STREAKS;                                                // show streaks
    GRAPH;                                                  // show graph
}

enum GroupType
{
    DAY;                                                    // group each day separately
    WEEK;                                                   // group by week
    MONTH;                                                  // group by month
    YEAR;                                                   // group by year
    FULL;                                                   // group everything together
}

enum ValType
{
    TOTAL;                                                  // total values
    COUNT;                                                  // count occurrences
    AVG;                                                    // average values by num days
    PERCENT;                                                // percent of count of num days
}
