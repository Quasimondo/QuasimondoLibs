package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	public class DelaunayNode
	{
		
		public var x:Number;
		public var y:Number;
		public var edge:DelaunayEdge;
		public var data:DelaunayNodeProperties;
		public var type:int;
		
		public var next:DelaunayNode;
		
		public function DelaunayNode( $x:Number, $y:Number, $data:DelaunayNodeProperties = null)
		{
			x = $x;
			y = $y
			data = $data
		}
		
		public function reset():void
		{
			if ( data != null ) data.node = null;
			next = null;
			edge = null;
			data = null;
			type = 0;
		}
		
		public function distanceTo( node:DelaunayNode ):Number
		{ 
		  	var dx:Number = node.x - x;
			var dy:Number = node.y - y;
		    return Math.sqrt(dx*dx+dy*dy);
		}
		
		
		public function distance( px:Number, py:Number ):Number
		{ 
			var dx:Number = px - x;
			var dy:Number = py - y;
		    return Math.sqrt(dx*dx+dy*dy);
		}
		
		public function squaredDistance( px:Number, py:Number ):Number
		{ 
			var dx:Number = px - x;
			var dy:Number = py - y;
		    return dx*dx+dy*dy;
		}
		 
		public function draw( g:Graphics, fixedToo:Boolean = false, colorMap:BitmapData = null):void
		{
			if ( data != null )
			{
				data.draw( g, colorMap );
			} else {
				g.drawCircle( x,y,2);
			}
		}
		
		public function clone():DelaunayNode
		{
			var n:DelaunayNode = DelaunayNodes.getNode( x,y);
			if ( data != null ) n.data = data.clone();
			return n;
		}
			
		
		public function toString():String
		{
			return x+", "+y;
		}
		
	}
}