package mymetrics.node;

using Lambda;

class Node
{
    public var parent(default,null) :Node;
    public var depth(default,null) :Int;        // ie. 0=root, 1=year, 2=month, 3=day
    public var index(default,null) :String;     // ie. 00=jan, 01=feb
    public var value(default,null) :Int;        // agg of children
    private var maxChildren :Int;               // length for averaging
    private var children :Hash<Node>;

    public function new(p, d, i)
    {
        parent = p;
        depth = d;
        index = i;
        value = 0;
        maxChildren = switch(depth)
        {
        case 0: null; // should be from first date until now
        case 1: ( DateTools.getMonthDays(new Date(Std.parseInt(index),1,1,0,0,0))==29 ) ? 366 : 365;
        case 2: DateTools.getMonthDays(new Date(Std.parseInt(parent.index), Std.parseInt(index), 1, 0, 0, 0));
        default: 1;
        }
    }

    private function prettyPrintNode()
    {
        var buf = new StringBuf();
        for( ii in 0...depth )
            buf.add("  ");
        buf.add(toString()+"\n");
        return buf.toString();
    }

    public static function prettyPrint(root :Node)
    {
        var buf = new StringBuf();
        buf.add("\n");
        for( node in root )
            buf.add(node.prettyPrintNode());
        return buf.toString();
    }

    public function toString()
    {
        return index +"="+ value;
    }

    public function fileIt(path :List<String>, val :Int)
    {
        value += val;
        if( path.length == 0 )
        {
            value = val;
            return;
        }
        if( children == null )
            children = new Hash<Node>();
        
        var childIndex = path.pop();
        if( !children.exists(childIndex) )
            children.set(childIndex, new Node(this, depth+1, childIndex));
        children.get(childIndex).fileIt(path, val);
    }

    public function pullIt(path :List<String>, avg :Bool)
    {
        if( path.length == 0 )
            return avg? value/maxChildren : value;
        else
        {
            var childIndex = path.pop();
            if( children.exists(childIndex) )
                return children.get(childIndex).pullIt(path, avg);
            else
                return 0;
        }
    }

    public function iterator()
    {
        return new NodeIterator(walkTree(new List<Node>()));
    }

    // walk the tree returning a list of nodes using preorder traversal
    private function walkTree(nodes :List<Node>) :List<Node>
    {
        nodes.add(this);
        if( children != null )
        {
            var keys = new Array<String>();            // sort children
            for( key in children.keys() )
                keys.push(key);
            keys.sort(function(a,b) return Reflect.compare(a,b));
            for( key in keys )
                children.get(key).walkTree(nodes);
        }
        return nodes;
    }

    // convert dayStr such as (2010-01-01) to path
    public static function pathFromDayStr( dayStr )
    {
        var path = new List<String>();
        path.add(dayStr.substr(0, 4));
        var month = Std.parseInt(dayStr.substr(5, 2))-1;
        var monthStr = Std.string(month);
        if( monthStr.length==1 )
            monthStr = "0"+monthStr;
        path.add(monthStr);
        path.add(dayStr.substr(8, 2));
        return path;
    }
}
