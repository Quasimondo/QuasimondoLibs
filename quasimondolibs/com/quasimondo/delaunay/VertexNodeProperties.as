package com.quasimondo.delaunay
{
	import com.quasimondo.geom.Vector2;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	public class VertexNodeProperties extends DelaunayNodeProperties
	{
		public var vertex:Vector2;
		public var id:int;
		
		public function VertexNodeProperties():void
 		{
    	}
    	
    	override public function offset( dx:Number, dy:Number ):void
		{
		}
		
		override public function updateView():void
  	    {
	  	}
	  	
	  	override public function draw( g:Graphics, colorMap:BitmapData = null ):void
	  	{
	  		g.drawCircle( vertex.x,vertex.y,2);
	  	}
	  	
	   override public function update( mode:String ):void
		{
		}
		
		override public function solve( otherNode:DelaunayNodeProperties, marker:int ):Boolean
		{
			return false
		}
		
		override public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			var p:VertexNodeProperties = new VertexNodeProperties();
			p.id = id;
			p.vertex = vertex;
			if ( replaceNode ) p.node = newNode;
			return p;
		}
	  	
    	
    }
}