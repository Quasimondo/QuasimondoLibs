package com.quasimondo.delaunay
{
	import com.quasimondo.bitmapdata.Pixel;

	public class DelaunayPixelNodeProperties extends DelaunayNodeProperties
	{
		public var pixel:Pixel;
		public function DelaunayPixelNodeProperties( pixel:Pixel )
		{
			this.pixel = pixel;
		}
		
		override public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			var p:DelaunayPixelNodeProperties = new DelaunayPixelNodeProperties( pixel );
			if ( replaceNode ) p.node = newNode;
			return p;
		}
	}
}