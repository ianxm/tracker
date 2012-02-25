package tracker;

using Lambda;
import neko.Lib;
import neko.Sys;
import neko.FileSystem;
import utils.Utils;

class Main
{
    public static var NO_DATA = -9999;
    private static var VERSION = "v0.4";

    private var dbFile   :String;
    private var metrics  :List<String>;
    private var range    :Array<String>;
    private var val      :Int;
    private var cmd      :Command;
    private var fname    :String;
    private var tail     :Int;

    public function new()
    {
        cmd = RECORDS;
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
            case LIST:       worker.list();
            case INCR:       worker.incr();
            case SET:        worker.set(val);
            case CLEAR:      worker.clear();
            case CSV_EXPORT: worker.exportCsv(fname);
            case CSV_IMPORT: worker.importCsv(fname);
            default:         worker.view(cmd, tail);
            }
            worker.close();
        } catch ( e:Dynamic ) {
            Lib.println("ERROR: " + e);
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
            case "list":        cmd = LIST;
            case "incr":        cmd = INCR;
            case "set":         { cmd = SET; val = Std.parseInt(args.shift()); }
            case "clear":       cmd = CLEAR;
            case "cal":         cmd = CAL;
            case "log",
                "dlog":         cmd = DLOG;
            case "wlog":        cmd = WLOG;
            case "mlog":        cmd = MLOG;
            case "ylog":        cmd = YLOG;
            case "export":      cmd = CSV_EXPORT;
            case "import":      { cmd = CSV_IMPORT; fname = args.shift(); }
            case "count":       cmd = COUNT;
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
        if( metrics.isEmpty() && cmd!=INIT && cmd!=CSV_IMPORT ) // list metrics if no metrics specified
            cmd = LIST;

        if( range[0] == null && ( cmd==INCR || cmd==SET ) ) // fix range if not specified
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

        if( cmd == SET && val == null )                     // check that set has a val
            throw "set must be followed by a number";

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
usage: tracker [command] [options] [metric [metric..]] 

if no command is given, tracker will show usage help.
if no date range is specified, the range is all days. 
if no metric is given, tracker will list all metrics found.

commands:
  init           initialize a repository
  list           show list of existing metrics
  incr           increment a value
  set VAL        set a value
  clear          remove occurrences
  dlog,log       show a log by day
  wlog           show a log by week
  mlog           show a log by month
  ylog           show a log by year
  export         export data to csv format
                 this will write to stdout unless -o is given
  import FILE    import data from a csv file
                 with the columns: date,metric,value
  count          count occurrences
  cal            show calendar view
  records        show high and low records
  streaks        show consecutive days with or without occurrences
  graph          draw a graph
  help           show help
  
options:
  -d RANGE       specify date range (see details below)
  -o FILE        write graph image to a file
  -N             limit output to the last N items
                 this affects streaks and the log commands
  --all          select all existing metrics
  --repo FILE    specify a repository filename
  --min VAL      min threshold
  -v, --version  show version
  -h, --help     show help

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
               initialize the default repo

  > tracker incr today bikecommute
               increments bikecommute metric for today

  > tracker clear bikecommute
               clear all bikecommute occurrences

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
    LIST;                                                   // list existing metrics
    INCR;                                                   // increment a day
    SET;                                                    // set the value for a day
    CLEAR;                                                  // clear a value for a day
    CAL;                                                    // show calendar
    DLOG;                                                   // show log by day
    WLOG;                                                   // show log by week
    MLOG;                                                   // show log by month
    YLOG;                                                   // show log by year
    CSV_EXPORT;                                             // export to csv
    CSV_IMPORT;                                             // import from csv
    COUNT;                                                  // count occurrences
    RECORDS;                                                // view report
    STREAKS;                                                // show streaks
    GRAPH;                                                  // show graph
}
