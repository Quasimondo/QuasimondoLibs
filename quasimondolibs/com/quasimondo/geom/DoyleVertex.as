package com.quasimondo.geom
{
	import com.quasimondo.geom.Circle;
	import com.signalsondisplay.datastructs.graphs.Vertex;
	
	public class DoyleVertex extends Vertex
	{
		public var circle:Circle;
		
		public function DoyleVertex(index:int=0, circle:Circle = null )
		{
			super("", index);
			this.circle = circle;
		}
	}
}