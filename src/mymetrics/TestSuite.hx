package mymetrics;

import mymetrics.node.TestNode;
import utils.TestUtils;
import utils.TestSet;

class TestSuite
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new mymetrics.node.TestNode());
        r.add(new utils.TestSet());
        r.add(new utils.TestUtils());
        r.run();
    }
}
