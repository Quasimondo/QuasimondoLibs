package com.quasimondo.geom
{
	import com.quasimondo.utils.MathUtils;
	
	import flash.display.Graphics;
	
	public class Circle extends GeometricShape implements IIntersectable
	{
		public static const HATCHING_MODE_SAWTOOTH:String = "SAWTOOTH";
		public static const HATCHING_MODE_ZIGZAG:String = "ZIGZAG";
		public static const HATCHING_MODE_CRISSCROSS:String = "CRISSCROSS";
		
		public var c:Vector2;
		public var r:Number;
		
		static private const rad:Number = Math.PI / 180;
		
		private var drawingSegments:int = 6 ;
		private var startAngle:Number = 0;
		private var endAngle:Number = 0;
		
		static public function from3Points( p0:Vector2, p1:Vector2, p2:Vector2 ):Circle
		{
			var m:Vector.<Number> = new Vector.<Number>;
				
			m[0] = 1;
			m[1] = -2 * p0.x;
			m[2] = -2 * p0.y;
			m[3] = - p0.x * p0.x - p0.y * p0.y;
			
			m[4] = 1;
			m[5] = -2 * p1.x;
			m[6] = -2 * p1.y;
			m[7] = - p1.x * p1.x - p1.y * p1.y;
			
			m[8] = 1;
			m[9] = -2 * p2.x;
			m[10] = -2 * p2.y;
			m[11] = - p2.x * p2.x - p2.y * p2.y;
			
			MathUtils.GLSL( m );
			
			return new Circle(m[7],m[ 11 ],  Math.sqrt( m[7] * m[7] + m[11] * m[11] - m[3]) );
			
		}
		
		public function Circle( value1:* = null, value2:* = null, value3:* = null ) {
			
			if ( value1 is Circle )
			{
				c = new Vector2( Circle( value1.c ) );
				r =  Circle( value1 ).r;
			} else if ( value1 is Vector2)
			{
				c = Vector2( value1 ).getClone();
				r = Number( value2 );
			} else {
				c = new Vector2( Number(value1),Number(value2));
				r = Number(value3);
			}
		}
		
		override public function get type():String
		{
			return "Circle";
		}
	
		//
		override public function isInside ( point:Vector2, includeVertices:Boolean = true ):Boolean
		{
			return includeVertices ? point.squaredDistanceToVector(c)<= r*r : point.squaredDistanceToVector(c)< r*r;
		}
		
		public function lineIsInside ( line:LineSegment ):Boolean
		{
			return (line.p1.squaredDistanceToVector(c)<r*r) && (line.p2.squaredDistanceToVector(c)<r*r);
		}
		
		public function circleIsInside ( circle:Circle ):Boolean
		{
			if (circle.r <= r ) return false;
			return circle.c.squaredDistanceToVector(c)<(circle.r-r)*(circle.r-r);
		}
		
		public function circleIsInsideOrIntersects ( circle:Circle ):Boolean
		{
			return circle.c.squaredDistanceToVector(c)<(circle.r+r)*(circle.r+r);
		}
	
		public function isIdentical( c2:Circle ):Boolean
		{
			return ( r==c2.r && c.x == c2.c.x && c.y == c2.c.y);
		}
		
		override public function translate( p:Vector2 ):GeometricShape
		{
			c.plus( p );
			return this;
		}
		
		public function snaps( c2:Circle ):Boolean
		{
			return ( Math.abs(r-c2.r) < SNAP_DISTANCE && Math.abs(c.x-c2.c.x) < SNAP_DISTANCE  && Math.abs(c.y -c2.c.y) < SNAP_DISTANCE  );
		}
		
		public function setDrawingOpions(  sgm:int = 6, s1:Number = 0, s2:Number = 0 ):void
		{
			drawingSegments = sgm;
			startAngle = s1;
			endAngle = s2;
		}
		
		public function toVector( maxSegmentLength:Number):Vector.<Vector2>
		{
			var segments:int = Math.ceil( circumference / maxSegmentLength );
			var result:Vector.<Vector2> = new Vector.<Vector2>();
			var step:Number = 2 * Math.PI / segments;
			for ( var i:int = 0; i < segments; i++ )
			{
				result.push( new Vector2( c.x + r * Math.cos(i*step), c.y + r * Math.sin(i*step)));
			}
			return result;
		}
		
		public function toPolygon( maxSegmentLength:Number):Polygon
		{
			var polygon:Polygon = new Polygon();
			var segments:int = Math.ceil( circumference / maxSegmentLength );
			var step:Number = 2 * Math.PI / segments;
			for ( var i:int = 0; i < segments; i++ )
			{
				polygon.addPoint( new Vector2( c.x + r * Math.cos(i*step), c.y + r * Math.sin(i*step)));
			}
			return polygon;
		}
		
		public function toConvexPolygon( maxSegmentLength:Number):ConvexPolygon
		{
			var polygon:ConvexPolygon = new ConvexPolygon();
			var segments:int = Math.ceil( circumference / maxSegmentLength );
			var step:Number = 2 * Math.PI / segments;
			for ( var i:int = 0; i < segments; i++ )
			{
				polygon.addPoint( new Vector2( c.x + r * Math.cos(i*step), c.y + r * Math.sin(i*step)));
			}
			return polygon;
		}
		
		
		// based on java code by Paul Hertz
		// http://ignotus.com/factory/wp-content/uploads/2010/03/bezcircle_applet/index.html
		public function toMixedPath( cubicBezierCount:int = 4 ):MixedPath
		{
			/** 
			 * kappa = distance between Bezier anchor and its associated control point divided by circle radius 
			 * when circle is divided into 4 sectors 0f 90 degrees
			 * see http://www.whizkidtech.redprince.net/bezier/circle/kappa/, notes by G. Adam Stanislav
			 */
			var kappa:Number = 0.5522847498;

			var k:Number = 4 * kappa / cubicBezierCount;
			var d:Number = k * r;
			var secPi:Number = Math.PI*2/cubicBezierCount;
			
			var a1:Vector2 = new Vector2(0,r);
			var c1:Vector2 = new Vector2(d,r);
			var a2:Vector2 = new Vector2(0,r);
			var c2:Vector2 = new Vector2(-d,r);
			
			a2.rotateBy(-secPi);
			c2.rotateBy(-secPi);
			
			var path:MixedPath = new MixedPath();
			path.addPoint( a1.getPlus(c) );
			path.addControlPoint( c1.getPlus(c) );
			path.addControlPoint( c2.getPlus(c) );
			path.addPoint( a2.getPlus(c) );
			
			for (var i:int = 1; i < cubicBezierCount; i++) 
			{
				a2.rotateBy(-secPi);
				c2.rotateBy(-secPi);
				c1.rotateBy(-secPi);
				path.addControlPoint( c1.getPlus(c) );
				path.addControlPoint( c2.getPlus(c) );
				path.addPoint( a2.getPlus(c) );
			}
			path.deletePointAt(path.pointCount-1);
			path.setClosed( true );
			
			return path;
		}
		

		public function get circumference():Number
		{
			return 2 * r * Math.PI;
		}
		
		public function get area():Number
		{
			return r * r * Math.PI;
		}
		
		override public function export( canvas:IGraphics ):void 
		{
			var x1:Number, y1:Number, grad:Number, segm:Number;
			
			var s1:Number = startAngle;
			var s2:Number = endAngle;
			var sgm:Number = drawingSegments;
			
			if (s1 == s2) 
			{
				canvas.moveTo(c.x, c.y);
				canvas.drawCircle( c.x, c.y, r );
				return;
			} else {
				s1>s2 ? s1 -= 360 : "";
				x1 = r*Math.cos(s1*rad)+c.x;
				y1 = r*Math.sin(s1*rad)+c.y;
				grad = s2-s1;
				segm = grad/sgm;
				canvas.moveTo(c.x, c.y);
				canvas.lineTo(x1, y1);
			}
			
			for (var s:Number = segm+s1; s<grad+.1+s1; s += segm) {
				var x2:Number = r*Math.cos((s-segm/2)*rad)+c.x;
				var y2:Number = r*Math.sin((s-segm/2)*rad)+c.y;
				var x3:Number = r*Math.cos(s*rad)+c.x;
				var y3:Number = r*Math.sin(s*rad)+c.y;
				// begin tnx 2 Robert Penner
				var cx:Number = 2*x2-.5*(x1+x3);
				var cy:Number = 2*y2-.5*(y1+y3);
				canvas.curveTo(cx, cy, x3, y3);
				// end tnx 2 Robert Penner :)
				x1 = x3;
				y1 = y3;
			}
			if (grad != 360) {
				canvas.lineTo(c.x, c.y);
			}
		}
		//
		override public function draw( canvas:Graphics ):void 
		{
			var x1:Number, y1:Number, grad:Number, segm:Number;
			
			var s1:Number = startAngle;
			var s2:Number = endAngle;
			var sgm:Number = drawingSegments;
			
			if (s1 == s2) 
			{
				canvas.moveTo(c.x, c.y);
				canvas.drawCircle( c.x, c.y, r );
				return;
			} else {
				s1>s2 ? s1 -= 360 : "";
				x1 = r*Math.cos(s1*rad)+c.x;
				y1 = r*Math.sin(s1*rad)+c.y;
				grad = s2-s1;
				segm = grad/sgm;
				canvas.moveTo(c.x, c.y);
				canvas.lineTo(x1, y1);
			}
			
			for (var s:Number = segm+s1; s<grad+.1+s1; s += segm) {
				var x2:Number = r*Math.cos((s-segm/2)*rad)+c.x;
				var y2:Number = r*Math.sin((s-segm/2)*rad)+c.y;
				var x3:Number = r*Math.cos(s*rad)+c.x;
				var y3:Number = r*Math.sin(s*rad)+c.y;
				// begin tnx 2 Robert Penner
				var cx:Number = 2*x2-.5*(x1+x3);
				var cy:Number = 2*y2-.5*(y1+y3);
				canvas.curveTo(cx, cy, x3, y3);
				// end tnx 2 Robert Penner :)
				x1 = x3;
				y1 = y3;
			}
			if (grad != 360) {
				canvas.lineTo(c.x, c.y);
			}
		};
		
		override public function drawExtras( canvas:Graphics, factor:Number = 1 ):void 
		{
			c.draw( canvas, factor );
		}
		
		public function drawHatching( distance:Number, angle:Number, offsetFactor:Number, canvas:Graphics ):void
		{
			if ( distance == 0 ) return;
			
			angle %= Math.PI;
			offsetFactor %= 1;
			
			var lineLength:Number = 3 * r;
			
			var line:LineSegment = LineSegment.fromPointAndAngleAndLength( c.getClone(), angle,lineLength,true);
			var normalOffset:Vector2 = line.getNormalAtPoint( c );
			
			normalOffset.newLength( -r - distance * offsetFactor );
			line.translate( normalOffset );
			normalOffset.newLength(-distance);
			
			var maxIterations:int = 2 + (2*r)/ distance;
			while ( maxIterations-- > -1)
			{
				var pts:Intersection = this.intersect( line );
				if ( pts.points.length == 2) 
				{
					canvas.moveTo( 	pts.points[0].x,pts.points[0].y);
					canvas.lineTo( 	pts.points[1].x,pts.points[1].y);
				}
				line.translate( normalOffset );
			}
		}
		
		public function getHatchingPath( distance:Number, angle:Number, offsetFactor:Number, mode:String = HATCHING_MODE_ZIGZAG ):LinearPath
		{
			if ( distance == 0 ) return null;
			distance = Math.abs( distance );
			angle %= Math.PI;
			offsetFactor %= 2;
			
			var lineLength:Number = 3 * r;
			
			var line:LineSegment = LineSegment.fromPointAndAngleAndLength( c.getClone(), angle,lineLength,true);
			var normalOffset:Vector2 = line.getNormalAtPoint( c );
			
			
			var startLength:Number =  - (r - r % distance) - distance * offsetFactor;
			
			normalOffset.newLength( startLength );
			line.translate( normalOffset );
			normalOffset.newLength(-distance);
			
			
			var pts:Intersection;
			var path:LinearPath = new LinearPath();
			var zigzag:int = 0;
			var startLeft:Boolean = ( Math.abs(r) % (distance * 4 ) < distance * 2 );
			
			var maxIterations:int = 2 + (2*r)/ distance;
			
			while ( maxIterations-- > -1)
			{
				pts = this.intersect( line );
				if ( pts.points.length == 2) 
				{
					var middle:Vector2 = pts.points[0].getLerp( pts.points[1], 0.5 );
					if ( (pts.points[0].isLeft(middle,middle.getPlus(normalOffset)) < 0) == startLeft )
					{
						var tmp:Vector2 = pts.points[0];
						pts.points[0] = pts.points[1];
						pts.points[1] = tmp;
					}
					
					path.addPoint(pts.points[1-zigzag]);
					if ( mode != HATCHING_MODE_SAWTOOTH ) path.addPoint(pts.points[zigzag]);
					if ( mode != HATCHING_MODE_CRISSCROSS	) zigzag = 1 - zigzag;
				}
				line.translate( normalOffset );
			}
			
			return path;
		}
	
		override public function getNormalAtPoint( p:Vector2 ):Vector2
		{
			return Vector2.fromAngle(c.angleTo(p),1);
		}
	
		override public function getPoint(t:Number):Vector2
		{
			return new Vector2( c.x + r * Math.cos( 2 * Math.PI * t ),  c.y + r * Math.sin( 2 * Math.PI * t ));
		}
		
		override public function hasPoint(v:Vector2):Boolean
		{
			return false;
		}
		
		public function getTangentPolygon( circle:Circle ):Polygon
		{
			var poly:Polygon = new Polygon();
			var l:LineSegment = new LineSegment ( c, circle.c );
			poly.addPoint(l.getNormalAtPoint( l.p1 ).newLength( r ).plus( l.p1 ));
			poly.addPoint(l.getNormalAtPoint( l.p2 ).newLength( circle.r ).plus( l.p2 ));
			poly.addPoint(l.getNormalAtPoint( l.p2 ).newLength( -circle.r ).plus( l.p2 ));
			poly.addPoint(l.getNormalAtPoint( l.p1 ).newLength( -r ).plus( l.p1 ));
			return poly;
		}
		
		public function getInvertedPoint( p:Vector2 ):Vector2
		{
			var dx:Number = p.x - c.x;
			var dy:Number = p.y - c.y;
			var dxy:Number = dx * dx + dy * dy ;
			if ( dxy == 0 ) dxy = 1 / Number.MAX_VALUE;
			return c.getPlus( new Vector2( r * r * dx  / dxy, r * r * dy / dxy) );
		}
		
		public function inversionOnCircle( inversionCircle:Circle ):void
		{
			var dx:Number = c.x - inversionCircle.c.x;
			var dy:Number = c.y - inversionCircle.c.y;
			var s:Number = (inversionCircle.r * inversionCircle.r) / ( dx*dx + dy*dy - r*r );
			
			r *= Math.abs( s ); 
			c.x = inversionCircle.c.x + s * dx;
			c.y = inversionCircle.c.y + s * dy;
		}
		
		public function getInvertedCircle( circle:Circle ):Circle
		{
			var dx:Number = circle.c.x - c.x;
			var dy:Number = circle.c.y - c.y ;
			var div:Number = dx*dx + dy*dy - circle.r*circle.r;
			var s:Number = (r * r) / div;
			if ( s == Infinity ) s = Number.MAX_VALUE;
			else if ( s == -Infinity ) s = -Number.MAX_VALUE;
			
			return new Circle(c.x + s * dx, c.y + s * dy, circle.r * Math.abs( s ) );
			
		}
		
		/*
			returns up to 4 tangent line segments
			
			Code from "Geometric Tools for Computer Graphics"
			by Philip J. Schneider & David H. Eberly
		*/
		public function getTangents( circle:Circle ):Vector.<LineSegment>
		{
			var result:Vector.<LineSegment> = new Vector.<LineSegment>();
			
			if ( circle.circleIsInside( this ) || this.circleIsInside( circle ) ) return result;
			
			var w:Vector2 = circle.c.getMinus( c );
			var wLenSqr:Number = w.length_squared;
			var rSum:Number = r + circle.r;
			
			var l1p2:Vector2 = new Vector2();
			var l2p2:Vector2 = new Vector2();
			var l3p2:Vector2 = new Vector2();
			var l4p2:Vector2 = new Vector2();
			
			const epsilon:Number = 0.00001;
			var a:Number, oms:Number;
			var rDiff:Number = circle.r - r;
			if ( Math.abs(rDiff) >= epsilon )
			{
				var R0sqr:Number = r * r;
				var R1sqr:Number = circle.r * circle.r;
				var c0:Number = -R0sqr
				var c1:Number = 2 * R0sqr;
				var c2:Number = circle.r * circle.r - R0sqr;
				var invc2:Number = 1 / c2;
				var discr:Number = Math.sqrt( Math.abs(c1 * c1 - 4 * c0 * c2));
				var s:Number = -0.5 * (c1 + discr) * invc2;
			
				var l1p1:Vector2 = new Vector2(c.x + s * w.x, c.y + s * w.y);
				
				var l2p1:Vector2 = l1p1.getClone();
				
			
				if ( s >= 0.5 )
				{
					a = Math.sqrt( Math.abs(wLenSqr - R0sqr / (s * s)));
				} else {
					oms = 1 - s;
					a = Math.sqrt( Math.abs( wLenSqr - R1sqr / (oms * oms)));
				}
				getDirections ( w, a, l1p2, l2p2 );
			
				s = -0.5 * (c1 - discr) * invc2;
					
				var l3p1:Vector2 = new Vector2(c.x + s * w.x, c.y + s * w.y);
				var l4p1:Vector2 = l3p1.getClone();
				
				
				if ( s >= 0.5)
				{
					a = Math.sqrt( Math.abs(wLenSqr - R0sqr / (s * s)));
				} else {
					oms = 1 - s;
					a = Math.sqrt( Math.abs(wLenSqr - R1sqr / (oms * oms)));
				}
				
				getDirections ( w, a, l3p2, l4p2 );
			} else {
				
				var mid:Vector2 = new Vector2( 0.5 * (c.x + circle.c.x), 0.5 * (c.y + circle.c.y) );
				a =  Math.sqrt( Math.abs(wLenSqr - 4 * r * r));
				
				getDirections ( w, a, l1p2, l2p2 ) 
				l1p1 = mid.getClone();
				l2p1 = mid.getClone();
				var invwlen:Number = 1 / Math.sqrt(wLenSqr);
				w.x *= invwlen;
				w.y *= invwlen;
				
				l3p1 = new Vector2(mid.x + r * w.y, mid.y - r * w.x);
				l3p2 = w.getClone();
				l4p1 = new Vector2(mid.x - r * w.y, mid.y + r * w.x);
				l4p2 = w.getClone();
			}	
			
			var ls:LineSegment = LineSegment.fromPointAndAngleAndLength( l1p1, l1p2.angle, wLenSqr ,true );
			result.push( new LineSegment(ls.getClosestPoint( c ),ls.getClosestPoint( circle.c  )));
			
			ls = LineSegment.fromPointAndAngleAndLength(  l2p1, l2p2.angle, wLenSqr ,true );
			result.push( new LineSegment(ls.getClosestPoint( c ),ls.getClosestPoint( circle.c  )));
			
			var intersects:Boolean = ( result[0].intersect( result[1] ).points.length == 1 );
			if (this.circleIsInsideOrIntersects( circle ))
			{
				if ( intersects )
				{
					result.length = 0;
				} else {
					return result;
				}
			}
			
			ls = LineSegment.fromPointAndAngleAndLength(   l3p1, l3p2.angle, wLenSqr ,true );
			if ( intersects )
			{
				result.unshift( new LineSegment(ls.getClosestPoint( c ),ls.getClosestPoint( circle.c  )));
			} else {
				result.push( new LineSegment(ls.getClosestPoint( c ),ls.getClosestPoint( circle.c  )));
			}
			
			ls = LineSegment.fromPointAndAngleAndLength(   l4p1, l4p2.angle, wLenSqr ,true );
			if ( intersects )
			{
				result.unshift( new LineSegment(ls.getClosestPoint( c ),ls.getClosestPoint( circle.c  )));
			} else {
				result.push( new LineSegment(ls.getClosestPoint( c ),ls.getClosestPoint( circle.c  )));
			}
			
			
			return result;		
		}
		
		private function getDirections( w:Vector2, a:Number, dir0:Vector2, dir1:Vector2 ):void
		{
			var aSqr:Number = a * a;
			var wxSqr:Number = w.x * w.x;
			var wySqr:Number = w.y * w.y;
			var c2:Number = wxSqr + wySqr;
			var invc2:Number = 1 / c2;
			var c0:Number, c1:Number, invwx:Number, invwy:Number, discr:Number; 
			
			if ( Math.abs(w.x) >= Math.abs(w.y) )
			{
				c0 = aSqr - wxSqr;
				c1 = -2 * a * w.y;
				discr = Math.sqrt( Math.abs(c1 * c1 - 4 * c0 * c2));
				invwx = 1 / w.x;
				dir0.y = -0.5 * (c1 + discr) * invc2;
				dir0.x = (a - w.y * dir0.y) * invwx;
				dir1.y = -0.5 * (c1 - discr) * invc2;
				dir1.x = (a - w.y * dir1.y) * invwx;
			} else {
				c0 = aSqr - wySqr;
				c1 = -2 * a * w.x;
				discr = Math.sqrt( Math.abs(c1 * c1 - 4 * c0 * c2));
				invwy = 1 / w.y;
				dir0.x = -0.5 * (c1 + discr) * invc2;
				dir0.y = (a - w.x * dir0.x) * invwy;
				dir1.x = -0.5 * (c1 - discr) * invc2;
				dir1.y = (a - w.x * dir1.x) * invwy;
			}
		}
		
		public function getArcs( poly:Polygon, inner:Boolean = true, outer:Boolean = false ):Vector.<Arc>
		{
			var result:Vector.<Arc> = new Vector.<Arc>();
			var intersections:Intersection = this.intersect( poly );
			if ( intersections.points.length == 0 )
			{
				if ( poly.isInside(c) && poly.distanceToVector2( c ) >= r )
				{
					result.push( new Arc( c.getClone(),c.getPlusXY(r,0),c.getPlusXY(r,0)));
				}
			} else {
				
				intersections.points.sort( function ( a:Vector2, b:Vector2 ):int
				{
					var a1:Number = c.angleTo( a );
					var a2:Number = c.angleTo( b );
					if ( a1 < a2 ) return -1;
					if ( a1 > a2 ) return 1;
					return 0;
				});
				
				for ( var i:int = 0; i < intersections.points.length; i++ )
				{
					result.push( new Arc( c.getClone(), intersections.points[i].getClone(), intersections.points[(i+1) % intersections.points.length ].getClone()) );
				}
				
				for ( i = result.length; --i > -1; )
				{
					var inside:Boolean =  poly.isInside( result[i].getPoint( 0.5 ) );
					if ( !((inside && inner) || ( !inside && outer ))  )
					{
						result.splice( i,1 );	
					}
				}
			}
			return result;
		}
		
		override public function clone(deepClone:Boolean=true):GeometricShape
		{
			if ( deepClone )
				return new Circle( c.x, c.y, r );
			else 
				return new Circle( c, r );
		}
		
	}
}