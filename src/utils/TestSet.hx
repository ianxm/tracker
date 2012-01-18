package utils;

class TestSet extends haxe.unit.TestCase
{
  public function testHas()
  {
    var set = new Set();
    set.add(1);
    set.add(2);
    set.add(3);
    assertTrue(set.has(1));
    assertTrue(set.has(2));
    assertTrue(set.has(3));
    assertFalse(set.has(4));
    assertFalse(set.has(101));
  }

  public function testString()
  {
    var set = new Set();
    set.add("one");
    set.add("two");
    set.add("three");
    assertTrue(set.has("one"));
    assertTrue(set.has("two"));
    assertTrue(set.has("three"));
    assertFalse(set.has("four"));
  }

  public function testClear()
  {
    var set = new Set();
    set.add(1);
    set.add(2);
    assertTrue(set.has(1));
    assertTrue(set.has(2));
    set.clear();
    assertFalse(set.has(1));
    assertFalse(set.has(2));
  }

  public function testUnion()
  {
    var set = new Set();
    set.add(1);
    set.add(2);
    assertFalse(set.has(3));
    assertFalse(set.has(4));
    set.union([3,4]);
    assertTrue(set.has(1));
    assertTrue(set.has(2));
    assertTrue(set.has(3));
    assertTrue(set.has(4));
  }

  public function testIntersection()
  {
    var set = new Set();
    set.add(1);
    set.add(2);
    assertTrue(set.has(1));
    assertTrue(set.has(2));
    set.intersection([2,3,4]);
    assertFalse(set.has(1));
    assertTrue(set.has(2));
    assertFalse(set.has(3));
  }

  public function testMinus()
  {
    var set = new Set();
    set.add(1);
    set.add(2);
    set.add(3);
    set.minus([1,3,4]);
    assertFalse(set.has(1));
    assertTrue(set.has(2));
    assertFalse(set.has(3));
    assertFalse(set.has(4));
  }

  public function testIter()
  {
    var set = new Set();
    set.add(1);
    set.add(2);
    set.add(3);
    var iter = set.iterator();
    assertEquals(iter.next(), 1);
    assertEquals(iter.next(), 2);
    assertEquals(iter.next(), 3);
  }
}