package utils;

class DeepHash<K,V>
{
    private var key :K;
    private var val :V;
    private var parent :DeepHash<K,V>;
    private var children :List<DeepHash<K,V>>;

    // optional so the root doesn't have to have a key
    public function new(?p, ?k)
    {
        parent = p;
        key = k;
        val = null;
        children = null;
    }

    // set a value at the specified path. create nodes as needed
    public function set(path :List<K>, val :V)
    {
        if( path.isEmpty() )
        {
            this.val = val;
            return;
        }

        if( children == null )
            children = new List<DeepHash<K,V>>();
        var key = path.pop();
        var child = first(children, function(ii) return ii.key==key);
        if( child == null )
        {
            child = new DeepHash<K,V>(this, key);
            children.add(child);
        }
        child.set(path, val);
    }

    // get the value at the specified path. return null if not found
    public function get(path :List<K>)
    {
        if( path.isEmpty() )
            return val;

        if( children == null )
            return null;

        var key = path.pop();
        var child = first(children, function(ii) return ii.key==key);
        return if( child==null )
            null;
        else
            child.get(path);
    }

    private function getPath(?path :List<K>)
    {
        if( path == null )
            path = new List<K>();
        if( key != null ) // dont care about the root
        {
            path.push(key);
            parent.getPath(path);
        }
        return path;
    }

    // pre-order traversal of paths, not lazy
    public function getPaths(?paths)
    {
        if( paths == null )
            paths = new List<List<K>>();
        if( parent != null )
            paths.add(getPath());
        if( children != null )
            for( child in children )
                child.getPaths(paths);
        return if (parent == null)
            paths.iterator();
        else
            null; // recursion doesnt use the return value
    }

    // utility to find the first item that matches in a list
    private static function first<A>(it:Iterable<A>, f:A->Bool)
    {
        for( ii in it )
            if( f(ii) )
                return ii;
        return null;
    }
}
