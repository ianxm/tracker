package mymetrics;

import utils.TestUtils;
import utils.TestSet;

class TestSuite
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new mymetrics.report.TestDurationReport());
        r.add(new mymetrics.report.TestLogReport());
        r.add(new mymetrics.report.TestStreakOnReport());
        r.add(new mymetrics.report.TestStreakOffReport());
        r.add(new mymetrics.report.TestStreakCurrentReport());
        r.add(new utils.TestSet());
        r.add(new utils.TestUtils());
        r.run();
    }
}
