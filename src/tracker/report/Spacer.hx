package tracker.report;

class Spacer implements Report
{
    public function new()
    {}

    inline public function include(thisDay :Date, val :Float)
    {}

    inline public function getLabel()
    {
        return "";
    }

    inline public function toString()
    {
        return "\n";
    }
}
