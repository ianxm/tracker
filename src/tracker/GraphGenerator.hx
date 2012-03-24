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
import haxe.Template;
import haxe.Resource;
import neko.Lib;
import neko.io.Process;
import utils.Utils;
import tracker.Main;
import tracker.report.Report;

class GraphGenerator
{
    private var reports   :List<Report>;
    private var groupType :GroupType;
    private var valType   :ValType;
    private var graphType :GraphType;
    private var fname     :String;
    private var makePng   :Bool;
    private var makeSvg   :Bool;
    private var title     :String;

    public function new(t :String, gt :GraphType, f :String)
    {
        checkGnuplot();
        reports = new List<Report>();
        title = t;
        graphType = gt;
        makePng = false;
        makeSvg = false;
        if( f != null )
        {
            fname = f;
            if( fname.endsWith(".png") )
                makePng = true;
            else if( fname.endsWith(".svg") )
                makeSvg = true;
            else
                throw "graph output files must end in '.png' or '.svg'";
            Lib.println("saving graph to: " + fname);
        }
    }

    public function setReport(gt, vt)
    {
        reports.add(new tracker.report.LogReport(gt, vt));
        groupType = gt;
        valType = vt;
    }

    public function include( date, val )
    {
        for( report in reports )
            report.include(date, val);
    }

    public function render()
    {
        var gpTemplate = new Template(Resource.getString("gnuplot"));
        var config = reports.first().toString().replace(":","");
        var params = { makePng: makePng,
                       makeSvg: makeSvg,
                       useMagick: (!makePng && !makeSvg && checkImageMagick()),
                       fname: fname,
                       title: title,
                       grouping: Std.string(groupType).toLowerCase(),
                       valType: Std.string(valType).toLowerCase(),
                       graphType: Std.string(graphType).toLowerCase(),
                       data: config};
        runGnuplot(gpTemplate.execute(params));
    }

    private function runGnuplot(config :String)
    {
    	try
        {
            var ret = new Process("gnuplot", []);
            ret.stdin.writeString(config);
            ret.stdin.close();
            if( ret.exitCode() != 0 )
                throw("gnuplot failed");
        } catch( ex : String ) {
            throw("gnuplot failed" );
        }
    }

    // make sure gnuplot is installed and in the path
    private function checkGnuplot()
    {
    	try
        {
            var ret = new Process("gnuplot", ["--version"]);
            if( ret.exitCode() != 0 )
                throw("gnuplot was not found");
        } catch( ex : String ) {
            throw("gnuplot was not found");
        }
        return true;
    }

    // see if gnuplot is installed and in the path
    public function checkImageMagick()
    {
    	try
        {
            var ret = new Process("display", ["--version"]);
            if( ret.exitCode() != 0 )
                return false;
        } catch( ex : String ) {
            return false;
        }
        return true;
    }
}
