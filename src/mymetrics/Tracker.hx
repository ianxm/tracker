package mymetrics;

import neko.Lib;
import neko.Sys;
import neko.FileSystem;
import neko.db.Sqlite;
import neko.db.Connection;
import neko.db.Manager;
import utils.Utils;
import utils.Set;

class Tracker
{
    private var metric :String;
    private var db :Connection;

    public function new(m)
    {
        metric = m;
        connect();
    }

    // open db file
    private function connect()
    {
        var exists = FileSystem.exists(Main.DB_FILE);
        db = Sqlite.open(Main.DB_FILE);
        if( !exists )
        {
            trace("creating table");
            db.request("CREATE TABLE occurrence ("
                       + "metric TEXT NOT NULL, "
                       + "date TEXT NOT NULL, "
                       + "value INT NOT NULL);");
        }
        neko.db.Manager.cnx = db;
        neko.db.Manager.initialize();
    }

    // get list of existing metrics
    public function list()
    {
        if( Occurrence.manager.count()==0 )
        {
            Lib.println("No metrics found");
            return;
        }

        var metrics = new Set<String>();
        var occurrences = Occurrence.manager.search({}, false);
        for( rr in occurrences )
            metrics.add(rr.metric);

        Lib.println("Current Metrics:");
        for( metric in metrics )
            Lib.println("- "+ metric);
    }

    // run the report generator to view the data
    public function view(range, cmd)
    {
        var reportGenerator = new ReportGenerator(range);
        reportGenerator.setReport(cmd);
        var occurrences = selectRange(range);

        if( range[0] != null )                               // start..
            reportGenerator.include(Utils.day(range[0]), 0);

        for( occ in occurrences )
            reportGenerator.include(Utils.day(occ.date), occ.value);

        reportGenerator.include(Utils.day(range[1]), 0); // ..end (cant be null)

        reportGenerator.print();
    }

    // increment values
    public function incr(range)
    {
        var day = range[0];
        while( true )
        {
            var occ = Occurrence.manager.getWithKeys({metric: metric, date: day});
            if( occ != null )
            {
                occ.value++;
                occ.update();
                Lib.println("set " + metric + " to " + occ.value + " for " + day);
            }
            else
                set( [day, null], 1 );

            day = Utils.dayToStr(Utils.dayShift(Utils.day(day), 1));
            if( range[1]==null || Utils.dayDelta(Utils.day(day), Utils.day(range[1])) < 0 )
                break;
        }
    }

    // set values (clear if val is 0)
    public function set(range, val)
    {
        var day = range[0];
        while( true )
        {
            var occ = Occurrence.manager.getWithKeys({metric: metric, date: day});
            if( occ != null )
            {
                if( val != 0 )
                {
                    occ.value = val;
                    occ.update();
                    Lib.println("set " + metric + " to " + val + " for " + day);
                }
                else
                {
                    occ.delete();
                    Lib.println("deleted " + metric + " for " + day);
                }
            }
            else
            {
                if( val != 0 )
                {
                    occ = new Occurrence();
                    occ.metric = metric;
                    occ.date = day;
                    occ.value = val;
                    occ.insert();
                    Lib.println("set " + metric + " to " + val + " for " + day);
                }
            }

            day = Utils.dayToStr(Utils.dayShift(Utils.day(day), 1));
            if( range[1]==null || Utils.dayDelta(Utils.day(day), Utils.day(range[1])) < 0 )
                break;
        }
    }

    // clear values
    public function clear(range)
    {
        var occurrences = selectRange(range);
        for( occ in occurrences )
        {
            occ.delete();
            Lib.println("deleted " + metric + " for " + occ.date);
        }
    }

    // select a date range from the db
    private function selectRange(range)
    {
        if( Occurrence.manager.count()==0 )
        {
            Lib.println("No metrics found");
            Sys.exit(0);
        }

        var whereClause = new StringBuf();
        whereClause.add("WHERE metric='"+ metric + "'");
        if( range[0]!=null )                               // start..
            whereClause.add(" AND date >= '"+ range[0] +"'");
        if( range[1]!=null )                               // ..end
            whereClause.add(" AND date <= '"+ range[1] +"'");

        return Occurrence.manager.objects("SELECT * FROM occurrence "+ whereClause.toString() +" ORDER BY date", false);
    }

    // close db file
    public function close()
    {
        neko.db.Manager.cleanup();
        db.close();
    }
}
