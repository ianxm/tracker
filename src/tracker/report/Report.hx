package tracker.report;

interface Report
{
    public function include(thisDay :Date, val :Float) :Void;
    public function getLabel() :String;
    public function toString() :String;
}
