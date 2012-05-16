/*
 Copyright (c) 2012, Ian Martins (ianxm@jhu.edu)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/
package tracker;

using Lambda;
using StringTools;
import neko.Lib;
import neko.Sys;
import neko.FileSystem;
import utils.Utils;
import altdate.Gregorian;

class Main
{
    private static var VERSION = "v0.17";

    public static var NO_DATA = Math.NaN;
    public static var IS_NO_DATA = Math.isNaN;

    private var dbFile     :String;
    private var metrics    :Set<String>;
    private var range      :Array<Gregorian>;
    private var val        :Float;
    private var cmd        :Command;
    private var valType    :ValType;
    private var groupType  :GroupType;
    private var graphType  :GraphType;
    private var fname      :String;
    private var tail       :Int;
    private var tag        :String;
    private var undoMode   :Bool;

    public function new(?u = false)
    {
        cmd = null;
        groupType = DAY;
        valType = TOTAL;
        graphType = LINE;
        metrics = new Set<String>();
        range = [null, null];
        undoMode = u;
    }

    public function run(args)
    {
        try {
            parseArgs(args);
            setDefaults();

            var worker = new Tracker(dbFile, metrics, range, undoMode);
            switch (cmd)
            {
            case INIT:       worker.init();
            case LIST:       worker.list();
            case HIST:       worker.hist(tail);
            case UNDO:       worker.undo();
            case SET:        worker.set(val);
            case INCR:       worker.incr(val);
            case REMOVE:     worker.remove();
            case CSV_EXPORT: worker.exportCsv(fname);
            case CSV_IMPORT: worker.importCsv(fname);
            case ADD_TAG:    worker.addTag(tag);
            case RM_TAG:     worker.rmTag(tag);
            case LIST_TAGS:  worker.listTags();
            case GRAPH:      worker.graph(fname, graphType, groupType, valType);
            default:         worker.view(cmd, groupType, valType, tail);
            }
            worker.close();
        } catch ( e:Dynamic ) {
            Lib.println("ERROR: " + e);
            //Lib.println(haxe.Stack.toString(haxe.Stack.exceptionStack()));
        }
    }

    private function parseArgs(args)
    {
        var arg = args.shift();
        switch( arg )                                       // process command first
        {
        case "init":    cmd = INIT;
        case "list":    cmd = LIST;
        case "hist":    cmd = HIST;
        case "undo":    cmd = UNDO;

        case "set":     cmd = SET;
        case "rm":      cmd = REMOVE;

        case "cal":     cmd = CAL;
        case "log":     cmd = LOG;
        case "export":  cmd = CSV_EXPORT;
        case "import":  { cmd = CSV_IMPORT; fname = args.shift(); }
        case "records": cmd = RECORDS;
        case "streaks": cmd = STREAKS;
        case "graph":   cmd = GRAPH;

        case "addtag":   { cmd = ADD_TAG; tag = args.shift(); }
        case "rmtag":    { cmd = RM_TAG; tag = args.shift(); }
        case "listtags": cmd = LIST_TAGS;

        case "help":      printHelp();
        case "-v",
            "--version":  printVersion();
        case "-h",
            "--help":     printHelp();

        default:        throw "the first argument must be a command (try -h for help)";
        }

        while( args.length>0 )                              // process options and metrics
        {
            arg = args.shift();
            switch( arg )
            {
            case "-d":                                      // date range
                {
                    arg = args.shift();
                    if( arg.indexOf("..")!=-1 )
                        range = arg.split("..").map(dateFix).array();
                    else
                    {
                        var date = dateFix(arg);
                        range = [date, date];
                    }
                }
            case "-o":        fname = args.shift();         // save image or csv file
            case "--all":     metrics.add("*");             // select all metrics
            case "--min":     throw "the min option has not been implemented yet";
            case "--repo":    dbFile = args.shift();        // set filename
            case "-v",
                "--version":  printVersion();
            case "-h",
                "--help":     printHelp();

            case "-by-day":      groupType = DAY;
            case "-by-week":     groupType = WEEK;
            case "-by-month":    groupType = MONTH;
            case "-by-year":     groupType = YEAR;
            case "-by-full":     groupType = FULL;

            case "-total":       valType = TOTAL;
            case "-count":       valType = COUNT;
            case "-avg-week":    valType = AVG_WEEK;
            case "-avg-month":   valType = AVG_MONTH;
            case "-avg-year":    valType = AVG_YEAR;
            case "-avg-full":    valType = AVG_FULL;
            case "-pct-week":    valType = PCT_WEEK;
            case "-pct-month":   valType = PCT_MONTH;
            case "-pct-year":    valType = PCT_YEAR;
            case "-pct-full":    valType = PCT_FULL;

            case "-line":     graphType = LINE;
            case "-bar":      graphType = BAR;
            case "-point":    graphType = POINT;

            default:                                        // else assume it is a metric
                if( StringTools.startsWith(arg, "=") )
                    if( cmd == SET )
                    {
                        val = Std.parseFloat(arg.substr(1)); // see if its a set val
                        if( Math.isNaN(val) )
                            throw "unrecognized option: " + arg;
                    }
                    else
                        throw "the '=VAL' option can only be used with a set command ";
                else if( StringTools.startsWith(arg, "+") )
                {
                    if( cmd == SET )
                    {
                        val = Std.parseFloat(arg.substr(1)); // see if its a decr val
                        if( Math.isNaN(val) )
                            throw "unrecognized option: " + arg;
                        cmd = INCR;
                    }
                    else
                        throw "the '+VAL' option can only be used with a set command ";
                }
                else if( StringTools.startsWith(arg, "-") )
                {
                    if( cmd == SET )
                    {
                        val = -1*Std.parseFloat(arg.substr(1)); // see if its a decr val
                        if( Math.isNaN(val) )
                            throw "unrecognized option: " + arg;
                        cmd = INCR;
                    }
                    else
                    {
                        tail = Std.parseInt(arg.substr(1));     // see if its a tail arg
                        if( tail == null )
                            throw "unrecognized option: " + arg;
                    }
                }
                else
                {
                    var path = neko.io.Path.directory(arg); // if run from haxelib, the last arg will be the haxelib dir
                    if( args.length==0 && FileSystem.exists( path ) && FileSystem.isDirectory( path ) ) 
                        Sys.setCwd( path );
                    else
                        metrics.add(arg);                   // it must be a metric
                }
            }
        }
    }

    // parse date strings
    // accept yyyy-mm-dd or yesterday or today[-N]
    private function dateFix(dateStr :String)
    {
        return if( dateStr.startsWith("yest") )
        {
            var day = Utils.today();
            day.day -= 1;
            day;
        }
        else if( dateStr.startsWith("tod") )
        {
            var day = Utils.today();
            var fields = dateStr.split("-");
            try {
                if( fields.length == 2 )
                    day.day -= Std.parseInt(fields[1]);
            } catch( e:String ) {
                throw "offset from today must be an integer";
            }
            day;
        }
        else
            Utils.dayFromString(dateStr);
    }


    // set defaults after args have been processed
    private function setDefaults()
    {
        if( cmd==SET && val==null )
            throw "you must specify a value";

                                                            // list metrics if no metrics specified
        if( metrics.isEmpty() && cmd!=INIT && cmd!=CSV_IMPORT && cmd!=LIST && cmd!=HIST && cmd!=UNDO && cmd!=LIST_TAGS  )
            throw "you must specify a metric";

                                                            // fix range if not specified
        if( range[0] == null && ( cmd==SET || cmd==INCR || cmd==REMOVE ) )
            range[0] = Utils.today();
        if( range[1] == null )
            range[1] = Utils.today();

        if( cmd == CAL )                                    // always cal by full month
        {
            if( range[0] == null )
                range[0] = Utils.today();
            range[0].day = 1;
            if( range[0] == range[1] )
                range[1] = range[0].toDate();
            range[1].month += 1;
            range[1].day = 0;
        }

        if( (valType==AVG_WEEK || valType==PCT_WEEK) && groupType==DAY )
        {
            Lib.println("WARNING: grouping by week");
            groupType = WEEK;
        }
        else if( (valType==AVG_MONTH || valType==PCT_MONTH) && (groupType==DAY || groupType==WEEK) )
        {
            Lib.println("WARNING: grouping by month");
            groupType = MONTH;
        }
        else if( (valType==AVG_YEAR || valType==PCT_YEAR) && (groupType==DAY || groupType==WEEK || groupType==MONTH) )
        {
            Lib.println("WARNING: grouping by year");
            groupType = YEAR;
        }
        else if( (valType==AVG_FULL || valType==PCT_FULL) )
        {
            Lib.println("WARNING: grouping by full duration");
            groupType = FULL;
        }

        if( dbFile == null )                                // use default repo
        {
            var home = Sys.environment().get("HOME");
            if( home == null )
                throw "you must set the HOME environment variable or specify the repo filename";
            dbFile = home + "/.tracker.db";
        }
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

commands:
  general:
    init           initialize a repository
    list           list existing metrics and date ranges
    undo           undo the last modify command used
    hist           list recently used modify commands
    help           show help

  modify repository:
    set SETVAL     set or increment a value
                   see SETVAL below
    rm             remove occurrences

  import/export:
    export         export data to csv format
                   this will write to stdout unless -o is given
    import FILE    import data from a csv file
                   with the columns: date,metric,value
                   read from stdin if FILE is '-'

  reporting:
    log            view log of occurrences
    cal            show calendar
    records        show high and low records
    streaks        show consecutive days with or without occurrences
    graph          draw graph (requires gnuplot)

  tags:
    addtag TAG     tag given metrics with TAG
    rmtag TAG      untag given metrics with TAG
    listtags       list all tags

options:
  general:
    -d RANGE       specify date range (see RANGE below)
    -o FILE        write graph image or csv export to a file
    -N             limit output to the last N items
                   this only affects the 'streaks', 'log', 'hist'
    --all          select all existing metrics
    --repo FILE    specify a repository filename
    --min VAL      min threshold to count as an occurrence
    -v, --version  show version
    -h, --help     show help

  date groupings for reports:
    (these are only used by the 'log' and 'graph' commands)
    -by-day        each day is separate (default)
    -by-week       group weeks together
    -by-month      group months together
    -by-year       group years together
    -by-full       group the full date range together

  values in reports:
    -total         total values (default)
    -count         count of occurrences
    -avg-week      average total per week
    -avg-month     average total per month
    -avg-year      average total per year
    -avg-full      average total for full date range
    -pct-week      percent of days with occurrences per week
    -pct-month     percent of days with occurrences per month
    -pct-year      percent of days with occurrences per year
    -pct-full      percent of days with occurrences of full date range

  graphs:
    -line          draw a line graph (default)
    -bar           draw a bar graph
    -point         draw a point graph

SETVAL:
  =N           set metrics to N
  +N           increment metrics by N
  -N           decrement metrics by N

RANGE:
  DATE         only the specified date
  DATE..       days from the given date until today
  ..DATE       days from the start of the data to the specified date
  DATE..DATE   days between specified dates (inclusive)

DATE:
  YYYY-MM-DD   specify a date
  today        specify day is today (default)
  yesterday    specify day is yesterday
  today-N      specify day is N days before today
  
examples:
  > tracker init
               initialize the default repository

  > tracker set -d yesterday jogging =2
               set jogging occurrence to 2 for yesterday

  > tracker set -d today bikecommute +1
               increase bikecommute metric by 1 for today

  > tracker rm bikecommute
               remove bikecommute occurrence for today

  > tracker log -d 2012-01-01.. bikecommute
               show a log of all bikecommute occurrences since jan 1, 2012 

  > tracker cal -d 2012-01-01.. wastedtime
               show wastedtime calendars for each month from jan 2012
               until the current month
");
        Sys.exit(0);
    }

    public static function main()
    {
        new Main().run(Sys.args());
    }
}

enum Command
{
    INIT;                                                   // initialize a db file
    LIST;                                                   // metrics list and duration
    HIST;                                                   // list recent commands
    UNDO;                                                   // undo last command
    SET;                                                    // set the value for a day
    INCR;                                                   // incrthe value for a day
    REMOVE;                                                 // clear a value for a day
    CAL;                                                    // show calendar
    LOG;                                                    // show log by day
    CSV_EXPORT;                                             // export to csv
    CSV_IMPORT;                                             // import from csv
    RECORDS;                                                // view report
    STREAKS;                                                // show streaks
    GRAPH;                                                  // show graph
    ADD_TAG;                                                // add a tag
    RM_TAG;                                                 // remove a tag
    LIST_TAGS;                                              // list all tags
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
    AVG_WEEK;                                               // average values by week
    AVG_MONTH;                                              // average values by month
    AVG_YEAR;                                               // average values by year
    AVG_FULL;                                               // average all values
    PCT_WEEK;                                               // percent of occurrence days per week
    PCT_MONTH;                                              // percent of occurrence days per month
    PCT_YEAR;                                               // percent of occurrence days per year
    PCT_FULL;                                               // percent of occurrence days for full duration
}

enum GraphType
{
    LINE;                                                  // line graph
    BAR;                                                   // bar graph
    POINT;                                                 // point graph
}
