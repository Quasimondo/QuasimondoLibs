package com.signalsondisplay.datastructs.graphs
{
	
	/**
	 * Basic graph vertex
	 * version: 0.3
	 * 
	 * @Quasimondo: "index" property added for use in LinearMesh class
	 */
	
	import __AS3__.vec.Vector;
	
	import com.signalsondisplay.datastructs.queues.Prioritizable;
	
	public class Vertex extends Prioritizable
	{
				
		private var _parent:Vertex;
		private var _weight:Number;
		private var _edges:Vector.<GraphEdge>;
		private var _edgeCount:uint;
		private var _visited:Boolean = false;
		public var name:String;
		public var index:int;
		
		public function Vertex( name:String = "", index:int = 0 )
		{
			_edges = new Vector.<GraphEdge>();
			_edgeCount = 0;
			this.name = name;
			this.index = index;
		}
		
		public function addEdge( v:Vertex, weight:Number ):void
		{
			_edges[ _edgeCount ] = new GraphEdge( v, weight );
			_edgeCount++
		}
		
		public function removeEdge( v:Vertex ):void
		{
			for ( var i:int = 0; i < _edgeCount; ++i )
			{
				if ( _edges[ i ].dest == v )
				{
					_edges[ i ].dest = null;
					_edges.splice( i, 1 );
					_edgeCount--;
				}
			}
		}
		
		public function hasEdge( v:Vertex ):Boolean
		{
			for ( var i:int = 0; i < _edgeCount; ++i )
			{
				if ( _edges[ i ].dest == v )
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * removes all edges from this vertex
		 */
		public function removeAllEdges():void
		{
			for ( var i:int = 0; i < _edgeCount; ++i )
			{
				_edges[ i ] = null;
				_edges.splice( i, 1 );
			}
			_edgeCount = 0;
		}
		

		public function get parent():Vertex
		{
			return _parent;
		}
		
		public function set parent( parent:Vertex ):void
		{
			_parent = parent;
		}
		
		public function get edgeCount():uint
		{
			return _edgeCount;
		}
		
		public function get edges():Vector.<GraphEdge>
		{
			return _edges;
		}
		
		public function get weight():Number
		{
			return _weight;
		}
		
		public function set weight( weight:Number ):void
		{
			_weight = weight;
		}
		
		override public function get priority():int
		{
			return _weight;
		}
		
		override public function set priority( priority:int ):void
		{
			_weight = priority;
		}

		public function set visited( visited:Boolean ):void
		{
			_visited = visited;
		}
		
		public function get visited():Boolean
		{
			return _visited;
		}
	
	}
	
}