package com.quasimondo.delaunay
{
	import com.quasimondo.geom.ConvexPolygon;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.Graphics;
	
	public class VoronoiRegion
	{
		public var p:DelaunayNode;
		public var polygon:ConvexPolygon;
		public var neighbors:Vector.<VoronoiRegion>;
		
  		public function VoronoiRegion( $p:DelaunayNode ):void
		{
			update( $p ); 
		}
		
		public function reset():void
		{
			p = null;
			polygon = new ConvexPolygon();
			neighbors = new Vector.<VoronoiRegion>();
		}
		
		public function update( $p:DelaunayNode):void
		{ 
			p = $p;
			polygon = new ConvexPolygon();
			neighbors = new Vector.<VoronoiRegion>();
		}
		
		public function addPoint( p:Vector2 ):void
		{
			polygon.addPoint( p );
		}
		
		public function draw( g:Graphics):void
		{ 
			polygon.draw( g );
		}
		
		public function addNeighbor( region:VoronoiRegion ):void
		{
			neighbors.push ( region );
		}
		
	}
}