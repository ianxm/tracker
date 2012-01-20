package mymetrics;

import neko.db.Object;

class Occurrence extends Object
{
    static var TABLE_IDS = ["metric", "date"];
    public var metric :String;
    public var date :String;
    public var value :Int;

    public static var manager = new neko.db.Manager<Occurrence>(Occurrence);

    override public function toString()
    {
        return date + ": " + value;
    }
}
