package mymetrics.node;

using Lambda;

class TestNode extends haxe.unit.TestCase
{
    public function testPathFromDayStr()
    {
        assertEquals("{2012, 00, 01}", Std.string(Node.pathFromDayStr("2012-01-01")));
        assertEquals("{2010, 01, 01}", Std.string(Node.pathFromDayStr("2010-02-01")));
        assertEquals("{2009, 11, 31}", Std.string(Node.pathFromDayStr("2009-12-31")));
        assertEquals("{2008, 01, 29}", Std.string(Node.pathFromDayStr("2008-02-29")));
    }

    public function testCreateRoot()
    {
        var root = new Node(null, 0, "root");
        assertEquals("root", root.index);
    }

    public function testYearValue()
    {
        var root = new Node(null, 0, "root");
        var path = ["2012"].list();
        root.fileIt(path, 1);
        assertEquals(1.0, root.pullIt(path, false));

        //trace(Node.prettyPrint(root));
        assertEquals("2012=1, root=1", Lambda.map(root, function(ii) return ii.toString()).join(", "));
    }

    public function testMonthValue()
    {
        var root = new Node(null, 0, "root");
        var path = ["2012", "00"].list();
        root.fileIt(path, 2);

        path = ["2012", "00"].list();
        assertEquals(2.0, root.pullIt(path, false));

        path = ["2012"].list();
        assertEquals(2.0, root.pullIt(path, false));

        //trace(Node.prettyPrint(root));
        assertEquals("00=2, 2012=2, root=2", Lambda.map(root, function(ii) return ii.toString()).join(", "));
    }

    public function testDayValue()
    {
        var root = new Node(null, 0, "root");
        var path = ["2012", "00", "01"].list();
        root.fileIt(path, 3);

        path = ["2012", "00", "01"].list();
        assertEquals(3.0, root.pullIt(path, false));

        path = ["2012", "00"].list();
        assertEquals(3.0, root.pullIt(path, false));

        path = ["2012"].list();
        assertEquals(3.0, root.pullIt(path, false));

        //trace(Node.prettyPrint(root));
        assertEquals("01=3, 00=3, 2012=3, root=3", Lambda.map(root, function(ii) return ii.toString()).join(", "));
    }

    public function testDayAvg()
    {
        var root = new Node(null, 0, "root");
        var path = ["2012", "00", "01"].list();
        root.fileIt(path, 3);

        path = ["2012", "00", "01"].list();
        assertEquals(3.0, root.pullIt(path, true));

        path = ["2012", "00"].list();
        assertEquals(3.0/31.0, root.pullIt(path, true));

        path = ["2012"].list();
        assertEquals(3.0/366.0, root.pullIt(path, true));

        //trace(Node.prettyPrint(root));
        assertEquals("01=3, 00=3, 2012=3, root=3", Lambda.map(root, function(ii) return ii.toString()).join(", "));
    }

    public function testDayTwoValues()
    {
        var root = new Node(null, 0, "root");
        var path = ["2012", "00", "01"].list();
        root.fileIt(path, 3);

        var path = ["2012", "00", "31"].list();
        root.fileIt(path, 2);
        //trace(Node.prettyPrint(root));

        path = ["2012", "00", "01"].list();
        assertEquals(3.0, root.pullIt(path, false));

        path = ["2012", "00", "31"].list();
        assertEquals(2.0, root.pullIt(path, false));

        path = ["2012", "00"].list();
        assertEquals(5.0, root.pullIt(path, false));

        path = ["2012"].list();
        assertEquals(5.0, root.pullIt(path, false));

        assertEquals("31=2, 01=3, 00=5, 2012=5, root=5", Lambda.map(root, function(ii) return ii.toString()).join(", "));
    }

    public function testDayTwoValuesDifferentMonths()
    {
        var root = new Node(null, 0, "root");
        var path = ["2012", "00", "01"].list();
        root.fileIt(path, 3);

        path = ["2012", "02", "01"].list();
        root.fileIt(path, 2);
        //trace(Node.prettyPrint(root));

        path = ["2012", "00", "01"].list();
        assertEquals(3.0, root.pullIt(path, false));

        path = ["2012", "02", "01"].list();
        assertEquals(2.0, root.pullIt(path, false));

        path = ["2012", "00"].list();
        assertEquals(3.0, root.pullIt(path, false));

        path = ["2012", "02"].list();
        assertEquals(2.0, root.pullIt(path, false));

        path = ["2012"].list();
        assertEquals(5.0, root.pullIt(path, false));

        assertEquals("01=3, 00=3, 01=2, 02=2, 2012=5, root=5", Lambda.map(root, function(ii) return ii.toString()).join(", "));
    }
}
