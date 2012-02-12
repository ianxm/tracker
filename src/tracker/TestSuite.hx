package tracker;

import utils.TestUtils;
import utils.TestSet;

class TestSuite
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new tracker.report.TestDurationReport());
        r.add(new tracker.report.TestLogReport());
        r.add(new tracker.report.TestStreakOnReport());
        r.add(new tracker.report.TestStreakOffReport());
        r.add(new tracker.report.TestStreakCurrentReport());
        r.add(new tracker.report.TestStreakLogReport());
        r.add(new utils.TestSet());
        r.add(new utils.TestUtils());
        r.run();
    }
}
