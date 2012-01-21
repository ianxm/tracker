package mymetrics;

import neko.Lib;
import neko.Sys;
import neko.FileSystem;
import neko.db.Sqlite;
import neko.db.Connection;
import neko.db.Manager;
import utils.Set;

class Viewer
{
    private var metric :String;
    private var db :Connection;

    public function new(m)
    {
        metric = m;
        connect();
    }

    private function connect()
    {
        var exists = FileSystem.exists(Main.DB_FILE);
        if( !exists )
            throw "db file not found";
        db = Sqlite.open(Main.DB_FILE);
        neko.db.Manager.cnx = db;
        neko.db.Manager.initialize();
    }

    // get day val
    public function get(day)
    {
        var occ = Occurrence.manager.getWithKeys({metric: metric, date: day});
        if( occ == null )
            Lib.println("no occurrence that day");
        else
            Lib.println("Value for '"+ metric +"' on "+ occ.date +" is: "+  occ.value);
    }

    public function list()
    {
        if( Occurrence.manager.count()==0 )
        {
            Lib.println("No metrics found");
            return;
        }

        var metrics = new Set<String>();
        var results = Occurrence.manager.search({}, false);
        for( rr in results )
            metrics.add(rr.metric);

        Lib.println("Current Metrics:");
        for( metric in metrics )
            Lib.println("- "+ metric);
    }

    public function log(range)
    {
        var results = selectRange(range);

        Lib.println(metric +":");
        for( occ in results )
            Lib.println("  " + occ.toString());
    }

    public function view(range)
    {
        var report = new ReportGenerator(range);
        var results = selectRange(range);

        for( occ in results )
            report.include(occ);
        report.print();
    }

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
            whereClause.add(" AND date > '"+ range[0] +"'");
        if( range[1]!=null )                               // ..end
            whereClause.add(" AND date < '"+ range[1] +"'");

        return Occurrence.manager.objects("SELECT * FROM occurrence "+ whereClause.toString() +" ORDER BY date", false);
    }

    public function close()
    {
        neko.db.Manager.cleanup();
        db.close();
    }
}
