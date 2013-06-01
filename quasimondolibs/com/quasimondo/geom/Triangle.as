package com.quasimondo.geom
{

	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Triangle extends GeometricShape implements IIntersectable
	{
		public var p1:Vector2;
		public var p2:Vector2;
		public var p3:Vector2;
		
		public function Triangle ( p1:Vector2, p2:Vector2, p3:Vector2 )
		{
			this.p1 = p1;
			this.p2 = p2;
			this.p3 = p3;
		}
		
		static public function getCenteredTriangle( center:Vector2, leftLength:Number, rightLength:Number, bottomLength:Number, angle:Number = 0 ):Triangle
		{
			var alpha:Number = - Math.acos( ( leftLength * leftLength - rightLength * rightLength + bottomLength * bottomLength ) / ( 2 * leftLength * bottomLength) );
			if ( isNaN( alpha )) return null;
			
			var v1:Vector2 = new Vector2(0,0);
			var v2:Vector2 = new Vector2(bottomLength,0 );
			var v3:Vector2 = new Vector2( Math.cos( alpha ) * leftLength, Math.sin( alpha ) * leftLength );
			
			var triangle:Triangle = new Triangle( v1, v2, v3 );
			var ctr:Vector2 = triangle.centerOfMass;
			if ( angle != 0 ) triangle.rotate( angle );
			triangle.translate( center.getMinus( ctr ) );
			
			return triangle;
		}
		
		static public function getEquilateralTriangle( pa:Vector2, pb:Vector2, flipped:Boolean = false ):Triangle
		{
			return new Triangle( pa, pb, new Vector2( pa.getAddCartesian(pa.angleTo(pb) +  Math.PI / 3 * ( flipped ? -1 : 1), pa.distanceToVector( pb ))) );
		}
		
		override public function translate(offset:Vector2):GeometricShape
		{
			p1.plus( offset );
			p2.plus( offset );
			p3.plus( offset );
			return this;
		}
		
		public function updateFromPoints( p1:Point = null, p2:Point = null, p3:Point = null):void
		{
			if ( p1 != null ) {
				this.p1.x = p1.x;
				this.p1.y = p1.y;
			}
			
			if ( p2 != null ) {
				this.p2.x = p2.x;
				this.p2.y = p2.y;
			}
			
			if ( p3 != null ) {
				this.p3.x = p3.x;
				this.p3.y = p3.y;
			}
		}
		
		override public function get type():String
		{
			return "Triangle";
		}
		
		public function getSide( index:int ):LineSegment
		{
			switch ( index )
			{
				case 0:
					return new LineSegment(p1, p2 );
				break;
				case 1:
					return new LineSegment(p1, p3 );
				break;
				case 2:
					return new LineSegment(p2, p3 );
				break;
			}
			return null;
		}
		
		
		public function getSideLength( index:int ):Number
		{
			switch ( index )
			{
				case 0:
					return p1.distanceToVector( p2 );
				break;
				case 1:
					return p1.distanceToVector( p3 );
				break;
				case 2:
					return p2.distanceToVector( p3 );
				break;
			}
			return NaN;
		}
		
		public function getLongestSideIndex( ):int
		{
			var l1:Number = p1.distanceToVector( p2 );
			var l2:Number = p1.distanceToVector( p3 );
			var l3:Number = p2.distanceToVector( p3 );
				
			if ( l1 >= l2 && l1 >= l3 ) return 0;
			if ( l2 >= l1 && l2 >= l3 ) return 1;
			return 2;
		}
		
		public function getSquaredSide( index:int ):Number
		{
			switch ( index )
			{
				case 0:
					return p1.squaredDistanceToVector( p2 );
				break;
				case 1:
					return p1.squaredDistanceToVector( p3 );
				break;
				case 2:
					return p2.squaredDistanceToVector( p3 );
				break;
			}
			return NaN;
		}
		
		public function subdivide( index:int, ratio:Number ):Triangle
		{
			index = (index % 3 + 3) % 3;
			var splitPoint:Vector2;
			var t:Triangle;
			switch ( index )
			{
				case 0:
					splitPoint = p1.getLerp( p2, ratio );
					t = new Triangle( splitPoint, p1, p3 );
					p1 = splitPoint;
				break;
				case 1:
					splitPoint = p1.getLerp( p3, ratio );
					t = new Triangle( splitPoint, p1, p2 );
					p1 = splitPoint;
					
				break;
				case 2:
					splitPoint = p2.getLerp( p3, ratio );
					t = new Triangle( splitPoint, p2, p1 );
					p2 = splitPoint;
				break;
			}
			return t;
		}
		
		
		public function get area():Number
		{
			return Math.abs((p1.x-p2.x)*(p1.y-p3.y)-(p1.y-p2.y)*(p1.x-p3.x));
		}
		
		override public function isInside( p:Vector2, includeVertices:Boolean = false ):Boolean
		{
			// Compute vectors        
			var v0:Vector2 = p3.getMinus( p1 );
			var v1:Vector2 = p2.getMinus( p1 );
			var v2:Vector2 = p.getMinus( p1 );
			
			// Compute dot products
			var dot00:Number = v0.dot(v0);
			var dot01:Number = v0.dot(v1);
			var dot02:Number = v0.dot(v2);
			var dot11:Number = v1.dot(v1);
			var dot12:Number = v1.dot(v2);
			
			// Compute barycentric coordinates
			var invDenom:Number = 1 / (dot00 * dot11 - dot01 * dot01);
			var u:Number = (dot11 * dot02 - dot01 * dot12) * invDenom;
			var v:Number = (dot00 * dot12 - dot01 * dot02) * invDenom;
			
			// Check if point is in triangle
			return includeVertices ? ((u >= 0) && (v >= 0) && (u + v <= 1)) : ((u > 0) && (v > 0) && (u + v < 1));
		}
		
		public function isInsideXY( x:Number, y:Number ):Boolean
		{
			return isInside( new Vector2(x,y));
		}
		
		
		override public function draw ( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.lineTo( p2.x, p2.y );
			g.lineTo( p3.x, p3.y );
			g.lineTo( p1.x, p1.y );
		}
		
		override public function export( g:IGraphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.lineTo( p2.x, p2.y );
			g.lineTo( p3.x, p3.y );
			g.lineTo( p1.x, p1.y );
		}
		
		override public function drawTo ( g: Graphics ):void
		{
			g.lineTo( p2.x, p2.y );
			g.lineTo( p3.x, p3.y );
			g.lineTo( p1.x, p1.y );
		}
		
		override public function moveToStart ( g: Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function moveToEnd ( g: Graphics ): void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
		
			var minP:Vector2 = p1.getMin( p2 ).getMin( p3 );
			var size:Vector2 = p1.getMax( p2 ).getMax( p3 ).minus( minP );
			return new Rectangle( minP.x, minP.y , size.x, size.y  );
		}
		
		
		
		public function getMalfattiCircles():Array
		{
			var incenter:Vector2 = getIncircleCenter( p1, p2, p3 );
			
			var subcenter1:Vector2 = getIncircleCenter( p1, p2, incenter );
			var touchPt_1:Vector2 = getTouchPoint( subcenter1, p1, p2 );
			var r1:Number = subcenter1.distanceToVector( touchPt_1 );
	
			var subcenter2:Vector2 = getIncircleCenter( p1, p3, incenter );
			var touchPt_2:Vector2 = getTouchPoint( subcenter2, p1, p3 );
			var r2:Number = subcenter2.distanceToVector( touchPt_2 );
			
			var subcenter3:Vector2 = getIncircleCenter( p2, p3, incenter );
			var touchPt_3:Vector2 = getTouchPoint( subcenter3, p2, p3 );
			var r3:Number = subcenter3.distanceToVector( touchPt_3 );
			
			var touchC1C2:Vector2 = subcenter1.getLerp( subcenter2, r2 / ( r1 + r2 ) );
			var touchC1C3:Vector2 = subcenter1.getLerp(subcenter3, r3 / ( r1 + r3 ) );
			var touchC2C3:Vector2 = subcenter2.getLerp(subcenter3, r3 / ( r2 + r3 ) );
			
			var lP:Vector2   = getIntersectionPoint(touchC1C2, touchPt_3, touchC1C3, touchPt_2 );
	
			var hp1:Vector2  = getIncircleCenter(touchPt_1, lP, p1 );
			var center1:Vector2  = getIntersectionPoint(touchPt_1, hp1, p1, incenter );
			var radius1:Number = getIncircleRadius( touchPt_1, lP, touchPt_2, p1 );
			
			var hp2:Vector2  = getIncircleCenter(touchPt_2, lP, p3 );
			var center2:Vector2   = getIntersectionPoint(touchPt_2, hp2, p3, incenter );
			var radius2:Number = getIncircleRadius( touchPt_2, lP, touchPt_3, p3 );
			
			var hp3:Vector2  = getIncircleCenter(touchPt_3, lP, p2 );
			var center3:Vector2  = getIntersectionPoint(touchPt_3, hp3, p2, incenter );
			var radius3:Number = getIncircleRadius( touchPt_3, lP, touchPt_1, p2 );
		
			return [ new Circle( center1, radius1 ),  new Circle( center2, radius2 ),  new Circle( center3, radius3 )];
		}
		
		public function get inCircle():Circle
		{
			var center:Vector2 = getIncircleCenter( p1, p2, p3 );
			
			return new Circle( center, getSide(0).distanceToPoint( center ) );
		}
		
		public function getInCircleTangentTriangle( index:int ):Triangle
		{
			var p:Vector2;
			switch ( index )
			{
				case 0:
					p = p1;
				break;
				case 1:
					p = p2;
				break;
				case 2:
					p = p3;
				break;
				default:
					return null;
				break;
			}
			var c:Circle = inCircle;
			var l:LineSegment = new LineSegment( p, c.c );
			var s1:Intersection = l.intersect( c );
			var o:LineSegment = l.getOrth( Vector2( s1.points[0]), c.r * 2, c.r * 2 );
			var s2:Intersection = intersect( o );
			return new Triangle( p, Vector2(s2.points[0]), Vector2(s2.points[1]) );
			
		}
		
		public function getRandomSubdivisions( count:int, minRatio:Number = 0.25, maxRatio:Number = 0.75  ):Array
		{
			var result:Array = [];
			var p:Array = [p1];
			p.splice( int( Math.random() * 2), 0, p2 );
			p.splice( int( Math.random() * 3), 0, p3 );
			
			var v1:Vector2 = Vector2( p[0] );
			var v2:Vector2 = Vector2( p[1] );
			var v3:Vector2 = Vector2( p[2] );
			
			
			var range:Number = maxRatio - minRatio;
			var pn1:Vector2, pn2:Vector2, pn3:Vector2;
			
			switch ( count )
			{
				case 2:
					pn1 = v1.getLerp( v2, minRatio + Math.random() * range );
					result.push( new Triangle( pn1, v1, v3 ));
					result.push( new Triangle( pn1, v2, v3 ));
				break;
				case 3:
					pn1 = v1.getLerp( v2, minRatio + Math.random() * range );
					pn2 = v2.getLerp( v3, minRatio + Math.random() * range );
					result.push( new Triangle( pn1, v1, v3 ));
					result.push( new Triangle( pn1, pn2, v3 ));
					result.push( new Triangle( pn1, pn2, v2 ));
				break;
				case 4:
					pn1 = v1.getLerp( v2, minRatio + Math.random() * range );
					pn2 = v1.getLerp( v3, minRatio + Math.random() * range );
					pn3 = v2.getLerp( v3, minRatio + Math.random() * range );
					result.push( new Triangle( pn1, pn2, pn3 ));
					result.push( new Triangle( pn1, pn2, v1 ));
					result.push( new Triangle( pn1, pn3, v2 ));
					result.push( new Triangle( pn2, pn3, v3 ));
				break;
			}
			return result;
		}
		
		public function getOffsetTriangle( offset:Number, onlyInnerTriangles:Boolean = false ):Triangle
		{
			if ( offset==0) return Triangle(clone());
			
			var s1:LineSegment = getSide( 0 );
			var s2:LineSegment = getSide( 1 );
			var s3:LineSegment = getSide( 2 );
			
			
			if ( offset < 0 && onlyInnerTriangles )
			{
				var o:Vector2 = incircleCenter;
				if ( s1.distanceToPoint(o) < -offset || s2.distanceToPoint(o) < -offset || s3.distanceToPoint(o) < -offset ) return null;
			}
			
			var l1:LineSegment = s1.getParallel( offset );
			l1.multiply( 200 );
		    var t:Intersection = l1.intersect( s2 );
			if ( ( offset < 0 && t.status == Intersection.NO_INTERSECTION) || ( offset > 0 && t.status == Intersection.INTERSECTION)  )
			{
				l1 = s1.getParallel( -offset );
			}
			
			var l2:LineSegment = s2.getParallel( -offset );
			l2.multiply( 200 );
			t = l2.intersect( s1 );
			if ( ( offset < 0 && t.status == Intersection.NO_INTERSECTION) || ( offset > 0 && t.status == Intersection.INTERSECTION)  )
			{
				l2 = s2.getParallel( offset );
			}
			
			var l3:LineSegment = s3.getParallel( offset );
			l3.multiply( 200 );
			t = l3.intersect( s1 );
			if ( ( offset < 0 && t.status == Intersection.NO_INTERSECTION) || ( offset > 0 && t.status == Intersection.INTERSECTION)  )
			{
				l3 = s3.getParallel( -offset );
			}
			
			var i1:Vector2 = l1.getIntersection( l2 )[0];
			var i2:Vector2 = l1.getIntersection( l3 )[0];
			var i3:Vector2 = l2.getIntersection( l3 )[0];
			
			
			
			
			return new Triangle( i1, i2, i3 );
			
		}
		
		public function getSmoothPath( factor:Number, perEdge:Boolean = false, absolute:Boolean = false ):MixedPath
		{
			var s1:LineSegment = getSide( 0 );
			var s2:LineSegment = getSide( 1 );
			var s3:LineSegment = getSide( 2 );
			
			var s1l:Number = s1.length;
			var s2l:Number = s2.length;
			var s3l:Number = s3.length;
			
			var mp:MixedPath = new MixedPath();
			mp.setClosed( true );
			
			if ( s1l == 0 || s2l == 0 || s3l == 0 ) {
				
				mp.addPoint( p1 );
				mp.addPoint( p2 );
				mp.addPoint( p3 );
				return mp;
			}
			
			if ( !perEdge ) var l:Number = ( absolute ? Math.min( 2 * factor, s1l, s2l, s3l ) * 0.5 : Math.min( s1l, s2l, s3l ) * 0.5 * factor );
			
			if ( perEdge ) l = absolute ? Math.min( factor, s1l * 0.5 ) : s1l * 0.5 * factor;
			
			
			
			var p1:Vector2 = s1.getPoint( l / s1l );
			var p2:Vector2 = s1.getPoint( 1- ( l / s1l ) );
			
			if ( perEdge ) l = absolute ? Math.min( factor, s3l * 0.5 ) : s3l * 0.5 * factor;
			var p3:Vector2 = s3.getPoint( l / s3l );
			var p4:Vector2 = s3.getPoint( 1- ( l / s3l ) );
			
			if ( perEdge ) l = absolute ? Math.min( factor, s2l * 0.5 ) : s2l * 0.5 * factor;
			var p5:Vector2 = s2.getPoint( 1- ( l / s2l ) );
			var p6:Vector2 = s2.getPoint( l / s2l );
			
			
			mp.addPoint(p1);
			mp.addPoint(p2);
			mp.addControlPoint( s1.p2.getClone() );
			mp.addPoint(p3);
			mp.addPoint(p4);
			mp.addControlPoint( s2.p2.getClone() );
			mp.addPoint(p5);
			mp.addPoint(p6);
			mp.addControlPoint( s1.p1.getClone(),null,true );
			return mp;
		}
		
		public function get centerOfMass():Vector2
		{
			return p1.getPlus( p2 ).plus( p3 ).divide( 3 );
		}
		
		public function get orthocenter():Vector2
		{
			var s1:LineSegment = getSide(0);
			var a1:Vector2 = s1.getClosestPoint( p3 );
			
			var s2:LineSegment = getSide(1);
			var a2:Vector2 = s2.getClosestPoint( p2 );
			
			var l1:LineSegment = new LineSegment( a1, p3 );
			var l2:LineSegment = new LineSegment( a2, p2 );
			
			return l1.getIntersection(l2)[0];
		}
		
		public function get incircleCenter():Vector2
		{
			return getIncircleCenter( p1, p2, p3 ); 
		}
		
		private function getIncircleCenter( p1:Vector2, p2:Vector2, p3:Vector2 ):Vector2
		{
			var a:Number = p2.distanceToVector( p3 );
			var b:Number = p1.distanceToVector( p3 );
			var c:Number = p2.distanceToVector( p1 );
			
			var sum:Number = a + b + c;
			
			return new Vector2( ( a * p1.x + b * p2.x + c * p3.x ) / sum, ( a * p1.y + b * p2.y + c * p3.y ) / sum );
		}
		
		private function getTouchPoint( p1:Vector2, p2:Vector2, p3:Vector2 ):Vector2
		{
			var l:Number = p2.distanceToVector( p3 );
			var u:Number = ( ( p1.x - p2.x ) * ( p3.x - p2.x ) + ( p1.y - p2.y ) * ( p3.y - p2.y ) ) / ( l * l );
			return new Vector2( p2.x + u * ( p3.x - p2.x ), p2.y + u * ( p3.y - p2.y ));
		}
		
		private function getIntersectionPoint( p1:Vector2, p2:Vector2, p3:Vector2, p4:Vector2 ):Vector2
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
			
			return new Vector2( x1 + ua * ( x2 - x1 ), y1 + ua * ( y2 - y1 ) );
		}
		
		private function getIncircleRadius( p1:Vector2, p2:Vector2, p3:Vector2, p4:Vector2 ):Number
		{
			var a:Number = p1.distanceToVector( p2 );
			var b:Number = p2.distanceToVector( p3 );
			var c:Number = p3.distanceToVector( p4 );
			var d:Number = p4.distanceToVector( p1 );
			
			var p:Number = p1.distanceToVector( p3 );
			var q:Number = p2.distanceToVector( p4 );
			
			var t:Number = a*a - b*b + c*c - d*d;
			return Math.sqrt( ( 4 * p*p * q*q - t*t ) ) / ( 2 * ( a + b + c + d ) ) ;
		}
		
		public function getEquilateralTriangles( clonePoints:Boolean = false ):Vector.<Triangle>
		{
			var result:Vector.<Triangle> = new Vector.<Triangle>();
			var c:Vector2 = centerOfMass;
			for ( var i:int = 0; i<3; i++ )
			{
				var side:LineSegment = getSide( i );
				var c1:Circle = new Circle(side.p1, side.length );
				var c2:Circle = new Circle(side.p2, side.length );
				var intersection:Intersection = c1.intersect(c2);
				var d1:Number = c.distanceToVector( intersection.points[0] );
				var d2:Number = c.distanceToVector( intersection.points[1] );
				result.push( new Triangle( clonePoints ? side.p1.getClone() : side.p1, clonePoints ? side.p2.getClone() : side.p2, intersection.points[d1 < d2 ? 1 : 0]));	
			}
			return result;
		}
		
		public function getTouchingCornerCircles():Vector.<Circle>
		{
			var a:Number = getSideLength(0);
			var b:Number = getSideLength(1);
			var c:Number = getSideLength(2);
			var result:Vector.<Circle> = new Vector.<Circle>();
			result.push( new Circle( p1.getClone(), 0.5 * ( b - c + a )) );
			result.push( new Circle( p2.getClone(), 0.5 * ( c - b + a )) );
			result.push( new Circle( p3.getClone(), 0.5 * ( b - a + c )) );
			return result;
		}
		
		public function getTouchingCornerCircleTriangle():Triangle
		{
			var a:Number = getSideLength(0);
			var b:Number = getSideLength(1);
			var c:Number = getSideLength(2);
			
			var r1:Number = 0.5 * ( b - c + a );
			var r2:Number = 0.5 * ( c - b + a );
			var r3:Number = 0.5 * ( b - a + c );
			
			return new Triangle( getSide(2).getPoint( r2 / ( r2 + r3 )), getSide(1).getPoint( r1 / ( r3 + r1 )), getSide(0).getPoint( r1 / ( r1 + r2 ))  );
		}
		
		// Soddy circle method by Ryan Phelan: http://www.rphelan.com/
		// found here: http://www.bit-101.com/blog/?p=1251
		public function getTouchingCornerCircleIncircle():Circle
		{
			var circles:Vector.<Circle> = getTouchingCornerCircles();
			
			var x1:Number = circles[0].c.x;
			var x2:Number = circles[1].c.x;
			var x3:Number = circles[2].c.x;
			var y1:Number = circles[0].c.y;
			var y2:Number = circles[1].c.y;
			var y3:Number = circles[2].c.y;
			
			var a:Number = getSideLength(0);
			var b:Number = getSideLength(1);
			var c:Number = getSideLength(2);
			
			var R1:Number = 0.5 * ( b - c + a );
			var R2:Number = 0.5 * ( c - b + a );
			var R3:Number = 0.5 * ( b - a + c );
			
			var ax:Number = 2 * (x2 - x1);
			var Ay:Number = 2 * (y2 - y1);
			var Ar:Number = 2 * (R2 - R1);
			var bx:Number = 2 * (x3 - x2);
			var By:Number = 2 * (y3 - y2);
			var Br:Number = 2 * (R3 - R2);		
			var cx:Number = 2 * (x1 - x3);
			var Cy:Number = 2 * (y1 - y3);
			var Cr:Number = 2 * (R1 - R3);		
			
			var Aa:Number = x2*x2 - x1*x1 + y2*y2 - y1*y1 + R1*R1 - R2*R2;		
			var Bb:Number = x3*x3 - x2*x2 + y3*y3 - y2*y2 + R2*R2 - R3*R3;		
			var Cc:Number = x1*x1 - x3*x3 + y1*y1 - y3*y3 + R3*R3 - R1*R1;
			
			var DAB:Number = ax * By - Ay * bx;
			var DAC:Number = ax * Cy - Ay * cx;
			var DBC:Number = bx * Cy - By * cx;
			
			var DET:Number;
			var radius:Number;
			var xPos:Number;
			var yPos:Number;
			
			if( Ar == 0 && Br == 0 )
			{
				DET = ax * By - bx * Ay;
				xPos = (Aa * By - Bb * Ay ) / DET;
				yPos = (ax * Bb - Ay * Aa ) / DET;
				var p:Number = 1;
				var q:Number = 2 * R1;
				var r:Number = R1*R1 - x1*x1 - y1*y1;
				var d:Number = q*q - 4 * p * r;
				radius = (-q + Math.sqrt(d)) / 2;
			}
			
			if( DAB != 0 )
			{
				var xr:Number = (Br * Ay - Ar * By) / DAB;
				var yr:Number = (Ar * bx - Br * ax) / DAB;
				var xc:Number = (Aa * By - Bb * Ay) / DAB;
				var yc:Number = (Bb * ax - Aa * bx) / DAB;
				
				var Zp:Number = xr*xr + yr*yr - 1;
				var zq:Number = 2 * xc * xr - 2 * xr * x3 + 2 * yc * yr - 2 * yr * y3 - 2 * R3;
				var zr:Number = xc*xc - 2 * xc * x3 + x3*x3 + yc*yc - 2 * yc * y3 + y3*y3 - R3*R3;
				
				DET = zq*zq - 4 * Zp * zr;
				radius = (-zq - Math.sqrt(DET)) / 2 / Zp;
				
				xPos = xr * radius + xc;
				yPos = yr * radius + yc;
			}
			if (!isNaN(xPos) && !isNaN(yPos)  && !isNaN(radius) )
				return new Circle( xPos,yPos,radius );
			
			return null;
		}
		
		
		
		public function getBoundingCircle():Circle
		{
			return Circle.from3Points( p1,p2,p3);
		}
		
		public function get circumcenter():Vector2
		{
			return Circle.from3Points( p1,p2,p3).c;
		}
		
		public function get equicenter():Vector2
		{
			
			if ( getBiggestAngle() < Math.PI * 2 / 3 )
			{
				var equiTriangles:Vector.<Triangle> = getEquilateralTriangles();
				var intersection:Intersection = equiTriangles[0].getBoundingCircle().intersect(equiTriangles[1].getBoundingCircle());	
				if ( intersection.points.length == 0 )
				{
					intersection = equiTriangles[1].getBoundingCircle().intersect(equiTriangles[2].getBoundingCircle());	
				}
				if ( intersection.points.length == 0 )
				{
					intersection = equiTriangles[0].getBoundingCircle().intersect(equiTriangles[2].getBoundingCircle());	
				}
				return intersection.points[ p1.snaps(intersection.points[0]) ? 1 : 0 ]; 
			} else {
				return getBiggestAnglePoint();
			}
		}
		
		public function getAngles():Vector.<Number>
		{
			var result:Vector.<Number> = new Vector.<Number>();
			var a1:Number = p1.cornerAngle( p2, p3 );
			result.push(a1);
			var a2:Number = p2.cornerAngle( p3, p1 );
			result.push(a2);
			result.push(Math.PI - a1 - a2);
			return result;
		}
		
		public function getBiggestAngle():Number
		{
			var angles:Vector.<Number> =  getAngles().sort( Array.DESCENDING );
			return angles[0];
		}
		
		public function getBiggestAnglePoint():Vector2
		{
			var angles:Vector.<Number> =  getAngles();
			var corner:Vector2 = p1;
			var angle:Number = angles[0];
			if ( angle < angles[1] )
			{
				corner = p2;
				angle = angles[1];
			}
			if ( angle < angles[2] )
			{
				corner = p3;
				angle = angles[2];
			}
			
			return corner;
		}
		
		public function getSmallestAngle():Number
		{
			var angles:Vector.<Number> =  getAngles().sort( Array.NUMERIC );
			return angles[0];
		}
		
		public function getSmallestAnglePoint():Vector2
		{
			var angles:Vector.<Number> =  getAngles();
			var corner:Vector2 = p1;
			var angle:Number = angles[0];
			if ( angle > angles[1] )
			{
				corner = p2;
				angle = angles[1];
			}
			if ( angle > angles[2] )
			{
				corner = p3;
				angle = angles[2];
			}
			
			return corner;
		}
		
		override public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = centerOfMass;
			p1.rotateAround(angle, center );
			p2.rotateAround(angle, center );
			p3.rotateAround(angle, center );
			return this;
		}
		
		override public function clone( deepClone:Boolean = true ):GeometricShape
		{
			if ( deepClone )
				return new Triangle( p1.getClone(), p2.getClone(), p3.getClone() );
			else
				return new Triangle( p1, p2, p3 );
		}
		
		public function toPolygon():Polygon
		{
			var poly:Polygon = new Polygon();
			poly.addPoint(p1);
			poly.addPoint(p2);
			poly.addPoint(p3);
			return poly;
		}
		
		
		public function toString( ): String
		{
			return p1+" - "+p2+" - "+p3;
		}
		
		
	}
}