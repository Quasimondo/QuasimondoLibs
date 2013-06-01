package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	public class DelaunayNodeProperties
	{
		public var node:DelaunayNode;
		public var relaxable:Boolean = true;
		
		
		public function DelaunayNodeProperties( relaxable:Boolean = true):void
 		{
			this.relaxable = relaxable;
    	}
    	
    	public function offset( dx:Number, dy:Number ):void
		{
		}
		
		public function updateView():void
  	    {
	  	}
	  	
	  	public function draw( g:Graphics, colorMap:BitmapData = null ):void
	  	{
	  	}
	  	
	   	public function update( mode:String ):void
		{
		}
		
		public function solve( otherNode:DelaunayNodeProperties, marker:int ):Boolean
		{
			return false
		}
	  	
		public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			var p:DelaunayNodeProperties = new DelaunayNodeProperties();
			if ( replaceNode ) p.node = newNode;
			return p;
		}
    	
    }
}