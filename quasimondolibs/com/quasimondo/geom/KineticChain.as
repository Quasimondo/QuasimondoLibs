package com.quasimondo.geom
{
	import __AS3__.vec.Vector;
	
	import flash.display.Graphics;
	
	public class KineticChain extends Polygon
	{
		
		public static function fromArray( points:Array ):KineticChain
		{
			var cv:KineticChain = new KineticChain();
			for ( var i:int = 0; i < points.length; i++ )
			{
				cv.points.push( Vector2(points[i]) );
			}
			return cv;
		}
		
		public static function fromVector( points:Vector.<Vector2> ):KineticChain
		{
			var cv:KineticChain = new KineticChain();
			cv.points = points.concat();
			return cv;
		}
		
		public function KineticChain()
		{
			super();
		}
		
		public function movePointAtTo( index:int, newPosition:Vector2, enlarge:Boolean = true ):Boolean
		{
			var p0:Vector2 = getPointAt( index - 2 );
			var p1:Vector2 = getPointAt( index - 1 );
			var p2:Vector2 = getPointAt( index );
			var p3:Vector2 = getPointAt( index + 1 );
			var p4:Vector2 = getPointAt( index + 2 );
			
			var d0:Number = p0.distanceToVector( p1 );
			var d1:Number = p1.distanceToVector( p2 );
			var d2:Number = p2.distanceToVector( p3 );
			var d3:Number = p3.distanceToVector( p4 );
			
			var d4:Number = p0.distanceToVector( newPosition );
			var d5:Number = p4.distanceToVector( newPosition );
			
			if ( d4 > d0 + d1 || d5 > d2 + d3 )
			{
			 	//trace("outside range");	
				//TODO find max offset	
				var l:LineSegment = new LineSegment(p2, newPosition );
				var c:Circle;
				var intersection:Intersection;
				
				c = new Circle( p0, d0 + d1 );
				intersection = c.intersect( l );
				if ( intersection.points.length != 0 )
				{
					newPosition = intersection.points[0];
				} else {
					c = new Circle( p4, d2 + d3 );
					if ( l.p1.squaredDistanceToVector(c.c) == c.r )
					{
						newPosition = l.p1;
					} else {
						intersection = c.intersect( l );
						if ( intersection.points.length != 0 )
						{
							newPosition = intersection.points[0];
						} else {
							trace( "error - no intersection at all");
						}
					}
				}
			}
			
			var c0:Circle = new Circle( p0, d0 );
			var c1:Circle = new Circle( p4, d3 );
			
			var c3:Circle = new Circle( newPosition, d1 );
			var c4:Circle = new Circle( newPosition, d2 );
			
			var intersection1:Intersection = c0.intersect( c3 );
			var p1_new:Vector2;
			var p3_new:Vector2;
			
			switch ( intersection1.points.length )
			{
				case 1:
					p1_new = intersection1.points[0];
					break;
				case 2:
					var d6:Number = p1.squaredDistanceToVector( intersection1.points[0] );
					var d7:Number = p1.squaredDistanceToVector( intersection1.points[1] );
					if ( d6 < d7 )
						p1_new = intersection1.points[0];
					else if ( d6 > d7 )
						p1_new = intersection1.points[1];
					else {
						var ct:Vector2 = this.centroid;
						d6 = ct.squaredDistanceToVector( intersection1.points[0] );
						d7 = ct.squaredDistanceToVector( intersection1.points[1] );
						if ( ( d6 > d7 ) == enlarge )
							p1_new = intersection1.points[0];
						else 
							p1_new = intersection1.points[1];
					}
				break;
				case 0:
					//trace( "A no circle intersection: "+intersection1.status);
					return false;
				break;
			}
			
			var intersection2:Intersection = c1.intersect( c4 );
			switch ( intersection2.points.length )
			{
				case 1:
					p3_new = intersection2.points[0];
					break;
				case 2:
					var d8:Number = p3.squaredDistanceToVector( intersection2.points[0] );
					var d9:Number = p3.squaredDistanceToVector( intersection2.points[1] );
					if ( d8 < d9 )
						p3_new = intersection2.points[0];
					else if ( d8 > d9 )
						p3_new = intersection2.points[1];
					else {
						ct = this.centroid;
						d8 = ct.squaredDistanceToVector( intersection2.points[0] );
						d9 = ct.squaredDistanceToVector( intersection2.points[1] );
						if ( ( d8 > d9 ) == enlarge )
							p3_new = intersection2.points[0];
						else 
							p3_new = intersection2.points[1];
					}
				break;
				case 0:
					//trace( "B no circle intersection: "+intersection2.status );
					return false;
				break;
			}
			
			var testChain:KineticChain = KineticChain(clone());
			var p1t:Vector2 = testChain.getPointAt( index - 1 ).setValue( p1_new );
			var p2t:Vector2 = testChain.getPointAt( index ).setValue(newPosition);
			var p3t:Vector2 = testChain.getPointAt( index + 1 ).setValue(p3_new);
			testChain.invalidate();
			if ( !testChain.selfIntersects )
			{
				dirty = true;
				p1.setValue( p1_new );
				p3.setValue( p3_new );
				p2.setValue( newPosition );
			} else {
				trace("self intersection");
				return false
			}
			return true;
		}
		
		public function movePointAtBy( index:int, offsetVector:Vector2, enlarge:Boolean = true  ):void
		{
			movePointAtTo( index, getPointAt( index ).getPlus( offsetVector ), enlarge );
		}
		
		override public function clone(deepClone:Boolean = true ):GeometricShape
		{
			if ( deepClone )
			{
				var tmp:Vector.<Vector2> = new Vector.<Vector2>();
				for ( var i:int = 0; i < points.length; i++ )
				{
					tmp.push( points[i].getClone() );
				}
				return KineticChain.fromVector( tmp );
			} else {
				return KineticChain.fromVector( points );
			}
		}
		
		public function drawMotionZone( index:int, g:Graphics ):void
		{
			var p0:Vector2 = getPointAt( index - 2 );
			var p1:Vector2 = getPointAt( index - 1 );
			var p2:Vector2 = getPointAt( index );
			var p3:Vector2 = getPointAt( index + 1 );
			var p4:Vector2 = getPointAt( index + 2 );
			
			var d0:Number = p0.distanceToVector( p1 );
			var d1:Number = p1.distanceToVector( p2 );
			var d2:Number = p2.distanceToVector( p3 );
			var d3:Number = p3.distanceToVector( p4 );
			
			new Circle( p0, d0 + d1 ).draw( g );
			new Circle( p4, d2 + d3 ).draw( g );
		}
		
		
		
	}
}