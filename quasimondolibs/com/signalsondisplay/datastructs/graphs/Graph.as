package com.signalsondisplay.datastructs.graphs
{
	
	/**
	 * Graph class
	 * version: 0.3
	 * to-do:
	 * 	- implement graph traversal algorithms (BFS, DFS)
	 */
	
	import __AS3__.vec.Vector;
	
	public class Graph
	{
	
		private var _vertices:Vector.<Vertex>;
		private var _vertexCount:uint;
		
		public function Graph()
		{
			_vertices = new Vector.<Vertex>();
			_vertexCount = 0;
		}
		
		public function addVertex( vertex:Vertex ):void  
		{
			_vertices.push( vertex );
			_vertexCount++;
		}
		
		/**
		 * removes the specified vertex from the graph
		 * removing a vertex from the graph automaticaly
		 * deletes all it's edges to and from other vertices
		 */
		public function removeVertex( vertex:Vertex ):void
		{
			vertex.removeAllEdges();
			for ( var i:int = 0; i < _vertexCount; ++i )
			{
				var u:Vertex = _vertices[ i ];
				if ( vertex == u )
				{
					_vertices.splice( i, 1 );
					_vertexCount--;
					continue;
				}
				for ( var j:int = 0; j < u.edgeCount; j++ )
				{
					if ( u.edges[ j ].dest == vertex )
						u.removeEdge( vertex );
				}
			}
		}
		
		/**
		 * Adds an edge from vertex u to vertex v
		 * edge weight defaults to 1
		 */
		public function addEdge( u:Vertex, v:Vertex, weight:Number = 1 ):Boolean
		{
			//trace( "Adding edge from", u.name, "to", v.name );
			if ( u && v && u != v )
			{
				u.addEdge( v, weight );
				return true;
			}
			return false;
		}
		
		public function removeEdge( u:Vertex, v:Vertex ):Boolean
		{
			//trace( "Removing edge from", u.name, "to", v.name );
			if ( u && v && u != v )
			{
				u.removeEdge( v );
				return true;
			}
			return false;
		}
		
		public function hasEdge( u:Vertex, v:Vertex ):Boolean
		{
			//trace( "Adding edge from", u.name, "to", v.name );
			if ( u && v && u != v )
			{
				return u.hasEdge( v );
			}
			return false;
		}
		
		public function get vertices():Vector.<Vertex>
		{
			return _vertices;
		}
		
		public function get size():uint
		{
			return _vertexCount;
		}
		
		public function isEmpty():Boolean
		{
			return _vertexCount == 0;
		}
		
		/**
		 * ******************************************************************
		 * Debug util functions                                             *
		 * ******************************************************************
		 */
		public function dbg_vertices():void
		{
			for ( var i:int = 0; i < _vertices.length; ++i )
			{
				trace( "Vertex::", _vertices[ i ].name );
			}
		}
		
		public function dbg_edges():void
		{
			for ( var i:int = 0; i < _vertices.length; ++i )
			{
				var v:Vertex = _vertices[ i ] as Vertex;
				trace( "Vertex::", v.name );
				
				for ( var j:int = 0; j < v.edgeCount; ++j )
				{
					trace( " -", v.edges[ j ].dest.name, "::", v.edges[ j ].cost );
				} 
			}
		}
		
	}
	
}