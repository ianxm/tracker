package mymetrics.report;

import mymetrics.Occurrence;

interface Report
{
    public function include(thisDay :Date, val :Int) :Void;
    public function toString() :String;
}
