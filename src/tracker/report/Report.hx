package tracker.report;

import tracker.Occurrence;

interface Report
{
    public function include(thisDay :Date, val :Int) :Void;
    public function toString() :String;
}
