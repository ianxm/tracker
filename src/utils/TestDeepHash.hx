package utils;

using Lambda;

class TestDeepHash extends haxe.unit.TestCase
{
    public function testSetRoot()
    {
        var tree = new DeepHash<Int, String>();
        tree.set([].list(), "root");
        assertEquals("root", tree.get([].list()));
    }

    public function testSetChild()
    {
        var tree = new DeepHash<Int, String>();
        tree.set([1].list(), "one");
        assertEquals("one", tree.get([1].list()));
    }

    public function testSetChildTwice()
    {
        var tree = new DeepHash<Int, String>();
        tree.set([1].list(), "one");
        tree.set([2].list(), "two");
        assertEquals("one", tree.get([1].list()));
        assertEquals("two", tree.get([2].list()));
    }

    public function testSetTwoDeep()
    {
        var tree = new DeepHash<Int, String>();
        tree.set([1,2].list(), "one.two");
        assertEquals("one.two", tree.get([1,2].list()));
    }

    public function testSiblings()
    {
        var tree = new DeepHash<Int, String>();
        tree.set([1].list(), "one");
        tree.set([2].list(), "two");
        assertEquals("one", tree.get([1].list()));
        assertEquals("two", tree.get([2].list()));
    }

    public function testSetTwoDeepExistingPath()
    {
        var tree = new DeepHash<Int, String>();
        tree.set([1].list(), "one");
        tree.set([1,2].list(), "one.two");
        assertEquals("one", tree.get([1].list()));
        assertEquals("one.two", tree.get([1,2].list()));
    }

    public function testSetOtherTypes()
    {
        var tree = new DeepHash<String, Float>();
        tree.set(["one"].list(), 1.1);
        tree.set(["one","two"].list(), 1.2);
        assertEquals(1.1, tree.get(["one"].list()));
        assertEquals(1.2, tree.get(["one","two"].list()));
    }

    public function testIterateValues()
    {
        var tree = new DeepHash<String, Float>();
        tree.set(["one"].list(), 1.1);
        tree.set(["one","two"].list(), 1.2);
        var iter = tree.getPaths();
        assertEquals('{one}', iter.next().toString());
        assertEquals('{one, two}', iter.next().toString());
        assertFalse(iter.hasNext());
    }
}
