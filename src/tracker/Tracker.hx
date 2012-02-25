package tracker;

using Lambda;
import neko.Lib;
import neko.Sys;
import neko.io.File;
import neko.FileSystem;
import neko.db.Sqlite;
import neko.db.Connection;
import neko.db.Manager;

import tracker.Main;
import utils.Utils;

class Tracker
{
    private var dbFile  :String;
    private var metrics :List<String>;
    private var range   :Array<String>;
    private var db      :Connection;

    public function new(f, m, r)
    {
        dbFile = f;
        metrics = m;
        range = r;
    }

    // create db file
    public function init()
    {
        if( FileSystem.exists(dbFile) )
            throw "cannot init an existing repository";
        db = Sqlite.open(dbFile);
        Lib.println("creating repository: " + neko.FileSystem.fullPath(dbFile));
        db.request("CREATE TABLE occurrence ("
                   + "metric TEXT NOT NULL, "
                   + "date TEXT NOT NULL, "
                   + "value INT NOT NULL);");
    }

    // open db file
    private function connect()
    {
        if( !FileSystem.exists(dbFile) )
            throw "repository doesn't exist, you must run 'init' first";
        db = Sqlite.open(dbFile);
        neko.db.Manager.cnx = db;
        neko.db.Manager.initialize();
    }

    // get list of existing metrics
    public function list()
    {
        connect();
        if( Occurrence.manager.count() == 0 )
        {
            Lib.println("No metrics found");
            return;
        }

        var allMetrics = getAllMetrics();

        Lib.println("Current Metrics:");
        for( metric in allMetrics )
            Lib.println("- "+ metric);
    }

    // output all metrics as a csv
    public function exportCsv(fname)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var fout = if( fname != null )
        {
            if( FileSystem.exists(fname) )
                throw "file exists: " + FileSystem.fullPath(fname);
            else
                try {
                    File.write(fname);
                } catch( e:Dynamic ) {
                    throw "couldn't open output file: " + fname;
                }
        }
        else
            File.stdout();

        var occurrences = selectRange(range, false);
        fout.writeString("date,metric,value\n");
        for( rr in occurrences )
            fout.writeString(rr.date +","+ rr.metric +","+ rr.value +"\n");
        fout.close();
    }

    // import metrics from a csv
    public function importCsv(fname)
    {
        connect();

        if( !FileSystem.exists(fname) )
            throw "file not found: " + fname;
        var fin = File.read(fname);
        try
        {
            while( true )
            {
                var line = fin.readLine();
                var fields = line.split(",").map(function(ii) return StringTools.trim(ii)).array();
                var dayStr;
                try {
                    dayStr = Utils.dayStr(fields[0]);
                } catch( e:String ) {
                    Lib.println("bad date, skipping line: " + line);
                    continue;
                }
                var val = Std.parseInt(fields[2]);
                if( val == null )
                {
                    Lib.println("bad value, skipping line: " + line);
                    continue;
                }
                setOrUpdate(fields[1], dayStr, val);
            }
        } catch( e:haxe.io.Eof ) {
        }
        fin.close();
    }

    // run the report generator to view the data
    public function view(cmd)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var reportGenerator = new ReportGenerator(range);
        reportGenerator.setReport(cmd);
        var occurrences = selectRange(range);

        if( range[0] != null )                              // start..
            reportGenerator.include(Utils.day(range[0]), Main.NO_DATA);

        for( occ in occurrences )
            reportGenerator.include(Utils.day(occ.date), occ.value);

                                                            // ..end (cant be null)
        reportGenerator.include(Utils.day(range[1]), Main.NO_DATA);

        reportGenerator.print();
    }

    // increment values
    public function incr()
    {
        connect();
        for( metric in metrics )
        {
            var dayStr = range[0];
            do
            {
                var occ = Occurrence.manager.getWithKeys({metric: metric, date: dayStr});
                if( occ != null )
                {
                    occ.value++;
                    occ.update();
                    Lib.println("set " + occ.metric + " to " + occ.value + " for " + dayStr);
                }
                else
                    setNew( metric, dayStr, 1 );

                dayStr = Utils.dayToStr(Utils.dayShift(Utils.day(dayStr), 1));
            } while( range[1]!=null && Utils.dayDelta(Utils.day(dayStr), Utils.day(range[1])) >= 0 );
        }
    }

    // set values
    public function set(val)
    {
        connect();
        for( metric in metrics )
        {
            var dayStr = range[0];
            do
            {
                setOrUpdate(metric, dayStr, val);
                dayStr = Utils.dayToStr(Utils.dayShift(Utils.day(dayStr), 1));
            } while( range[1]!=null && Utils.dayDelta(Utils.day(dayStr), Utils.day(range[1])) >= 0 );
        }
    }

    private function setOrUpdate(metric, dayStr, val)
    {
        var occ = Occurrence.manager.getWithKeys({metric: metric, date: dayStr});
        if( occ != null )
        {
            occ.value = val;
            occ.update();
            Lib.println("set " + metric + " to " + val + " for " + dayStr);
        }
        else
            setNew(metric, dayStr, val);
    }

    private function setNew(metric, dayStr, val)
    {
        var occ = new Occurrence();
        occ.metric = metric;
        occ.date = dayStr;
        occ.value = val;
        occ.insert();
        Lib.println("set " + metric + " to " + val + " for " + dayStr);
    }

    // clear values
    public function clear()
    {
        connect();
        var occurrences = selectRange(range, false);
        for( occ in occurrences )
        {
            occ.delete();
            Lib.println("deleted " + occ.metric + " for " + occ.date);
        }
    }

    private function checkMetrics()
    {
        if( Lambda.exists(metrics, function(ii) return ii=="*") )
            metrics = Lambda.list(getAllMetrics());
        else
        {
            var allMetrics = getAllMetrics();
            for( metric in metrics )
                if( !allMetrics.has(metric) )
                    throw "unknown metric: " + metric;
        }
    }

    // get a set of all metrics in the db
    private function getAllMetrics()
    {
        var allMetrics = new Set<String>();
        var occurrences = Occurrence.manager.search({}, false);
        for( rr in occurrences )
            allMetrics.add(rr.metric);
        return allMetrics;
    }

    // select a date range from the db
    private function selectRange(range, ?shouldCombine = true)
    {
        if( Occurrence.manager.count()==0 )
        {
            Lib.println("No metrics found");
            Sys.exit(0);
        }

        var select = new StringBuf();
        select.add("SELECT ");
        select.add((shouldCombine) ? "date, sum(value) as value" : "*");
        select.add(" FROM occurrence ");
        select.add("WHERE ("+ metrics.map(function(ii) return "metric='"+ii+"'").join(" or ") +")");
        if( range[0]!=null )                               // start..
            select.add(" AND date >= '"+ range[0] +"'");
        if( range[1]!=null )                               // ..end
            select.add(" AND date <= '"+ range[1] +"'");
        select.add((shouldCombine) ? " GROUP BY date" : " ");
        select.add(" ORDER BY date");

        //trace("select: " + select);
        return Occurrence.manager.objects(select.toString(), false);
    }

    // close db file
    public function close()
    {
        neko.db.Manager.cleanup();
        db.close();
    }
}
