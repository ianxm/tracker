package tracker;

import neko.db.Object;

class Occurrence extends Object
{
    static function RELATIONS()
    {
        return [{prop: "metric", key: "metricId", manager: Occurrence.manager}];
    }
    //static var TABLE_IDS = ["metricId", "date"];
    private var metricId :Int;
    public var metric(dynamic,dynamic) :Metric;
    public var date :String;
    public var value :Int;

    public static var manager = new neko.db.Manager<Occurrence>(Occurrence);

    override public function toString()
    {
        return date + ": " + value;
    }
}
