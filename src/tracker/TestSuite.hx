package tracker;

import utils.TestUtils;

class TestSuite
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new tracker.report.TestDurationReport());
        r.add(new tracker.report.TestLogReport());
        r.add(new tracker.report.TestCountReport());
        r.add(new tracker.report.TestStreakReport());
        r.add(new tracker.report.TestStreakLogReport());
        // r.add(new tracker.report.TestCalReport());
        r.add(new tracker.report.TestRecordReport());
        r.add(new utils.TestUtils());
        r.run();
    }
}
