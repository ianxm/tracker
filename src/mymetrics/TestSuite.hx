package mymetrics;

import mymetrics.node.TestNode;

class TestSuite
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new mymetrics.node.TestNode());
        r.run();
    }
}
