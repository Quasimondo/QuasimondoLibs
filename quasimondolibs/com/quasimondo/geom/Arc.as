package com.quasimondo.geom
{
	import __AS3__.vec.Vector;
	
	import flash.display.Graphics;
	
	public class Arc extends GeometricShape
	{
		public var c:Vector2;
		
		public var p_in:Vector2;
		public var p_out:Vector2;
		
		public var r_in:Number;
		public var r_out:Number;
		
		public var angle:Number;
		
		private var angle_in:Number;
		private var angle_out:Number;
		
		static private const rad:Number = Math.PI / 180;
		
		// possible constructors:
		// arc:Arc
		// startpoint:Vector2, center:Vector2, radius out:Number, arc_angle:Number
		// startpoint:Vector2, angle_in:Number, endpoint:Vector2, angle_out:Number
		// center:Vector2, startpoint:Vector2, endpoint:Vector2
		
		public function Arc( value1:* = null, value2:* = null, value3:* = null, value4:* = null ) {
			
			if ( value1 is Arc )
			{
				c = new Vector2( Arc( value1.c ) );
				p_in =  Arc( value1 ).p_in;
				p_out =  Arc( value1 ).p_out;
				r_in =  Arc( value1 ).r_in;
				r_out =  Arc( value1 ).r_out;
				angle = Arc( value1 ).angle;
			} else if ( value1 is Vector2 && value2 is Vector2 && value3 is Number && value4 is Number )
			{
				c = Vector2( value1 );
				p_in = Vector2( value2 );
				r_out = Number( value3 );
				angle = Number( value4 );
				
				r_in = c.distanceToVector( p_in );
				angle_in = c.angleTo( p_in );
				angle_out = angle_in + angle;
				p_out = c.getAddCartesian( r_out, angle_out );
				if ( angle <= 0 ) angle += Math.PI * 2;
			} else if ( value1 is Vector2 && value2 is Number && value3 is Vector2 && value4 is Number )
			{
				angle_in = value2;
				angle_out = value4;
				
				p_in = Vector2( value1 );
				p_out = Vector2( value3 );
				
				var l1:LineSegment = new LineSegment( p_in, p_in.getAddCartesian( angle_in, 10 ));
				var l2:LineSegment = new LineSegment( p_out, p_out.getAddCartesian( angle_out, 10 ));
				
				var intersections:Vector.<Vector2> = l1.getIntersection( l2 );
				if ( intersections.length == 1 )
				{
					c = intersections[0];
					
					angle_in = p_in.angleTo( c );
					angle_out = p_out.angleTo( c );
					
					r_in = c.distanceToVector( p_in );
					r_out = c.distanceToVector( p_out );
					
					angle = angle_out - angle_in;
				
				} 
				if ( angle <= 0 ) angle += Math.PI * 2;
			} else if ( value1 is Vector2 && value2 is Number && value3 is Number && value4 is Number )
			{
				c =  Vector2( value1 );
				r_in = r_out = Number( value2 );
				angle_in = Number( value3 );
				angle_out = Number( value4 );
				
				angle = angle_out - angle_in;
				
				p_in = c.getAddCartesian( angle_in, r_in );
				p_out = c.getAddCartesian( angle_out, r_out );
				
				if ( angle <= 0 ) angle += Math.PI * 2;
				
			}  else if ( value1 is Vector2 && value2 is Vector2 && value3 is Vector2 )
			{
				c = Vector2(  value1 );
				p_in = Vector2( value2 );
				p_out = Vector2( value3 );
				r_in = c.distanceToVector( p_in );
				r_out = c.distanceToVector( p_out );
				angle_in = c.angleTo( p_in );
				angle_out = c.angleTo( p_out );
				if ( angle_out < angle_in ) angle_out += 2*Math.PI;
				angle = angle_out - angle_in;
				/*
				if ( angle < 0 ) {
					angle += Math.PI * 2;
					var tmp:Number = angle_in;
					angle_in = angle_out
					angle_out = tmp;
					tmp = r_in;
					r_in = r_out
					r_out = tmp;
					var tmp2:Vector2 = p_in;
					p_in = p_out;
					p_out = tmp2;
				} else 
					*/
				if ( angle == 0 ) angle = Math.PI * 2;
			} else {
				throw( new Error("Unknown Signature"));
			}
			
				/*
				var tmp:Number = angle_in;
				angle_in = angle_out
				angle_out = tmp;
				tmp = r_in;
				r_in = r_out
				r_out = tmp;
				var tmp2:Vector2 = p_in;
				p_in = p_out;
				p_out = tmp2;
				*/
			
		}
		
		public function flip():Arc
		{
			angle = 2 * Math.PI - angle;
			var tmp:Number = angle_in;
			angle_in = angle_out
			angle_out = tmp;
			tmp = r_in;
			r_in = r_out
			r_out = tmp;
			var tmp2:Vector2 = p_in;
			p_in = p_out;
			p_out = tmp2;
			return this;
		}
		
		override public function getPoint(t:Number):Vector2
		{
			var r:Number = r_in + ( r_out - r_in ) * t;
			var a:Number = angle_in + angle  * t;
			
			return new Vector2( c.x + r * Math.cos( a ), c.y + r * Math.sin( a ) );
		}
		
		override public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = c;
			p_in.rotateAround( angle, center );
			p_out.rotateAround( angle, center );
			c.rotateAround( angle, center );
			this.angle_in += angle;
			this.angle_out += angle;
			return this;
		}
	
		//
		override public function draw( canvas:Graphics ):void 
		{
			var r:Number = r_in;
			var a:Number = angle_in;
			canvas.moveTo(c.x + r * Math.cos(a),  c.y + r * Math.sin(a) );
			drawTo( canvas );
		};
		
		override public function export( canvas:IGraphics ):void 
		{
			var r:Number = r_in;
			var a:Number = angle_in;
			canvas.moveTo(c.x + r * Math.cos(a),  c.y + r * Math.sin(a) );
			var x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number;
			
			var segm:Number = Math.ceil( Math.abs(angle) / (Math.PI / 3 ) );
			
			var r:Number = r_in;
			var r_delta:Number = ( r_out - r_in ) / ( segm * 2 );
			
			var a:Number = angle_in;
			var a_delta:Number = angle / ( segm * 2 );
			
			x1 = c.x + r * Math.cos(a);
			y1 = c.y + r * Math.sin(a);
			
			for (var i:int = 0; i < segm; i++ ) 
			{
				r += r_delta;
				a += a_delta;
				
				x2 = c.x + r * Math.cos(a);
				y2 = c.y + r * Math.sin(a);
				
				r += r_delta;
				a += a_delta;
				
				x3 = c.x + r * Math.cos(a);
				y3 = c.y + r * Math.sin(a);
				
				canvas.curveTo( 2 * x2 - .5 * ( x1 + x3 ), 2 * y2 - .5 * ( y1 + y3 ), x3, y3);
				
				x1 = x3;
				y1 = y3;
			}
		}
		
		override public function drawExtras( canvas:Graphics, factor:Number = 1 ):void 
		{
			canvas.moveTo(p_in.x,p_in.y);
			canvas.lineTo(c.x,c.y);
			canvas.lineTo(p_out.x,p_out.y);
			
		};
		
		override public function drawTo(canvas:Graphics):void
		{
			var x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number;
			
			var segm:Number = Math.ceil( Math.abs(angle) / (Math.PI / 3 ) );
			
			var r:Number = r_in;
			var r_delta:Number = ( r_out - r_in ) / ( segm * 2 );
			
			var a:Number = angle_in;
			var a_delta:Number = angle / ( segm * 2 );
			
			x1 = c.x + r * Math.cos(a);
			y1 = c.y + r * Math.sin(a);
			
			for (var i:int = 0; i < segm; i++ ) 
			{
				r += r_delta;
				a += a_delta;
				
				x2 = c.x + r * Math.cos(a);
				y2 = c.y + r * Math.sin(a);
				
				r += r_delta;
				a += a_delta;
				
			 	x3 = c.x + r * Math.cos(a);
				y3 = c.y + r * Math.sin(a);
				
				canvas.curveTo( 2 * x2 - .5 * ( x1 + x3 ), 2 * y2 - .5 * ( y1 + y3 ), x3, y3);
				
				x1 = x3;
				y1 = y3;
			}
		}
		
		public function toMixedPathQuadratic( addFirst:Boolean = true ):MixedPath
		{
			var mp:MixedPath = new MixedPath();
			
			var x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number;
			
			var segm:Number = Math.ceil( Math.abs(angle) / (Math.PI / 3 ) );
			
			var r:Number = r_in;
			var r_delta:Number = ( r_out - r_in ) / ( segm * 2 );
			
			var a:Number = angle_in;
			var a_delta:Number = angle / ( segm * 2 );
			
			x1 = c.x + r * Math.cos(a);
			y1 = c.y + r * Math.sin(a);
			
			if ( addFirst )
			{
				mp.addPoint( new Vector2(x1,y1) );
			}
			
			for (var i:int = 0; i < segm; i++ ) 
			{
				r += r_delta;
				a += a_delta;
				
				x2 = c.x + r * Math.cos(a);
				y2 = c.y + r * Math.sin(a);
				
				r += r_delta;
				a += a_delta;
				
			 	x3 = c.x + r * Math.cos(a);
				y3 = c.y + r * Math.sin(a);
				mp.addControlPoint( new Vector2(2 * x2 - .5 * ( x1 + x3 ), 2 * y2 - .5 * ( y1 + y3 )) );
				mp.addPoint( new Vector2(x3, y3) )
				x1 = x3;
				y1 = y3;
			}
			
			return mp;
			
		}
		
		
		// based on java code by Paul Hertz
		// http://ignotus.com/factory/wp-content/uploads/2010/03/bezcircle_applet/index.html
		public function toMixedPathCubic( cubicBezierCount:int = 4 ):MixedPath
		{
			/** 
			 * kappa = distance between Bezier anchor and its associated control point divided by circle radius 
			 * when circle is divided into 4 sectors 0f 90 degrees
			 * see http://www.whizkidtech.redprince.net/bezier/circle/kappa/, notes by G. Adam Stanislav
			 */
			var fullSegments:int = angle / ( Math.PI * 2 / cubicBezierCount ) + 1;
			
			var kappa:Number = 0.5522847498;
			
			var k:Number = 4 * kappa / cubicBezierCount;
			var d:Number = k * r_in;
			var secPi:Number =  Math.PI * 2 / cubicBezierCount + angle_in;
			
			var a1:Vector2 = new Vector2(0,r_in);
			var c1:Vector2 = new Vector2(d,r_in);
			var a2:Vector2 = new Vector2(0,r_in);
			var c2:Vector2 = new Vector2(-d,r_in);
			
			a2.rotateBy(-secPi);
			c2.rotateBy(-secPi);
			
			var path:MixedPath = new MixedPath();
			path.addPoint( a1.getPlus(c) );
			path.addControlPoint( c1.getPlus(c) );
			path.addControlPoint( c2.getPlus(c) );
			path.addPoint( a2.getPlus(c) );
			
			for (var i:int = 1; i < fullSegments; i++) 
			{
				a2.rotateBy(-secPi);
				c2.rotateBy(-secPi);
				c1.rotateBy(-secPi);
				path.addControlPoint( c1.getPlus(c) );
				path.addControlPoint( c2.getPlus(c) );
				path.addPoint( a2.getPlus(c) );
			}
			path.deletePointAt(path.pointCount-1);
			path.setClosed( false );
		
			return path;
		}
		
		override public function get type():String
		{
			return "Arc";
		}
	
	}
}