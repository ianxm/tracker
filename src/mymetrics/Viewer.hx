package mymetrics;

import neko.Lib;
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

    public function view()
    {
        var rg = new ReportGenerator();
        var results = Occurrence.manager.search({metric: metric}, false);
        for( occ in results )
            rg.include(occ);
        rg.print();
    }

    public function close()
    {
        neko.db.Manager.cleanup();
        db.close();
    }
}
