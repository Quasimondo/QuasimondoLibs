package com.quasimondo.geom
{
	import flash.display.Graphics;
	
	public class TrianglePatch
	{
		private var width:Number;
		private var height:Number;
		private var maxArea:Number;
		private var minArea:Number;
		private var reSplitProbability:Number;
		
		private var stack:Array;
		public var triangles:Array;
		
		public static const MODE_LONGEST:int = 0;
		public static const MODE_SHORTEST:int = 1;
		public static const MODE_MIDDLE:int = 2;
		public static const MODE_RANDOM:int = 3;
		
		private var minOffsetFactor:Number = .25;
		private var maxOffsetFactor:Number = .75;
		
		public function TrianglePatch( width:Number, height:Number, firstSplitPoint:Vector2, minArea:Number = 2000, maxArea:Number = 20000, reSplitProbability:Number = 0.4, minOffsetFactor:Number = 0.25, maxOffsetFactor:Number = 0.75, mode:int = MODE_LONGEST  )
		{
			this.width = width;
			this.height = height;
			this.minArea = minArea;
			this.maxArea = maxArea;
			this.reSplitProbability = reSplitProbability;
			this.minOffsetFactor = minOffsetFactor;
			this.maxOffsetFactor = maxOffsetFactor;
			
			
			var p0:Vector2 = new Vector2(0,0);
			var p1:Vector2 = new Vector2(width,0);
			var p2:Vector2 = new Vector2(width,height);
			var p3:Vector2 = new Vector2(0,height);
			
			stack = [];
			triangles = [];
			
			addTriangle( new Triangle( p0,p1,firstSplitPoint));
			addTriangle( new Triangle( p1,p2,firstSplitPoint));
			addTriangle( new Triangle( p2,p3,firstSplitPoint));
			addTriangle( new Triangle( p3,p0,firstSplitPoint));
			
			subdivide( mode );	
		}
		
		private function addTriangle( t:Triangle ):void
		{
			var a:Number = t.area;
			
			if ( a > minArea && ( a > maxArea || Math.random() < reSplitProbability ))
			{
				stack.push(t);
			} else {
				
				triangles.push(t);
			}
		}
		
		
		private function subdivide( mode:int ):void
		{
			var t:Triangle;
			var i:int;
			var d0:Number, d1:Number, d2:Number, splitRatio:Number;
			
			while ( stack.length > 0 )
			{
				t = stack.shift();
				
				d0 = t.getSquaredSide(0);
				d1 = t.getSquaredSide(1);
				d2 = t.getSquaredSide(2);
				
				i=0;
				switch (mode )
				{
					case MODE_LONGEST:
						if (d0 > d1)
						{
							if (d0<d2)
							{
								i=2;
							} 
						} else if (d1>d2)
						{
							i=1;
						} else {
							i=2;
						}
					break;
					case MODE_LONGEST:
						if (d0 < d1)
						{
							if (d0 > d2)
							{
								i=2;
							} 
						} else if ( d1 < d2)
						{
							i=1;
						} else {
							i=2;
						}
					break;
					case MODE_MIDDLE:
						if (d0 < d1)
						{
							if (d0 < d2)
							{
								if ( d2 < d1 )
								{
									i = 2;
								} else {
									i = 1;
								}
							} 
						} else if ( d0 > d2)
						{
							if ( d0 > d1 )
							{
								i = 1;
							} else {
								i = 0;
							}
						}
					break;
					case MODE_RANDOM:
						i = Math.random() * 3;
					break;
				}
				splitRatio = minOffsetFactor + (maxOffsetFactor-minOffsetFactor) * Math.random();
				addTriangle( t.subdivide( i, splitRatio ) );
				addTriangle( t );
				
			}
		}

		public function draw( g:Graphics ):void
		{
			var triangle:Triangle;
			for each ( triangle in triangles )
			{
				triangle.draw( g );
			}
		}

	}
}