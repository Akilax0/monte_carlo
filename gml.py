import textwrap


class Graphics(object):

    def __init__(self, x: float, y: float, z: float, w=10.0, h=10.0, d=10.0, fill="#c0c0c0"):
        self.x = x
        self.y = y
        self.z = z
        self.w = w
        self.h = h
        self.d = d
        self.fill = fill

    def __str__(self):
        return textwrap.dedent("""
        graphics
        [
          y {1}
          z {2}
          w {3}
          h {4}
          d {5}
          fill "{6}"
        ]""".format(self.x, self.y, self.z, self.w, self.h, self.d, self.fill))


class Node(Graphics):

    def __init__(self, id, label: str, num, x: float, y: float, z: float=0.0, image="", w=10.0, h=10.0, d=10.0, fill="#c0c0c0"):
        super().__init__(x, y, z, w, h, d, fill)
        self.id = id
        self. label = label
        self.image = image
        self.num = num

    def __str__(self):
        return textwrap.dedent("""
        node
        [
          id {0}
          label "{1}"
          image "{2}.png"
          num "{3}\"""".format(self.id, self.label, self.image, self.num)) + "{0}\n]".format(super().__str__().replace('\n', '\n  '))


class Edge(object):

    def __init__(self, id: int, source: Node, target: Node, label: str, value: float=1.0, fill: str="#808080"):
        if not(type(source) is Node and type(target) is Node and type(value) is float):
            raise TypeError('Some of the arguments are of incorrect type')
        self.id = id
        self.source = source
        self.target = target
        self.label = label
        self.value = value
        self.fill = fill

    def __str__(self):
        return textwrap.dedent("""
        edge
        [
          id {0}
          source {1}
          target {2}
          label "{3}"
          value {4}
          fill "{5}"
        ]""".format(self.id, self.source.id, self.target.id, self.label, self.value, self.fill))


class DictNode(dict):
    def __init__(self):
        super().__init__()

    def __setitem__(self, key: int, value: Node):
        if type(value) is not Node:
            raise TypeError('Value must be a Node object')
        elif key is None or value.id == key:
            super().__setitem__(value.id, value)
        else:
            raise ValueError('Key must be the Node id')

    def append(self, value: Node) -> None:
        if type(value) is not Node:
            raise TypeError('Value must be a Node object')
        super().__setitem__(value.id, value)

    def __str__(self):
        s = ''
        for i in self.values():
            s += str(i)
        return s


class DictEdge(dict):
    def __init__(self, nodes: DictNode):
        if type(nodes) is not DictNode:
            raise TypeError('Parameter nodes must be a DictNode')
        super().__init__()
        self.__nodes = nodes

    def __setitem__(self, key: int, value: Edge):
        if type(value) is not Edge:
            raise TypeError('Value must be a Edge object')
        elif key is None or value.id == key:
            super().__setitem__(value.id, value)
            self.__nodes[value.target.id] = value.target
            self.__nodes[value.source.id] = value.source
        else:
            raise ValueError('Key must be the Edge id')

    def append(self, value: Edge) -> None:
        if type(value) is not Edge:
            raise TypeError('Value must be a Edge object')
        super().__setitem__(value.id, value)
        self.__nodes[value.target.id] = value.target
        self.__nodes[value.source.id] = value.source

    def __str__(self):
        s = ''
        for i in self.values():
            s += str(i)
        return s


class Graph(object):

    def __init__(self, creator: str="Henrique", directed: int=1):
        self.creator = creator
        self.directed = directed
        self.nodes = DictNode()
        self.edges = DictEdge(self.nodes)

    def __str__(self):
        return textwrap.dedent("""
        graph
        [
          Creator "{0}"
          directed {1}""".format(self.creator, self.directed))+"""{0}{1}\n]
        """.format(str(self.nodes).replace('\n', '\n  '), str(self.edges).replace('\n', '\n  '))

# n2 = Node(1, "1", 1.0, 3.0, 0.0)
# g = Graph()
# n = Node(2, "1", 1.0, 3.0, 0.0)
# e = Edge(1, n, n2)
# g.edges[None] = e
# print(g)