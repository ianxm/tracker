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
import neko.io.File;
import neko.FileSystem;
import neko.db.Sqlite;
import neko.db.Connection;
import neko.db.Manager;
import altdate.Gregorian;
import altdate.JulianDay;
import tracker.Main;
import utils.Utils;

class Tracker
{
    private var dbFile   :String;
    private var metrics  :Set<String>;
    private var range    :Array<Gregorian>;
    private var db       :Connection;
    private var undoMode :Bool;

    public function new(f, m, r, u)
    {
        dbFile = f;
        metrics = m;
        range = r;
        undoMode = u;
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
                   "name TEXT UNIQUE NOT NULL)");
        db.request("CREATE TABLE occurrences (" +
                   "metricId INTEGER NOT NULL REFERENCES metric (id) ON DELETE SET NULL, " +
                   "date DATE NOT NULL, " +
                   "value REAL NOT NULL, " +
                   "CONSTRAINT key PRIMARY KEY (metricId, date))");
        db.request("CREATE VIEW full AS SELECT " +
                   "metrics.id AS metricId, metrics.name AS metric, occurrences.date AS date, occurrences.value AS value " +
                   "FROM metrics, occurrences " +
                   "WHERE occurrences.metricId=metrics.id");
        db.request("CREATE TABLE tags (" +
                   "name TEXT NOT NULL," +
                   "metricId INTEGER NOT NULL REFERENCES metric (id) ON DELETE SET NULL)");
        db.request("CREATE VIEW tags_by_names AS SELECT " +
                   "tags.name AS tag, metrics.name AS metric " + 
                   "FROM tags, metrics " +
                   "WHERE tags.metricId=metrics.id");
        db.request("CREATE TABLE hist (" +
                   "id INTEGER PRIMARY KEY, " +
                   "refId INTEGER, " +         // null if user command, else id of parent cmd
                   "date DATE, " +
                   "cmd TEXT NOT NULL)");
    }

    // open db file
    private function connect()
    {
        if( !FileSystem.exists(dbFile) )
            throw "repository doesn't exist, you must run 'init' first";
        db = Sqlite.open(dbFile);
    }

    // get list of existing metrics
    public function list()
    {
        connect();
        checkMetrics();
        var allMetrics = if( !metrics.isEmpty() )
            metrics.list();
        else
            getAllMetrics();
        if( allMetrics.isEmpty() )
        {
            Lib.println("No metrics found");
            return;
        }

        var nameWidth = allMetrics.fold(function(name,width:Int) return Std.int(Math.max(name.length,width)), 5);
        var count;
        var firstDate = null;
        var lastDate = null;
        var buf = new StringBuf();
        var padding = Math.round((nameWidth-"metric".length)/2);
        for( ii in 0...padding )
            buf.add(" ");
        buf.add("metric");
        for( ii in 0...padding )
            buf.add(" ");
        buf.add(" count  first       last      days\n");
        for( metric in allMetrics  )
        {
            count = 0;
            firstDate = null;
            metrics.clear();
            metrics.add(metric);
            var occurrences = selectRange([null, null], false);
            for( occ in occurrences )
            {
                if( firstDate == null )
                    firstDate = Utils.dayFromJulian(occ.date);
                lastDate = Utils.dayFromJulian(occ.date);
                count++;
            }
            var duration = lastDate.value-firstDate.value + 1;
            buf.add(metric.rpad(" ",nameWidth) +"  "+ 
                    Std.string(count).lpad(" ",3) + 
                    "  "+ firstDate +"  "+ lastDate +
                    "  "+ Std.string(duration).lpad(" ",4) + "\n");
        }
        Lib.println(buf.toString());
    }

    public function hist(tail :Int)
    {
        connect();
        var limitStr = if( tail != null )
            " LIMIT " + tail;
        else
            "";
        var rs = db.request("SELECT * FROM hist WHERE refId IS NULL ORDER BY id DESC" + limitStr);
        for( result in rs )
        {
            var date = new JulianDay(true, result.date);
            Lib.println(JulianDay.convertToGregorianDateTime(date).toString() +"  "+ result.cmd);
        }
    }

    public function undo()
    {
        connect();
        var parentCmdId = getLastCmdId();
        var rs = db.request("SELECT cmd FROM hist WHERE refId='"+parentCmdId+"' ORDER BY id DESC");
        var cmds = rs.results().map(function(ii) return ii.cmd);
        db.close();
        for( cmd in cmds )
            new Main(true).run(Std.string(cmd + " --repo " + dbFile).split(" "));
        connect();
        db.request("DELETE FROM hist WHERE refId='"+parentCmdId+"'");
        db.request("DELETE FROM hist WHERE id='"+parentCmdId+"'");
    }

    // output all metrics as a csv
    public function exportCsv(fname)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var fout;
        if( fname != null )
        {
            if( FileSystem.exists(fname) )
                throw "file exists: " + FileSystem.fullPath(fname);
            else
                try {
                    fout = File.write(fname);
                } catch( e:Dynamic ) {
                    throw "couldn't open output file: " + fname;
                }
            Lib.println("writing csv to: " + fname);
        }
        else
            fout = File.stdout();

        var occurrences = selectRange(range, false);
        fout.writeString("date,metric,value\n");
        for( rr in occurrences )
            fout.writeString(Utils.dayFromJulian(rr.date).toString() +","+ rr.metric +","+ rr.value +"\n");
        fout.close();
    }

    // import metrics from a csv
    public function importCsv(fname)
    {
        connect();

        var fin = if( fname == "-" )
            File.stdin();
        else 
        {
            if( !FileSystem.exists(fname) )
                throw "file not found: " + fname;
            File.read(fname);
        }

        if( !undoMode )
            db.request("INSERT INTO hist VALUES (null, null, '"+ Utils.now().value +"', "+ db.quote("import "+fname) +" )");
        var parentCmdId = getLastCmdId();

        try
        {
            while( true )
            {
                var line = fin.readLine();
                var fields = line.split(",").map(function(ii) return StringTools.trim(ii)).array();
                var day;
                try {
                    day = Utils.dayFromString(fields[0]);
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
                setOrUpdate(fields[1], metricId, day, val, parentCmdId);
            }
        } catch( e:haxe.io.Eof ) {
        }
        fin.close();
    }

    // add a tag
    // this allows multiple identical, but it doesn't seem to hurt anything
    public function addTag(tag)
    {
        connect();
        for( metric in metrics )
        {
            var metricId = getMetric(metric);
            if( metricId == null )
                throw "metric doesn't exist: " + metric;
            db.request("INSERT INTO tags VALUES ("+ db.quote(tag) +", "+ metricId +")");
            Lib.println("added tag '"+ tag +"' to metric '"+ metric +"'");
        }
    }

    // remove a tag
    // this says it removed it even if the tag didn't exist
    public function rmTag(tag)
    {
        connect();
        for( metric in metrics )
        {
            var metricId = getMetric(metric);
            if( metricId == null )
                throw "metric doesn't exist: " + metric;
            db.request("DELETE FROM tags WHERE (name="+ db.quote(tag) +" AND metricId="+ metricId +")");
            Lib.println("removed tag '"+ tag +"' from metric '"+ metric +"'");
        }
    }

    // list all tags and the metrics they tag
    public function listTags()
    {
        connect();
        var rs = db.request("SELECT DISTINCT name FROM tags ORDER BY name");
        var tags = rs.results().map(function(ii) return ii.name);
        var tagHash = new Hash<String>();
        for( tag in tags )
        {
            rs = db.request("SELECT metric FROM tags_by_names where tag="+ db.quote(tag));
            var metricNames = rs.results().map(function(ii) return ii.metric);
            tagHash.set(tag, metricNames.join(", "));
        }
        
        var width = tags.fold(function(rr,width:Int) return Std.int(Math.max(rr.length,width)), 0);
        for( key in tags )
            Lib.println("  " + key.lpad(" ",width) + ": " + tagHash.get(key));
    }

    // run the report generator to view the data
    public function view(cmd, groupType, valType, tail)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var reportGenerator = new ReportGenerator(tail);
        reportGenerator.setReport(cmd, groupType, valType);

        if( range[0] != null )                              // start..
            reportGenerator.include(range[0], Main.NO_DATA);
        var occurrences = selectRange(range);
        for( occ in occurrences )
            reportGenerator.include(Utils.dayFromJulian(occ.date), occ.value);
        reportGenerator.include(range[1], Main.NO_DATA);    // ..end (cant be null)

        reportGenerator.print();
    }

    // run the graph generator
    public function graph(fname :String, graphType, groupType, valType)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var graphGenerator = new GraphGenerator(metrics.list().join(", "), graphType, fname);
        graphGenerator.setReport(groupType, valType);

        if( range[0] != null )                              // start..
            graphGenerator.include(range[0], Main.NO_DATA);
        var occurrences = selectRange(range);
        for( occ in occurrences )
            graphGenerator.include(Utils.dayFromJulian(occ.date), occ.value);
        graphGenerator.include(range[1], Main.NO_DATA);    // ..end (cant be null)

        graphGenerator.render();
    }

    // increment values
    public function incr(val :Float)
    {
        connect();
        var rangeStr = if( range[0].value == range[1].value )
            ""+range[0];
        else
            ""+range[0]+".."+range[1];
        if( !undoMode )
            db.request("INSERT INTO hist VALUES (null, null, '"+ Utils.now().value +"', "+
                       db.quote("set "+ ((val>0)?"+":"") + val +" -d "+ rangeStr + " " + Lambda.list(metrics).join(" ")) + " )");
        var parentCmdId = getLastCmdId();
        for( metric in metrics )
        {
            var metricId = getOrCreateMetric(metric);
            var day = range[0].toDate();
            do
            {
                var rs = db.request("SELECT value FROM occurrences WHERE metricId='"+ metricId +"' AND date='"+ day.value +"'");
                var val = if( rs.length != 0 )
                    rs.next().value+val;
                else
                    val;
                setOrUpdate( metric,  metricId, day, val, parentCmdId );

                day.day += 1;
            } while( range[1]!=null && range[1].value-day.value>=0 );
        }
    }

    // set values
    public function set(val :Float)
    {
        connect();
        var rangeStr = if( range[0].value == range[1].value )
            ""+range[0];
        else
            ""+range[0]+".."+range[1];
        if( !undoMode )
            db.request("INSERT INTO hist VALUES (null, null, '"+ Utils.now().value +"', "+
                       db.quote("set ="+ val +" -d "+ rangeStr + " " + Lambda.list(metrics).join(" ")) + " )");
        var parentCmdId = getLastCmdId();
        for( metric in metrics )
        {
            var metricId = getOrCreateMetric(metric);
            var day = range[0].toDate();
            do
            {
                setOrUpdate( metric, metricId, day, val, parentCmdId );
                day.day += 1;
            } while( range[1]!=null && range[1].value-day.value>=0 );
        }
    }

    // get id of last (most recent) user command in history
    inline private function getLastCmdId() :Int
    {
        var rs = db.request("SELECT * FROM hist WHERE refId IS NULL ORDER BY id DESC LIMIT 1");
        if( rs.length == 0 )
            throw "no history";
        return rs.next().id;
    }

    // get a metric id, create it if it doesn't exist
    private function getOrCreateMetric(metric :String) :Int
    {
        var metricId = getMetric(metric);
        return if( metricId!=null )
            metricId;
        else
        {                                                   // add metric if its new
            db.request("INSERT INTO metrics VALUES (null, "+ db.quote(metric) +")");
            getOrCreateMetric(metric);
        }
    }

    inline private function getMetric(metric :String) :Int
    {
        var rs = db.request("SELECT id FROM metrics WHERE name="+ db.quote(metric));
        return if( rs.length != 0 )
            rs.next().id;
        else
            null;
    }

    // set a value 
    private function setOrUpdate(metric :String, metricId :Int, day :Gregorian, val :Float, parentCmdId :Int)
    {
        if( (Utils.today().value - day.value) < 0 )
            throw "Cannot set metrics in the future";

                                                            // get old value
        var rs = db.request("SELECT * FROM full WHERE metricId='"+ metricId +"' AND date='"+ day.value +"'");
        var oldVal = if( rs.length != 0 )
            rs.next().value;
        else
            null;

        db.request("INSERT OR REPLACE INTO occurrences VALUES ('"+ metricId +"','"+ day.value +"','"+ val +"')");
        if( oldVal == null )
        {
            if( !undoMode )
                db.request("INSERT INTO hist VALUES (null, "+ parentCmdId +", null, "+ db.quote("rm -d "+ day + " " + metric) + " )");
            Lib.println("set "+ metric +" to "+ val +" for "+ day);
        }
        else
        {
            if( !undoMode )
                db.request("INSERT INTO hist VALUES (null, "+ parentCmdId +", null, "+ db.quote("set ="+oldVal+" -d "+ day + " " + metric) + " )");
            Lib.println("changed "+ metric +" from "+ oldVal +" to "+ val +" for "+ day);
        }
    }

    // clear values
    public function remove()
    {
        var count = 0;
        connect();
        checkMetrics();
        var occurrences = selectRange(range, false).results().map(function(ii) return {metricId: ii.metricId, metric: ii.metric, date: ii.date});
        for( occ in occurrences )
        {
            var date = Utils.dayFromJulian(occ.date);
            db.request("DELETE FROM occurrences WHERE metricId='"+ occ.metricId +"' AND date='"+ date.value +"'");
            Lib.println("removed " + occ.metric + " for " + date.toString());
            count++;
        }
        if( count == 0 )
            Lib.println("didn't find anything to remove");
        else
            for( metric in metrics )                        // remove metrics with no occurrences
            {
                var metricId = getOrCreateMetric(metric);
                var count = db.request("SELECT count(metricId) FROM occurrences WHERE metricId='"+ metricId +"'").getIntResult(0);
                if( count == 0 )
                {
                    db.request("DELETE FROM metrics WHERE id='"+ metricId + "'");
                    Lib.println("removed the last occurrence for " + metric);
                }
            }
    }

    // check that metrics exist, replace tags or splat
    private function checkMetrics()
    {
        var allMetrics = getAllMetrics();
        if( metrics.has("*") )
        {
            metrics.clear();
            metrics.union(allMetrics);
        }
        else
        {
            var newMetrics = new Set<String>();
            for( metric in metrics )
                if( allMetrics.has(metric) )
                    newMetrics.add(metric);
                else
                {
                    var taggedMetrics = checkTag(metric);
                    if( taggedMetrics != null )
                        newMetrics.union(taggedMetrics);
                    else
                        throw "unknown metric: " + metric;                        
                }
            metrics = newMetrics;
        }
    }

    // get a set of all metrics in the db
    private function getAllMetrics()
    {
        var rs = db.request("SELECT name FROM metrics");
        return rs.results().map(function(ii) return ii.name);
    }

    // check if the given string is a tag, if it is, return the metrics tagged with it
    private function checkTag(str :String)
    {
        var rs = db.request("SELECT metric FROM tags_by_names WHERE tag="+ db.quote(str));
        return if( rs.length == 0 )
            null;
        else
            rs.results().map(function(ii) return ii.metric);
    }

    // select a date range from the db
    private function selectRange(range :Array<Gregorian>, ?shouldCombine = true)
    {
        var rs = db.request("SELECT name FROM metrics");
        if( rs.length == 0 )
        {
            Lib.println("No metrics found");
            Sys.exit(0);
        }

        var select = new StringBuf();
        select.add("SELECT ");
        select.add((shouldCombine) ? "metric, date, sum(value) AS value " : "* ");
        select.add("FROM full WHERE ("+ metrics.map(function(ii) return "metric="+db.quote(ii)).join(" OR ") +") ");
        if( range[0]!=null )                               // start..
            select.add("AND date >= '"+ range[0].value +"' ");
        if( range[1]!=null )                               // ..end
            select.add("AND date <= '"+ range[1].value +"' ");
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
