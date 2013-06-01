package com.quasimondo.delaunay
{
	public class BoundingTriangleNodeProperties extends DelaunayNodeProperties
	{
		public function BoundingTriangleNodeProperties()
		{
			super();
			relaxable = false;
		}
		
		override public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			var p:BoundingTriangleNodeProperties = new BoundingTriangleNodeProperties();
			if ( replaceNode ) p.node = newNode;
			return p;
		}
	}
}