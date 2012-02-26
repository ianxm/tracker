package tracker;

using Lambda;
using StringTools;
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
        db.request("CREATE TABLE metrics (" +
                   "id INTEGER PRIMARY KEY, " +
                   "name TEXT UNIQUE NOT NULL);");
        db.request("CREATE TABLE occurrences (" +
                   "metricId INTEGER NOT NULL REFERENCES metric (id) ON DELETE SET NULL, " +
                   "date DATE NOT NULL, " +
                   "value REAL NOT NULL, " +
                   "CONSTRAINT key PRIMARY KEY (metricId, date));");
        db.request("CREATE VIEW full AS SELECT " +
                   "metrics.id as metricId, metrics.name as metric, occurrences.date, occurrences.value " +
                   "from metrics, occurrences " +
                   "where occurrences.metricId=metrics.id;");
    }

    // open db file
    private function connect()
    {
        if( !FileSystem.exists(dbFile) )
            throw "repository doesn't exist, you must run 'init' first";
        db = Sqlite.open(dbFile);
    }

    // get list of existing metrics
    public function info()
    {
        connect();
        var allMetrics = getAllMetrics();
        if( allMetrics.isEmpty() )
        {
            Lib.println("No metrics found");
            return;
        }

        var nameWidth = allMetrics.fold(function(name,width:Int) return Std.int(Math.max(name.length,width)), 0);
        var count;
        var firstDate = null;
        var lastDate = null;
        Lib.println("Current Metrics:");
        for( metric in allMetrics  )
        {
            count = 0;
            firstDate = null;
            metrics = [metric].list();
            var occurrences = selectRange([null, null], false);
            for( occ in occurrences )
            {
                if( firstDate == null )
                    firstDate = occ.date;
                lastDate = occ.date;
                count++;
            }
            var duration = Utils.dayDelta(Utils.day(firstDate), Utils.day(lastDate))+1;
            Lib.println("- "+ metric.rpad(" ",nameWidth) +" "+ 
                        Std.string(count).lpad(" ",3) +
                        ((count==1) ? " occurrence  " : " occurrences ") +
                        "from "+ firstDate +" to "+ lastDate +
                        " ("+ Std.string(duration).lpad(" ",4) + ((duration==1) ? " day " : " days")+ ")");
        }
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
                var val = Std.parseFloat(fields[2]);
                if( Math.isNaN(val) )
                {
                    Lib.println("bad value, skipping line: " + line);
                    continue;
                }
                var metricId = getOrCreateMetric(fields[1]);
                setOrUpdate(fields[1], metricId, dayStr, val);
            }
        } catch( e:haxe.io.Eof ) {
        }
        fin.close();
    }

    // run the report generator to view the data
    public function view(cmd, groupType, valType, tail)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var reportGenerator = new ReportGenerator(range, tail);
        reportGenerator.setReport(cmd, groupType, valType);
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
            var metricId = getOrCreateMetric(metric);
            var dayStr = range[0];
            do
            {
                var rs = db.request("SELECT value FROM occurrences WHERE metricId='"+ metricId +"' AND date='"+ dayStr +"';");
                var val = if( rs.length != 0 )
                    rs.next().value+1;
                else
                    1;
                setOrUpdate( metric,  metricId, dayStr, val );

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
            var metricId = getOrCreateMetric(metric);
            var dayStr = range[0];
            do
            {
                setOrUpdate( metric, metricId, dayStr, val );
                dayStr = Utils.dayToStr(Utils.dayShift(Utils.day(dayStr), 1));
            } while( range[1]!=null && Utils.dayDelta(Utils.day(dayStr), Utils.day(range[1])) >= 0 );
        }
    }

    // get a metric id, create it if it doesn't exist
    private function getOrCreateMetric(metric :String) :Int
    {
        var rs = db.request("SELECT id FROM metrics WHERE name='"+ metric +"';");
        return if( rs.length != 0 )
            rs.next().id;
        else
        {                                                   // add metric if its new
            db.request("INSERT INTO metrics VALUES (null, '"+ metric +"');");
            getOrCreateMetric(metric);
        }
    }

    // set a value 
    private function setOrUpdate(metric :String, metricId :Int, dayStr :String, val :Float)
    {
        db.request("INSERT OR REPLACE INTO occurrences VALUES ('"+ metricId +"','"+ dayStr +"','"+ val +"')");
        Lib.println("set " + metric + " to " + val + " for " + dayStr);
    }

    // clear values
    public function clear()
    {
        connect();
        checkMetrics();
        var occurrences = selectRange(range, false).results().map(function(ii) return {metricId: ii.metricId, metric: ii.metric, date: ii.date});
        for( occ in occurrences )
        {
            db.request("DELETE FROM occurrences WHERE metricId='"+ occ.metricId +"' AND date='"+ occ.date +"'");
            Lib.println("deleted " + occ.metric + " for " + occ.date);
        }
        for( metric in metrics )                            // remove metrics with no occurrences
        {
            var metricId = getOrCreateMetric(metric);
            var count = db.request("SELECT count(metricId) FROM occurrences WHERE metricId='"+ metricId +"'").getIntResult(0);
            if( count == 0 )
            {
                db.request("DELETE FROM metrics WHERE id='"+ metricId + "'");
                Lib.println("deleted the last occurrence for " + metric);
            }
        }
    }

    // check that metrics exist, replace splat
    private function checkMetrics()
    {
        if( metrics.exists(function(ii) return ii=="*") )
            metrics = getAllMetrics().list();
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
        var rs = db.request("SELECT name FROM metrics;");
        return rs.results().map(function(ii) return ii.name);
    }

    // select a date range from the db
    private function selectRange(range, ?shouldCombine = true)
    {
        var rs = db.request("SELECT name FROM metrics;");
        if( rs.length == 0 )
        {
            Lib.println("No metrics found");
            Sys.exit(0);
        }

        var select = new StringBuf();
        select.add("SELECT ");
        select.add((shouldCombine) ? "metric, date, sum(value) as value " : "* ");
        select.add("FROM full WHERE ("+ metrics.map(function(ii) return "metric='"+ii+"'").join(" OR ") +") ");
        if( range[0]!=null )                               // start..
            select.add("AND date >= '"+ range[0] +"' ");
        if( range[1]!=null )                               // ..end
            select.add("AND date <= '"+ range[1] +"' ");
        select.add((shouldCombine) ? "GROUP BY date " : " ");
        select.add("ORDER BY date");

        return db.request(select.toString());
    }

    // close db file
    public function close()
    {
        db.close();
    }
}
