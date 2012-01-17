package mymetrics.node;

class NodeIterator
{
    private var nodes :List<Node>;

    // walk the tree saving a list of nodes using preorder traversal
    public function new(n)
    {
        nodes = n;
    }

    public function hasNext()
    {
        return !nodes.isEmpty();
    }

    public function next()
    {
        return nodes.pop();
    }
}
