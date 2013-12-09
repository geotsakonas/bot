library bot.graph;

import 'dart:math' as math;
import 'dart:collection';
import 'require.dart';

part 'graph/topo_sort.dart';

// http://en.wikipedia.org/wiki/Tarjan's_strongly_connected_components_algorithm

List<List> stronglyConnectedComponents(Map graph) {
  assert(graph != null);

  var nodes = new _TarjanList(graph);
  var tarjan = new _TarjanCycleDetect._internal(nodes);
  return tarjan._executeTarjan();
}

/**
 * Use top-level [stronglyConnectedComponents] instead.
 */
@deprecated
class TarjanCycleDetect<TNode> {

  /**
   * Use top-level [stronglyConnectedComponents] instead.
   */
  @deprecated
  static List<List> getStronglyConnectedComponents(Map graph) =>
      stronglyConnectedComponents(graph);
}

class _TarjanCycleDetect<T> {

  int _index = 0;
  final List<_TarjanNode> _stack;
  final List<List<T>> _scc;
  final _TarjanList _list;

  _TarjanCycleDetect._internal(this._list) :
    _index = 0,
    _stack = new List<_TarjanNode<T>>(),
    _scc = new List<List<T>>();

  List<List<T>> _executeTarjan() {
    List<_TarjanNode> nodeList = new List<_TarjanNode>.from(_list.getSourceNodeSet());
    for (final node in nodeList)
    {
      if(node.index == -1) {
        _tarjan(node);
      }
    }
    return _scc;
  }

  void _tarjan(_TarjanNode<T> v){
    v.index = _index;
    v.lowlink = _index;
    _index++;
    _stack.insert(0, v);
    for(final n in _list.getAdjacent(v)){
      if(n.index == -1){
        _tarjan(n);
        v.lowlink = math.min(v.lowlink, n.lowlink);
      } else if(_stack.indexOf(n) >= 0){
        v.lowlink = math.min(v.lowlink, n.index);
      }
    }
    if(v.lowlink == v.index){
      _TarjanNode n;
      var component = new List<T>();
      do {
        n = _stack[0];
        _stack.removeRange(0, 1);
        component.add(n.value);
      } while(n != v);
      _scc.add(component);
    }
  }
}

class _TarjanNode<T> {
  final T value;
  int index;
  int lowlink;

  _TarjanNode(this.value):
    index = -1;

  int get hashCode => value.hashCode;

  bool operator ==(_TarjanNode<T> other) => other.value == value;
}

class _TarjanList<T> {
  final Map<_TarjanNode<T>, Set<_TarjanNode<T>>> _nodes;

  _TarjanList._internal(this._nodes);

  factory _TarjanList(Map<T, Set<T>> source) {
    assert(source != null);

    var map = new Map<T, _TarjanNode<T>>();

    var nodes = new Map<_TarjanNode<T>, Set<_TarjanNode<T>>>();

    source.forEach((k,v) {
      final tKey = map.putIfAbsent(k, () => new _TarjanNode(k));
      var edges = nodes[tKey] = new Set<_TarjanNode<T>>();

      if(v != null) {
        for(final edge in v) {
          final tEdge = map.putIfAbsent(edge, () => new _TarjanNode(edge));
          edges.add(tEdge);
        }
      }
    });

    return new _TarjanList._internal(nodes);
  }

  Iterable<_TarjanNode> getSourceNodeSet() {
    return _nodes.keys;
  }

  Iterable<_TarjanNode> getAdjacent(_TarjanNode v) {
    var nodes = _nodes[v];
    if(nodes == null) {
      return [];
    }
    else {
      return nodes;
    }
  }
}
