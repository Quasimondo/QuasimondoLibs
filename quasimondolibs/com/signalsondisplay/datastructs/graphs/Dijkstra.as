package com.signalsondisplay.datastructs.graphs
{
	
	/**
	 * Dijkstra's shortes path weight algorithm
	 * version: 1.0
	 */
	 
	import __AS3__.vec.Vector;
	
	import com.signalsondisplay.datastructs.linkedlists.ListNode;
	import com.signalsondisplay.datastructs.queues.PriorityQueue;
	
	public class Dijkstra
	{
	
		private var _graph:Graph;
		private var _src:Vertex;
		private var _dest:Vertex;
		private var _queue:PriorityQueue;
		
		public function Dijkstra( graph:Graph, src:Vertex, dest:Vertex )
		{
			_graph = graph;
			_src = src;
			_dest = dest;
			_queue = new PriorityQueue();
		}
		
		public function search():Vertex
		{
			var u:Vertex;
			var v:Vertex;
			var i:int;
			
			_graph.vertices.forEach( addToQueue );
			_src.weight = 0;
			while ( !_queue.isEmpty() )
			{
				if ( ( u = _queue.extractMin() as Vertex ) == null )
					break;
				if ( u == _dest )
					return _dest;
				i = 0;
				while ( i < u.edgeCount )
				{
					v = u.edges[ i ].dest;
					if ( v.visited ) { i++; continue; }
					if ( v.weight > ( u.weight + u.edges[ i ].cost ) )
					{
						v.weight = u.weight + u.edges[ i ].cost;
						v.parent = u;
					}
					i++;
				}
				u.visited = true;
			}
			return null;
		}
		
		private function addToQueue( v:Vertex, index:int, vector:Vector.<Vertex> ):void
		{
			v.weight = int.MAX_VALUE;
			v.visited = false;
			v.parent = null;
			_queue.enqueue( v );
		}

	}
	
}