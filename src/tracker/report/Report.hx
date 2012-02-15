package tracker.report;

interface Report
{
    public function include(thisDay :Date, val :Int) :Void;
    public function getLabel() :String;
    public function toString() :String;
}
