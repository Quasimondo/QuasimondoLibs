package com.quasimondo.geom
{
	import com.quasimondo.geom.Circle;
	
	import flash.display.Graphics;
	import flash.display.Sprite;

	public class DoyleFlower
	{
		public var circles:Vector.<Circle>;
		public var centerCircle:Circle;
		public var angles:Vector.<Number>;
		public var fixed:Vector.<Boolean>;
		public var fixedCircles:Vector.<Circle>;
		
		public var a:Number;
		public var b:Number;
		
		private var r:Number;
		private var rotation:Number;
		
		private static const SNAP_DISTANCE:Number = 0.000000001;
		private var radii:Vector.<Number>;
		
		public static function fromCirclesAB( circleA:Circle, circleB:Circle, r:Number, clockwise:Boolean ):DoyleFlower
		{
			var center:Circle = new Circle(0,0,r);
			
			return null;
		}
		
		public function DoyleFlower( center:Circle, a:Number, b:Number, rotation:Number = 0)
		{
			init( center, a, b, rotation );
		}
		
		private function init( center:Circle, a:Number, b:Number, rotation:Number = 0):void
		{
			centerCircle = center;
			this.a = a;
			this.b = b;
			r = centerCircle.r;
			this.rotation = rotation;
			
			circles = new Vector.<Circle>(6,true);
			angles = new Vector.<Number>(6,true);
			fixed = new Vector.<Boolean>(6,true);
			fixedCircles = new Vector.<Circle>();
			
			
			radii = new Vector.<Number>();
			radii.push(r*a);
			radii.push(r*a/b);
			radii.push(r/b);
			radii.push(r/a);
			radii.push(r*b/a);
			radii.push(r*b);
		}
		
		public function calculate():void
		{
			var firstSetRadiusIndex:int = -1;
			if ( fixedCircles.length > 0 )
			{
				firstSetRadiusIndex = getRadiusIndex( fixedCircles[0] );
			}
			
			if ( firstSetRadiusIndex == -1 )
			{
				angles[0] = rotation;
				circles[0] = new Circle( centerCircle.c.getAddCartesian( angles[0], centerCircle.r + radii[0] ), radii[0]);
				firstSetRadiusIndex = 0;
				fixed[0] = true;
			} else {
				circles[firstSetRadiusIndex] = fixedCircles.shift();
				angles[firstSetRadiusIndex] = centerCircle.c.angleTo(circles[firstSetRadiusIndex].c);
				fixed[firstSetRadiusIndex] = true;
				
			}
			
			var ta:Number, tb:Number, tc:Number;
			var currentIndex:int;
			var nextIndex:int;
			for ( var i:int = firstSetRadiusIndex; i < firstSetRadiusIndex+6; i++ )
			{
				currentIndex = i % 6;
				nextIndex = (i+1)%6;
				if (fixed[currentIndex] && !fixed[nextIndex] )
				{
					circles[nextIndex] = new Circle( 0,0, radii[nextIndex]);
					var angle:Number = Math.acos( (Math.pow( tb = (centerCircle.r + circles[nextIndex].r) ,2 ) + Math.pow( tc = (centerCircle.r + circles[currentIndex].r),2 ) -  Math.pow( ta = (circles[currentIndex].r + circles[nextIndex].r),2 ) ) / ( 2 * tb * tc ));
					angles[nextIndex] = angle + angles[currentIndex];
					fixed[nextIndex] = true;
					circles[nextIndex].c = centerCircle.c.getAddCartesian( angles[nextIndex], centerCircle.r + circles[nextIndex].r );
				}
			}
			
			for ( i = fixedCircles.length; --i > -1; )
			{
				for ( var j:int = 0; j < 6; j++ )
				{
					if ( circles[j].snaps( fixedCircles[i] ))
					{
						circles[j] = fixedCircles[i];
						fixedCircles.splice(i,1);
						break;
					}
				}
			}
		}
		
		
		public function draw( canvas:Graphics):void
		{
			centerCircle.draw(canvas);
			for each( var c:Circle in circles ) {
				c.draw( canvas); 
			}
		}
		
		
		private function getRadiusIndex( c:Circle ):int
		{
			for ( var i:int = 0; i < radii.length; i++ )
			{
				if ( Math.abs(radii[i]- c.r ) < SNAP_DISTANCE ) 
				{
					return i;
				}
			}
			return -1;
		}
	}
}