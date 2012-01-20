package mymetrics;

import neko.Lib;
import neko.FileSystem;
import neko.db.Sqlite;
import neko.db.Connection;
import neko.db.Manager;

class Tracker
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

    // increment day
    public function incr(day)
    {
        var occ = Occurrence.manager.getWithKeys({metric: metric, date: day});
        if( occ != null )
        {
            occ.value++;
            occ.update();
            Lib.println("set " + metric + " to " + occ.value + " for " + day);
        }
        else
            set( day, 1 );
    }

    // set day to val
    public function set(day, val)
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
            occ = new Occurrence();
            occ.metric = metric;
            occ.date = day;
            occ.value = val;
            occ.insert();
            Lib.println("set " + metric + " to " + val + " for " + day);
        }
    }

    public function close()
    {
        neko.db.Manager.cleanup();
        db.close();
    }
}
