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
import neko.Lib;
import neko.Sys;
import neko.FileSystem;
import utils.Utils;
import altdate.Gregorian;

class Main
{
    private static var VERSION = "v0.9";

    public static var NO_DATA = Math.NaN;
    public static var IS_NO_DATA = Math.isNaN;

    private var dbFile     :String;
    private var metrics    :List<String>;
    private var range      :Array<Gregorian>;
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
            case SET:        worker.set(val);
            case INCR:       worker.incr(val);
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

        var arg = args.shift();
        switch( arg )                                       // process command first
        {
        case "init":    cmd = INIT;
        case "info":    cmd = INFO;

        case "set":     cmd = SET;
        case "rm":      cmd = REMOVE;

        case "cal":     cmd = CAL;
        case "log":     cmd = LOG;
        case "export":  cmd = CSV_EXPORT;
        case "import":  { cmd = CSV_IMPORT; fname = args.shift(); }
        case "records": cmd = RECORDS;
        case "streaks": cmd = STREAKS;
        case "graph":   throw "graphs have not been implemented yet";
        case "help":    printHelp();
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
                    var dateFix = function(ii) {
                        return switch(ii){
                        case "today":     Utils.today();
                        case "yesterday": Utils.dayShift(Utils.today(),-1);
                        default:          Utils.dayFromString(ii);
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
                "--help":     printHelp();

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

    // set defaults after args have been processed
    private function setDefaults()
    {
        if( metrics.isEmpty() && cmd!=INIT && cmd!=CSV_IMPORT ) // list metrics if no metrics specified
            cmd = INFO;

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
            range[1].month += 1;
            range[1].day = 0;
        }

        if( dbFile == null )                                // use default repo
            dbFile = Sys.environment().get("HOME") + "/.tracker.db";

        if( fname != null )
            if( cmd == GRAPH )
                Lib.println("saving graph to: " + fname);
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
    set            set or increment a value
                   see 'set command options' below
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
  set command options:
    =N             set metrics to N
    +N             increment metrics by N
    -N             decrement metrics by N

  general:
    -d RANGE       specify date range (see RANGE below)
    -o FILE        write graph image to a file
    -N             limit output to the last N items
                   this only affects the 'streaks' and 'log' commands
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
  YYYY-MM-DD   specify a date
  today        specify day is today (default)
  yesterday    specify day is yesterday
  
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
        new Main().run();
    }
}

enum Command
{
    INIT;                                                   // initialize a db file
    INFO;                                                   // metrics list and duration
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
