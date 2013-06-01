package com.signalsondisplay.datastructs.graphs
{
	
	/**
	 * GraphEdge class
	 * version: 0.3
	 */
	
	public class GraphEdge
	{
	
		public var cost:Number;
		public var dest:Vertex;
		
		public function GraphEdge( dest:Vertex, cost:Number )
		{
			this.dest = dest;
			this.cost = cost;
		}

	}
	
}