package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;

	public class DelaunayColorNodeProperties extends DelaunayNodeProperties
	{
		public var rgba:uint;
		public function DelaunayColorNodeProperties( rgba:uint, relaxable:Boolean = true )
		{
			this.rgba = rgba;
			this.relaxable = relaxable;
		}
		
		override public function draw( g:Graphics, colorMap:BitmapData = null ):void
		{
			g.beginFill(rgba & 0xffffff)
			g.drawCircle(node.x,node.y,1);
			g.endFill();
		}
		
		override public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			var p:DelaunayColorNodeProperties = new DelaunayColorNodeProperties( rgba );
			if ( replaceNode ) p.node = newNode;
			return p;
		}
	}
}