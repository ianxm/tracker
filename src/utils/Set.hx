package utils;

using Lambda;

// TODO add should be a binary-search-insert
// there should be a "has" that uses binary search
class Set<T>
{
  public var vals(default,null) :List<T>;

  public function new()
  {
    vals = new List<T>();
  }

  public function union(otherItems :Iterable<T>, ?cmp :T->T->Bool)
  {
    for( ii in otherItems )
      add(ii, cmp);
  }

  public function intersection(otherItems :Iterable<T>, ?cmp :T->T->Bool)
  {
    for( ii in vals )
      if( !otherItems.has(ii, cmp) )
	vals.remove(ii);
  }

  public function add(item :T, ?cmp :T->T->Bool)
  {
    if( !vals.has(item, cmp) )
      vals.add(item);
  }

  public function has(item :T, ?cmd :T->T->Bool)
  {
    return( vals.has(item, cmd) );
  }

  public function clear()
  {
    vals.clear();
  }
}
