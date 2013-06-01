package com.quasimondo.delaunay
{
	import com.quasimondo.geom.Vector2;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	public class PathfindingNodeProperties extends DelaunayNodeProperties
	{
		public var id:int;
		//used by the BFS so a waypoint is not processed multiple times
		public var marked:Boolean;
		
		//the distance from the start to this waypoint
		public var distance:Number;
		public var prev:DelaunayNode;
		
		
		
		public function PathfindingNodeProperties( id:int = 0 ):void
 		{
 			this.id = id;
 			init();
    	}
    	
    	override public function offset( dx:Number, dy:Number ):void
		{
		}
		
		override public function updateView():void
  	    {
	  	}
	  	
	  	override public function draw( g:Graphics, colorMap:BitmapData = null ):void
	  	{
	  	}
	  	
	   override public function update( mode:String ):void
		{
		}
		
		override public function solve( otherNode:DelaunayNodeProperties, marker:int ):Boolean
		{
			return false
		}
		
		public function init():void
		{
			marked = false;
			distance = 0;
			prev = null;
		}
	  
	  	public function distanceTo( otherNode:DelaunayNode ):Number
		{
			return Math.random();
			//return node.distanceTo( otherNode );// * (1+Math.random())
		}
    	
		override public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			var p:PathfindingNodeProperties = new PathfindingNodeProperties( id );
			p.distance = distance;
			p.marked = marked;
			p.prev = prev;
			if ( replaceNode ) p.node = newNode;
			return p;
		}
    }
}