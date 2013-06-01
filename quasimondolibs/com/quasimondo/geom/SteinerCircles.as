package com.quasimondo.geom
{
	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.Graphics;
	
	public class SteinerCircles
	{
		
		public var circles:Vector.<Circle>;
		public var outerCircle:Circle;
		
		
		private var parentCircle:Circle;
		private var ratio:Number;
		private var circleCount:int;
		
		private var a:Number;
		private var b:Number;
		private var angleStep:Number;
		private var piFactor:Number;
		private var centerFactor:Number;
		private var rotAngle:Number;
		
		private var center:Vector2;
		private var inverter:Vector2;
		
			
		
		public function SteinerCircles()
		{
		}
		
		
		public function init( parentCircle:Circle, circleCount:int, ratio:Number, rotation:Number, startAngle:Number = 0 ):void
		{
			var i:int;
			
			this.parentCircle = parentCircle;
			this.circleCount = Math.max(3,circleCount);
			this.ratio = ratio;
			
			angleStep = Math.PI / circleCount;
			piFactor = Math.sin( angleStep );
			centerFactor = ( 1 - piFactor) / ( 1 + piFactor );
			
			var radius:Number = parentCircle.r;
			a = 2 * radius;
			b = a * centerFactor;
			var c:Number = ( a - b ) / 2;
			
			var satelitesDistance:Number = b + c;
			rotAngle = 0;
			
			center = new Vector2();
			circles = new Vector.<Circle>();
			
			var points:Vector.<Vector2> = new Vector.<Vector2>();
			var angle:Number;
			for ( i = 0; i < circleCount; i++) 
			{
				angle = 2*angleStep*i - rotation + startAngle;
				points.push( new Vector2( Math.cos(angle+angleStep)*satelitesDistance, Math.sin(angle+angleStep)*satelitesDistance));
				points.push( new Vector2( Math.cos(angle)*a, Math.sin(angle)*a));
				points.push( new Vector2( Math.cos(angle)*b, Math.sin(angle)*b));
			}
		
			
			inverter = new Vector2(  parentCircle.r * ratio * Math.cos(rotation), parentCircle.r * ratio * Math.sin(rotation));
			
			var innerPoints:Vector.<Vector2> = new Vector.<Vector2>();
			var outerPoints:Vector.<Vector2> = new Vector.<Vector2>();
			var p:Array;
			var j:int;
			var p1:Vector2;
			var p2:Vector2;
			var p3:Vector2;
			
			for ( i = 0;  i < circleCount; i++) 
			{
				p1 = invert( points[ int( i * 3 ) ] );
				p2 = invert( points[ int( i * 3 + 1 )] );
				p3 = invert( points[ int( i * 3 + 2) ] );
				
				innerPoints.push( p2 );
				outerPoints.push( p3 );
				
				circles.push( Circle.from3Points(p1, p2, p3) );
			}
		
			circles.push( Circle.from3Points( innerPoints[0],  innerPoints[1],  innerPoints[2] ) );
			outerCircle = Circle.from3Points( outerPoints[0],  outerPoints[1],  outerPoints[2] );
			
			var scale:Number =  parentCircle.r / outerCircle.r;
			var circle:Circle;
			
			for ( i = 0;  i < circles.length; i++) 
			{
				circle = circles[i];
				circle.c.minus( outerCircle.c );
				circle.c.multiply( scale );
				circle.r *= scale;
				circle.c.plus( parentCircle.c );
			}
			
			
			outerCircle.r *= scale;
			outerCircle.c.setValue( parentCircle.c );
			
			
		}
		
		private function invert( p:Vector2 ):Vector2
		{
			var dx:Number = p.x - inverter.x;
			var dy:Number = p.y - inverter.y;
			var dxy:Number = dx * dx + dy * dy ;
			if ( dxy == 0 ) dxy = 1 / Number.MAX_VALUE;
			return inverter.getPlus( new Vector2( dx  / dxy, dy / dxy) );
		}
		
		public function draw( canvas:Graphics ):void
		{
			for each ( var circle:Circle in circles ) circle.draw(canvas);
		}
	}
}

