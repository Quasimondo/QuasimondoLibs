package com.quasimondo.geom
{

	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	
	public class Ellipse extends GeometricShape implements IIntersectable
	{
		public var c:Vector2;
		public var rx:Number;
		public var ry:Number;
		public var rx2:Number;
		public var ry2:Number;
		
		static private var rad:Number = Math.PI / 180;
		static private var iMaxIteration:Number = 64;
		static private const EPSILON:Number = 1e-4;
		static private const PI2:Number = 2*Math.PI;
		
		private var drawingSegments:int = 6;
		private var startAngle:Number = 0;
		private var endAngle:Number = 0;
		
		public function Ellipse( value1:* = null, value2:* = null, value3:* = null ) 
		{
			
			if (value1 is Rectangle) {
				var r:Rectangle = Rectangle( value1 );
				rx = r.width * 0.5;
				ry =  r.height * 0.5;
				c = new Vector2( r.x + rx, r.y + ry);
				update();
			} else if (value1 is Vector2 && value2 is Number && value3 is Number ) {
				c = value1;
				rx = value2;
				ry = value3;
				update();
			} else {
				throw( new Error("Ellipse: Wrong arguments"))
			}
		}
		
		override public function get type():String
		{
			return "Ellipse";
		}
	
		private function update():void
		{
			rx2 = rx*rx;
			ry2 = ry*ry;
		};
		
		
		public function setDrawingOpions(  sgm:int = 6, s1:Number = 0, s2:Number = 0 ):void
		{
			drawingSegments = sgm;
			startAngle = s1;
			endAngle = s2;
		}
		
		//
		override public function draw( canvas:Graphics ):void 
		{
			var x1:Number, y1:Number, grad:Number, segm:Number;
			var s1:Number = startAngle;
			var s2:Number = endAngle;
			var sgm:Number = drawingSegments;
			
			if (s1 == s2) {
				grad = 360;
				segm = grad/sgm;
				x1 = rx+c.x;
				y1 = c.y;
				canvas.moveTo(x1, y1);
			} else {
				s1>s2 ? s1 -= 360 : "";
				x1 = rx*Math.cos(s1*rad)+c.x;
				y1 = ry*Math.sin(s1*rad)+c.y;
				grad = s2-s1;
				segm = grad/sgm;
				canvas.moveTo(c.x, c.y);
				canvas.lineTo(x1, y1);
			}
			for (var s:Number = segm+s1; s<grad+.1+s1; s += segm) {
				var x2:Number = rx*Math.cos((s-segm/2)*rad)+c.x;
				var y2:Number = ry*Math.sin((s-segm/2)*rad)+c.y;
				var x3:Number = rx*Math.cos(s*rad)+c.x;
				var y3:Number = ry*Math.sin(s*rad)+c.y;
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
	
		override public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			var v:Vector2 = c.getMinus( p );
			v.y *= rx/ry;
			return (includeVertices ? v.length <= rx : v.length < rx);
		};
		
		//
		override public function getClosestPoint( point:Vector2):Vector2 
		{
			return c.getPlus(calculateClosestPoint(point));
		};
		
		//
		private function calculateClosestPoint( point:Vector2 ):Vector2
		{
			var pt:Vector2 = c.getMinus( point );
			var rkClosest:Vector2 = new Vector2();
			
			var b:Number = ry;
			var b2:Number = ry2;
			
			var a2u2:Number = rx2*pt.x*pt.x;
			var b2v2:Number = ry2*pt.y*pt.y;
			var t:Number;
			
			var dx:Number, dy:Number, fXDivA:Number, fYDivB:Number, p:Number, q:Number, p2:Number, q2:Number, r:Number, dr:Number;
			// handle points near the coordinate axes
			var fThreshold:Number = 1e-12;
			if (Math.abs(pt.x)<=fThreshold) {
				if (rx>=ry || Math.abs(pt.y)>=ry-rx2/ry) {
					rkClosest.x = 0;
					rkClosest.y = (pt.y>=0 ? ry : -ry);
					return rkClosest;
				} else {
					rkClosest.y = ry2*pt.y/(ry2-rx2);
					fYDivB = rkClosest.y/ry;
					rkClosest.x = rx * Math.sqrt(Math.abs(1-fYDivB*fYDivB));
					return rkClosest;
				}
			}
			if (Math.abs(pt.y)<=fThreshold) {
				if (ry>=rx || Math.abs(pt.x)>=rx-ry2/rx) {
					rkClosest.x = (pt.x>=0 ? rx : -rx);
					rkClosest.y = 0;
					return rkClosest;
				} else {
					rkClosest.x = rx2*pt.x/(rx2-ry2);
					fXDivA = rkClosest.x/rx;
					rkClosest.y = ry*Math.sqrt(Math.abs(1-fXDivA*fXDivA));
					return rkClosest;
				}
			}
			// initial guess
			var fURatio:Number = pt.x/rx;
			var fVRatio:Number = pt.y/ry;
			if (fURatio*fURatio+fVRatio*fVRatio<1) {
				t = 0;
			} else {
				var fMax:Number = Math.max(rx, ry);
				t = fMax * pt.length;
			}
			// Newton's method
			
			for (var i:int = 0; i<iMaxIteration; i++) {
				p = t+rx2;
				q = t+ry2;
				p2 = p*p;
				q2 = q*q;
				r = p2*q2-a2u2*q2-b2v2*p2;
				if (Math.abs(r)<EPSILON) {
					break;
				}
				dr = 2*(p*q*(p+q)-a2u2*q-b2v2*p);
				t -= r/dr;
			}
			rkClosest.x = rx2*pt.x/p;
			rkClosest.y = ry2*pt.y/q;
			return rkClosest;
		};
		
		//
		public function distanceToPoint( point:Vector2 ):Number {
			return calculateClosestPoint(point).distanceToVector(point);
		};
		
		public function intersectHullToLine( d:Number, l:LineSegment ):Intersection {
			var r:Number;
			var dr:Number;
			
			var cos_t:Number;
			var sin_t:Number;
			
			var c2:Number;
			var s2:Number;
			var cssq:Number;
			var sq:Number;
			
			var result:Intersection = new Intersection();
			
			var x1:Number = l.p1.x;
			var y1:Number = l.p1.y;
			
			var dx:Number = l.p2.x-x1;
			var dy:Number = l.p2.y-y1;
			
			var rx2:Number = rx2;
			var ry2:Number = ry2;
			
			var c1:Number = dx*y1 - dy*x1 + dy * c.x - dx * c.y;
			
			var dyry:Number = d*dy*ry;
			var dxrx:Number = d*dx*rx;
			var dyrx:Number = dy*rx;
			var dxry:Number = dx*ry;
			
			var t:Number = 0;
			var tFound:Number = NaN;
			var tAdd:Number = Math.PI/2;
			var found:Number = 0;
			var rounds:Number = 0;
			var v1:Number, v2:Number, n:Number;
			
			for (var i:Number = 0; i<iMaxIteration; i++) {
				cos_t = Math.cos(t);
				sin_t = Math.sin(t);
				c2 = cos_t*cos_t;
				s2 = sin_t*sin_t;
				cssq = c2 * ry2 + s2 * rx2;
				sq = Math.sqrt(cssq);
				r = c1+dyrx*cos_t-dxry*sin_t+(dyry*cos_t-dxrx*sin_t)/sq;
				if (Math.abs(r)<EPSILON) 
				{
					if ( isNaN(tFound)) 
					{
						tFound = (t%PI2+PI2)%(PI2);
						v1 = cos_t*ry;
						v2 = sin_t*rx;
						n = d/Math.sqrt(v1*v1+v2*v2);
						result.appendPoint(new Vector2(c.x+cos_t*rx+n*v1, c.y+sin_t*ry+n*v2));
					} else {
						if (Math.abs(tFound-(t%PI2+PI2)%PI2)>EPSILON) {
						//	result.appendPoint(new Vector2(c.x+c*rx, c.y+s*ry));
							v1 = cos_t*ry;
							v2 = sin_t*rx;
							n = d / Math.sqrt(v1*v1+v2*v2);
							result.appendPoint(new Vector2(c.x+cos_t*rx+n*v1, c.y+sin_t*ry+n*v2));
							break;
						}
					}
					i = 0;
					t += (t<0 ? -1 : 1)*tAdd;
					tAdd += Math.PI/2;
					rounds++;
					if (rounds == 5) {
						break;
					}
				}
				dr = -dxry*cos_t-dyrx*sin_t+(-(dxrx*cos_t+dyry*sin_t)*sq-((rx2-ry2)*cos_t*sin_t)/sq*(dyry*cos_t-dxrx*sin_t))/cssq;
				t -= r/dr;
			}
			return result;
		};
		
	}
}