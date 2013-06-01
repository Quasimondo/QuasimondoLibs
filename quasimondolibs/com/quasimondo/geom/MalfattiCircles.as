package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class MalfattiCircles
	{
		private var p1:Point;
		private var p2:Point;
		private var p3:Point;
		
		public var center1:Point;
		public var center2:Point;
		public var center3:Point;
		
		public var radius1:Number;
		public var radius2:Number;
		public var radius3:Number;
		
		public function MalfattiCircles( p1:Point, p2:Point, p3:Point )
		{
			updatePoints( p1, p2, p3 )
		}
		
		public function updatePoints( p1:Point, p2:Point, p3:Point ):void
		{
			this.p1 = p1;
			this.p2 = p2;
			this.p3 = p3;
			
			calculate();
		}
		
		public function draw( canvas:Graphics ):void
		{
			canvas.drawCircle( center1.x, center1.y, radius1 );
			canvas.drawCircle( center2.x, center2.y, radius2 );
			canvas.drawCircle( center3.x, center3.y, radius3 );
		}
		
		private function calculate():void
		{
			var incenter:Point = getIncircleCenter( p1, p2, p3 );
			
			var subcenter1:Point = getIncircleCenter( p1, p2, incenter );
			var touchPt_1:Point = getTouchPoint( subcenter1, p1, p2 );
			var r1:Number = subcenter1.subtract( touchPt_1 ).length;
	
			var subcenter2:Point = getIncircleCenter( p1, p3, incenter );
			var touchPt_2:Point = getTouchPoint( subcenter2, p1, p3 );
			var r2:Number = subcenter2.subtract( touchPt_2 ).length;
			
			var subcenter3:Point = getIncircleCenter( p2, p3, incenter );
			var touchPt_3:Point = getTouchPoint( subcenter3, p2, p3 );
			var r3:Number = subcenter3.subtract( touchPt_3 ).length;
			
			var touchC1C2:Point = Point.interpolate( subcenter1,subcenter2, r2 / ( r1 + r2 ) );
			var touchC1C3:Point = Point.interpolate( subcenter1,subcenter3, r3 / ( r1 + r3 ) );
			var touchC2C3:Point = Point.interpolate( subcenter2,subcenter3, r3 / ( r2 + r3 ) );
			
			var lP:Point   = getIntersectionPoint(touchC1C2, touchPt_3, touchC1C3, touchPt_2 );
	
			var hp1:Point  = getIncircleCenter(touchPt_1, lP, p1 );
			
			center1   = getIntersectionPoint(touchPt_1, hp1, p1, incenter );
			radius1 = getIncircleRadius( touchPt_1, lP, touchPt_2, p1 );
			
			var hp2:Point  = getIncircleCenter(touchPt_2, lP, p3 );
			center2   = getIntersectionPoint(touchPt_2, hp2, p3, incenter );
			radius2 = getIncircleRadius( touchPt_2, lP, touchPt_3, p3 );
			
			var hp3:Point  = getIncircleCenter(touchPt_3, lP, p2 );
			center3  = getIntersectionPoint(touchPt_3, hp3, p2, incenter );
			radius3 = getIncircleRadius( touchPt_3, lP, touchPt_1, p2 );
		}
		
		
		private function getIncircleCenter( p1:Point, p2:Point, p3:Point ):Point
		{
			var a:Number = p2.subtract( p3 ).length;
			var b:Number = p1.subtract( p3 ).length;
			var c:Number = p2.subtract( p1 ).length;
			
			var sum:Number = a + b + c;
			
			return new Point( ( a * p1.x + b * p2.x + c * p3.x ) / sum, ( a * p1.y + b * p2.y + c * p3.y ) / sum );
		}
		
		private function getTouchPoint( p1:Point, p2:Point, p3:Point ):Point
		{
			var l:Number = p2.subtract( p3 ).length;
			var u:Number = ( ( p1.x - p2.x ) * ( p3.x - p2.x ) + ( p1.y - p2.y ) * ( p3.y - p2.y ) ) / ( l * l );
			return new Point( p2.x + u * ( p3.x - p2.x ), p2.y + u * ( p3.y - p2.y ));
		}
		
		private function getIntersectionPoint( p1:Point, p2:Point, p3:Point, p4:Point ):Point
		{
			var x1:Number = p1.x;
			var x2:Number = p2.x;
			var x3:Number = p3.x;
			var x4:Number = p4.x;
			
			var y1:Number = p1.y;
			var y2:Number = p2.y;
			var y3:Number = p3.y;
			var y4:Number = p4.y;
			
			var d:Number =  ( y4 - y3 ) * (x2 - x1 ) - ( x4 - x3 ) * ( y2 - y1 );
			
			var ua:Number = (( x4 - x3 ) * ( y1 - y3 ) - ( y4 - y3 ) * ( x1 - x3 ) ) / d;
			var ub:Number = (( x2 - x1 ) * ( y1 - y3 ) - ( y2 - y1 ) * ( x1 - x3 ) ) / d;
			
			return new Point( x1 + ua * ( x2 - x1 ), y1 + ua * ( y2 - y1 ) );
		}
		
		private function getIncircleRadius( p1:Point, p2:Point, p3:Point, p4:Point ):Number
		{
			var a:Number = p1.subtract( p2 ).length;
			var b:Number = p2.subtract( p3 ).length;
			var c:Number = p3.subtract( p4 ).length;
			var d:Number = p4.subtract( p1 ).length;
			
			var p:Number = p1.subtract( p3 ).length;
			var q:Number = p2.subtract( p4 ).length;
			
			var t:Number = a*a - b*b + c*c - d*d;
			return Math.sqrt( ( 4 * p*p * q*q - t*t ) ) / ( 2 * ( a + b + c + d ) ) ;
		}
	}
}