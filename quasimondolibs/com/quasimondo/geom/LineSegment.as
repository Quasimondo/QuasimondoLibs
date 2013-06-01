package com.quasimondo.geom
{

	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class LineSegment extends GeometricShape implements IIntersectable
	{
		public var p1:Vector2;
		public var p2:Vector2;
		
		//private var dirty:Boolean = true;
		//private var __length:Number;
		
		private const ZERO_DISTANCE:Number = 1e-10;
		
		public static function fromSlope( slope:Number, intercept:Number, bounds:Rectangle ):LineSegment
		{
			var pts:Vector.<Vector2> = new Vector.<Vector2>()
			var x:Number = bounds.left;
			var y:Number = slope * x + intercept;
			if ( y >= bounds.top && y <= bounds.bottom )
			{
				pts.push( new Vector2( x,y ) );
			}
			
			x = bounds.right;
			y = slope * x + intercept;
			if ( y >= bounds.top && y <= bounds.bottom )
			{
				pts.push( new Vector2( x,y ) );
			}
			
			if ( pts.length < 2 && slope != 0 )
			{
				y = bounds.top;
				x = (y - intercept) / slope;
				if (x >= bounds.left && x <= bounds.right )
				{
					pts.push( new Vector2( x,y ) );
				}
				
				if ( pts.length < 2 )
				{
					y = bounds.bottom;
					x = (y- intercept) / slope;
					if (x >= bounds.left && x <= bounds.right )
					{
						pts.push( new Vector2( x,y ) );
					}
				}
			}
			if ( pts.length == 2 )
			{
				return new LineSegment( pts[0], pts[1] );
			}
			
			return null;
		}
		
		public static function fromXY( x1:Number, y1:Number,x2:Number, y2:Number):LineSegment
		{
			return new LineSegment( new Vector2( x1,y1), new Vector2( x2,y2));
		}
		
		public static function fromPointAndAngleAndLength( p1:Vector2, angle:Number, length:Number, centered:Boolean = false ):LineSegment
		{
			var line:LineSegment
			if ( !centered )
				line = new LineSegment( p1, p1.getAddCartesian( angle, length ) );
			else
				line = new LineSegment( p1.getAddCartesian( angle, -length*0.5 ), p1.getAddCartesian( angle, length*0.5 ) );
			return line
		}
		
		
		public function LineSegment ( value1:*, value2:*, value3:* = null, value4:*= null )
		{
			if ( value1 is Vector2 )
			{
				p1 = value1;
			} else if ( value1 is Point )
			{
				p1 = new Vector2( value1.x, value1.y );
			} else if ( value1 is Number && value2 is Number )
			{
				p1 = new Vector2( value1, value2 );
			} else {
				throw new Error ( "Object not supported: "+value1);
			} 
			
			if ( value2 is Vector2 )
			{
				p2 = value2;
			} else if ( value2 is Point )
			{
				p2 = new Vector2( value2.x, value2.y );
			} else if ( value3 is Number && value4 is Number )
			{
				p2 = new Vector2( value3, value4 );
			} else {
				throw new Error ( "Object not supported: "+value2);
			}
				
		}
		
		public function get slope():Number
		{
			return (p2.y-p1.y) / (p2.x-p1.x);
		}
		
		public function get intercept():Number
		{
			return p1.y - slope * p1.x;
		}
	
		public function updateFromPoints( p1:Point = null, p2:Point = null):void
		{
			if ( p1 != null ) {
				this.p1.x = p1.x;
				this.p1.y = p1.y;
			}
			if ( p2 != null ) {
				this.p2.x = p2.x;
				this.p2.y = p2.y;
			}
			
		}
		
		override public function get type():String
		{
			return "LineSegment";
		}
		
		override public function draw( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.lineTo( p2.x, p2.y );
		}
		
		override public function export( g:IGraphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.lineTo( p2.x, p2.y );
		}
		
		public function drawWithOffset( g:Graphics, offset:Vector2 ):void
		{
			g.moveTo( p1.x + offset.x, p1.y + offset.y );
			g.lineTo( p2.x + offset.x, p2.y + offset.y );
		}
		
		override public function drawExtras ( g:Graphics, factor:Number = 1 ):void
		{
			var p:LineSegment = this.getParallel( 10 );
			
			g.moveTo( p1.x, p1.y );
			g.lineTo( p.p1.x, p.p1.y );
			g.moveTo( p2.x, p2.y );
			g.lineTo( p.p2.x, p.p2.y );
			
			p = this.getParallel( 5 );
			p.draw( g );
			
			p1.draw(g,factor);
			p2.draw(g,factor);
		}
		
		override public function drawTo ( g: Graphics ):void
		{
			g.lineTo( p2.x, p2.y );
		}
		
		override public function moveToStart ( g: Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function moveToEnd ( g: Graphics ): void
		{
			g.moveTo( p2.x, p2.y );
		}
		
		override public function exportDrawTo ( g: IGraphics ):void
		{
			g.lineTo( p2.x, p2.y );
		}
		
		override public function exportMoveToStart ( g: IGraphics ):void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function exportMoveToEnd ( g: IGraphics ): void
		{
			g.moveTo( p2.x, p2.y );
		}
		
		override public function get length():Number
		{
			//if (!dirty) return __length;
			
			//__length = ;
			//dirty = false;
			
			return p1.getMinus(p2).length;
		}
		
		public function get angle():Number
		{
			return p1.angleTo( p2 );
		}
		
		override public function hasPoint( p:Vector2 ):Boolean
		{
			if ( p1.squaredDistanceToVector( p ) < SNAP_DISTANCE * SNAP_DISTANCE) return true;
			if ( p2.squaredDistanceToVector( p ) < SNAP_DISTANCE * SNAP_DISTANCE) return true;
			return false;
		}
		
		override public function getPoint( t:Number ): Vector2 
		{
			return p1.getLerp(p2,t);
		}
		
		override public function getPointAtOffset( offset:Number ): Vector2 
		{
			return p1.getPlus(p2.getMinus(p1).newLength(offset));
		}
		
		override public function getBoundingRect(  loose:Boolean = true ):Rectangle
		{
			var minP:Vector2 = p1.getMin( p2 );
			var size:Vector2 = p1.getMax( p2 ).minus( minP );
			return new Rectangle( minP.x, minP.y , size.x, size.y  );
		}
		
		public function squaredDistanceToPoint(pt:Vector2 ):Number 
		{
			var p:Vector2 = new Vector2(pt);
			var D:Vector2 = new Vector2(p1, p2);
			var YmP0:Vector2 = new Vector2(p1, p);
			var t:Number = D.dot(YmP0);
			if (t<=0) {
				return YmP0.dot(YmP0);
			}
			var DdD:Number = D.dot(D);
			if (t>=DdD) {
				var YmP1:Vector2 = new Vector2(p, p2);
				return YmP1.dot(YmP1);
			}
			return YmP0.dot(YmP0)-t*t/DdD;
		};
		
		public function getShortestConnectionToLine( l:LineSegment ):LineSegment 
		{
			
			var intersection:Intersection = intersect( l );
			if ( intersection.status == Intersection.INTERSECTION  ) return new LineSegment( intersection.points[0], intersection.points[0]);
			if ( intersection.status == Intersection.COINCIDENT  ) return new LineSegment( l.p1, l.p1);
			
			var p:Vector2 = l.getClosestPoint( p1 );
			var cn:Array = [ p1, p ];
			var dist:Number = p.squaredDistanceToVector( p1 );
			var minDist:Number = dist;
			
			p = l.getClosestPoint( p2 );
			dist = p.squaredDistanceToVector( p2 );
			if ( dist < minDist )
			{
				cn = [ p2,p];
				minDist = dist;
			}
			
			p = getClosestPoint( l.p1 );
			dist = p.squaredDistanceToVector( l.p1  );
			if ( dist < minDist )
			{
				cn = [ l.p1,p];
				minDist = dist;
			}
			
			p = getClosestPoint( l.p2 );
			dist = p.squaredDistanceToVector( l.p2  )
			if ( dist < minDist )
			{
				cn = [ l.p2,p];
			}
			
			return new LineSegment( cn[0], cn[1] );
		}
		
		public function distanceToLine( l:LineSegment ):Number 
		{
			return getShortestConnectionToLine(l ).length;
		
		};
	
		public function distanceToPoint(pt:Vector2 ):Number 
		{
			return Math.sqrt( squaredDistanceToPoint(pt));
		};
		
		public function contains( pt:Vector2 ):Boolean
		{
			//trace( (p1.distanceToVector( pt ) + p2.distanceToVector( pt ) ) - length);
			return ( p1.distanceToVector( pt ) + p2.distanceToVector( pt ) ) - length < ZERO_DISTANCE; 
		}
		
		public function equals( ls:LineSegment ):Boolean
		{
			return( (p1.distanceToVector(ls.p1 ) < ZERO_DISTANCE &&  p2.distanceToVector(ls.p2 ) < ZERO_DISTANCE) || (p1.distanceToVector(ls.p2 ) < ZERO_DISTANCE &&  p2.distanceToVector(ls.p1 ) < ZERO_DISTANCE));
		}
	
		public function getClosestPointOnLine( pt:Vector2 ):Vector2
		{
			var Dx:Number = p2.x - p1.x;
			var Dy:Number = p2.y - p1.y;
			
			var YmP0x:Number = pt.x - p1.x;
			var YmP0y:Number = pt.y - p1.y;
			
			var t:Number = YmP0x * Dx + YmP0y * Dy;
			
			var DdD:Number = Dx*Dx + Dy*Dy;
			
			if (DdD == 0) 
			{
				return new Vector2( p1 );
			}
			
			return p1.getLerp( p2, t / DdD );
		};
		
		override public function getClosestPoint( pt:Vector2 ):Vector2
		{
			var Dx:Number = p2.x - p1.x;
			var Dy:Number = p2.y - p1.y;
			
			var YmP0x:Number = pt.x - p1.x;
			var YmP0y:Number = pt.y - p1.y;
			
			var t:Number = YmP0x * Dx + YmP0y * Dy;
			
			if ( t <= 0) 
			{
				return new Vector2( p1 );
			}
			
			var DdD:Number = Dx*Dx + Dy*Dy;
			if ( t >= DdD ) 
			{
				return new Vector2( p2 );
			}
			
			if (DdD == 0) 
			{
				return new Vector2( p1 );
			}
			
			return p1.getLerp( p2, t / DdD );
		};
		
		override public function getClosestT( pt:Vector2 ):Number
		{
			var Dx:Number = p2.x - p1.x;
			var Dy:Number = p2.y - p1.y;
			
			var YmP0x:Number = pt.x - p1.x;
			var YmP0y:Number = pt.y - p1.y;
			
			var t:Number =  YmP0x * Dx + YmP0y * Dy;
			var DdD:Number = Dx*Dx + Dy*Dy;
			if ( DdD == 0 ) return 0;
			return ( t / DdD )
		
		};
		
		override public function getNormalAtPoint( p:Vector2 ):Vector2
		{
			return new Vector2(p1, p2).getNormal();
		}
		
		override public function translate( p:Vector2 ):GeometricShape
		{
			p1.plus( p );
			p2.plus( p );
			return this;
		}
		
		public function getParallel( d:Number ):LineSegment
		{
			var v:Vector2 = new Vector2(p1, p2);
			var n:Vector2 = v.getNormal().multiply(d);
			return new LineSegment( p1.getPlus(n),  p2.getPlus(n) );
		};
		
		public function getOrth( p:Vector2, lengthLeft:Number = 1, lengthRight:Number = 1 ):LineSegment
		{
			var cp:Vector2 = getClosestPointOnLine( p );
			if ( p.squaredDistanceToVector(cp) > ZERO_DISTANCE )
			{
				p = cp;
			}
			
			var v:Vector2 = new Vector2(p1, p2).getNormal();
			return new LineSegment( p.getPlus( v.multiply(lengthLeft)), p.getPlus( v.multiply(-lengthRight)) );
		};
		
		
		public function getIntersection( l:LineSegment, onlyInThisSegment:Boolean = false, onlyInOtherSegment:Boolean = false):Vector.<Vector2>
		{
			var result:Vector.<Vector2> = new Vector.<Vector2>();
			var ua_t:Number = (l.p2.x-l.p1.x)*(p1.y-l.p1.y)-(l.p2.y-l.p1.y)*(p1.x-l.p1.x);
			var ub_t:Number = (p2.x-p1.x)*(p1.y-l.p1.y)-(p2.y-p1.y)*(p1.x-l.p1.x);
			var u_b:Number  = (l.p2.y-l.p1.y)*(p2.x-p1.x)-(l.p2.x-l.p1.x)*(p2.y-p1.y);
			
			if (u_b != 0) 
			{
				var ua:Number = ua_t/u_b;
				var ub:Number = ub_t/u_b;
				if ( onlyInThisSegment && ( ua < 0 || ua > 1 || ub < 0 || ub > 1 ) ) return result
				if ( onlyInOtherSegment && ( ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1 ) ) return result
				result.push( new Vector2(p1.x+ua*(p2.x-p1.x), p1.y+ua*(p2.y-p1.y)) );
			} else if ( onlyInThisSegment ) {
				if ( this.contains( l.p1 ) ) result.push( l.p1 );
				if ( this.contains( l.p2 ) ) result.push( l.p2 );
				if ( l.contains( p1 ) ) result.push( p1 );
				if ( l.contains( p2 ) ) result.push( p2 );
			}
			return result;
		};
		
		/**
		 * Checks for edge intersection.
		 * @return True if edges intersect in X pattern.
		 * @see http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
		 */
		public function crosses( line:LineSegment ):Boolean
		{
			var x1:Number = p1.x, y1:Number = p1.y,
				x2:Number = p2.x, y2:Number = p2.y,
				x3:Number = line.p1.x, y3:Number = line.p1.y,
				x4:Number = line.p2.x, y4:Number = line.p2.y;
			
			var a:Number = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
			var b:Number = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
			var d:Number = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
			
			return (d != 0) && (0 < a/d) && (a/d < 1) && (0 < b/d) && (b/d < 1);
		}
		
		public function multiply( factor:Number ):LineSegment
		{
			var mx:Number = 0.5* ( p1.x + p2.x );
			var my:Number = 0.5* ( p1.y + p2.y );
			
			p1.x = mx + ( p1.x - mx ) * factor;
			p1.y = my + ( p1.y - my ) * factor;
			
			p2.x = mx + ( p2.x - mx ) * factor;
			p2.y = my + ( p2.y - my ) * factor;
			
			return this;
		}
		
		public function lerp( factor:Number, fromP1:Boolean = true ):LineSegment
		{
			if ( fromP1 )
			{
				p2.x = p1.x + ( p2.x - p1.x ) * factor;
				p2.y = p1.y + ( p2.y - p1.y ) * factor;
			} else {
				p1.x = p2.x + ( p1.x - p2.x ) * factor;
				p1.y = p2.y + ( p1.y - p2.y ) * factor;
			}
			return this;
		}
		
		public function setLength( value:Number, fromP1:Boolean = true ):LineSegment
		{
			var f:Number = value / length;
			
			return lerp( f, fromP1 );
		}
		
		
		public function clip( xmin:Number,xmax:Number,ymin:Number,ymax:Number):void
		{ 
			
			if(    p1.x > xmin && p1.x < xmax 
		      	&& p1.y > ymin && p1.y < ymax
		      	&& p2.x > xmin && p2.x < xmax
		      	&& p2.y > ymin && p2.y < ymax ) return;
		     
			
   	 		var top:LineSegment = LineSegment.fromXY( xmin,ymin, xmax,ymin);
   	 		var bottom:LineSegment = LineSegment.fromXY( xmin,ymax, xmax,ymax);
   	 		var left:LineSegment = LineSegment.fromXY( xmin,ymin, xmin,ymax);
   	 		var right:LineSegment = LineSegment.fromXY( xmax,ymin, xmax,ymax);
   	 		
   	 		var pi:Intersection = intersect( top );
   	 		if ( pi.status == Intersection.INTERSECTION )
   	 		{
   	 			if ( p1.y > Vector2(pi.points[0]).y )
   	 			{
   	 				p2 = Vector2(pi.points[0]);
   	 			} else {
   	 				p1 = Vector2(pi.points[0]);
   	 			}
   	 		}
   	 		
   	 		pi = intersect( bottom );
   	 		if ( pi.status == Intersection.INTERSECTION )
   	 		{
   	 			if ( p1.y < Vector2(pi.points[0]).y )
   	 			{
   	 				p2 = Vector2(pi.points[0]);
   	 			} else {
   	 				p1 = Vector2(pi.points[0]);
   	 			}
   	 		}
   	 		
   	 		pi = intersect( left );
   	 		if ( pi.status == Intersection.INTERSECTION )
   	 		{
   	 			if ( p1.x > Vector2(pi.points[0]).x )
   	 			{
   	 				p2 = Vector2(pi.points[0]);
   	 			} else {
   	 				p1 = Vector2(pi.points[0]);
   	 			}
   	 		} 
   	 		
   	 		pi = intersect( right );
   	 		if ( pi.status == Intersection.INTERSECTION )
   	 		{
   	 			if ( p1.x < Vector2(pi.points[0]).x )
   	 			{
   	 				p2 = Vector2(pi.points[0]);
   	 			} else {
   	 				p1 = Vector2(pi.points[0]);
   	 			}
   	 		} 
   	 		
   	 		
  		}
  		
  		
  		public function fit( xmin:Number,xmax:Number,ymin:Number,ymax:Number):void
		{ 
			
			var top:LineSegment = LineSegment.fromXY( xmin,ymin, xmax,ymin);
   	 		var bottom:LineSegment = LineSegment.fromXY( xmin,ymax, xmax,ymax);
   	 		var left:LineSegment = LineSegment.fromXY( xmin,ymin, xmin,ymax);
   	 		var right:LineSegment = LineSegment.fromXY( xmax,ymin, xmax,ymax);
   	 		
   	 		var pt:Vector.<Vector2> = getIntersection( top );
   	 		var pb:Vector.<Vector2> = getIntersection( bottom );
   	 		var pl:Vector.<Vector2> = getIntersection( left );
   	 		var pr:Vector.<Vector2> = getIntersection( right );
   	 		
   	 		if ( pt.length == 1 && pt[0].x >= xmin && pt[0].x <= xmax )
   	 		{
   	 			if ( p1.y >  p2.y )
   	 			{
   	 				p2 = pt[0];
   	 			} else {
   	 				p1 = pt[0];
   	 			}
   	 		}
   	 		
   	 		if ( pb.length == 1 && pb[0].x >= xmin && pb[0].x <= xmax )
   	 		{
   	 			if ( p1.y < p2.y )
   	 			{
   	 				p2 = pb[0];
   	 			} else {
   	 				p1 = pb[0];
   	 			}
   	 		}
   	 		
   	 		if ( pl.length == 1 && pl[0].y >= ymin && pl[0].y <= ymax )
   	 		{
   	 			if ( p1.x > p2.x )
   	 			{
   	 				p2 = pl[0];
   	 			} else {
   	 				p1 = pl[0];
   	 			}
   	 		} 
   	 		
   	 		if ( pr.length == 1 && pr[0].y >= ymin && pr[0].y <= ymax )
   	 		{
   	 			if ( p1.x < p2.x )
   	 			{
   	 				p2 = pr[0];
   	 			} else {
   	 				p1 = pr[0];
   	 			}
   	 		} 
   	 		
   	 		
  		}
		
		public function isLeft( p:Vector2):Number
		{
			return (p2.x-p1.x)*(p.y-p1.y)-(p.x-p1.x)*(p2.y-p1.y);
		}
  		
		override public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = p1.getLerp( p2, 0.5 );
			
			p1.rotateAround(angle, center );
			p2.rotateAround(angle, center );
			return this;
		}
		
		override public function scale( factorX:Number, factorY:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = p1.getLerp( p2, 0.5 );
			
			p1.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			p2.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			return this;
		}
  		
  		override public function clone( deepClone:Boolean = true ):GeometricShape
  		{
  			if ( deepClone)
  				return new LineSegment( p1.getClone(), p2.getClone() );
  			else 
  				return new LineSegment( p1, p2 );
  		}
		
		public function getMirrorPoint( p:Vector2 ):Vector2
		{
			var Dx:Number = p2.x - p1.x;
			var Dy:Number = p2.y - p1.y;
			var DdD:Number = Dx*Dx + Dy*Dy;
			if (DdD == 0) 
			{
				return p.getMirror( p1 );
			}
			
			var YmP0x:Number = p.x - p1.x;
			var YmP0y:Number = p.y - p1.y;
			var t:Number = YmP0x * Dx + YmP0y * Dy;
			
			return p.getMirror( p1.getLerp( p2, t / DdD ) );
		}
		
		public function mirrorPoint( p:Vector2 ):Vector2
		{
			
			var Dx:Number = p2.x - p1.x;
			var Dy:Number = p2.y - p1.y;
			var DdD:Number = Dx*Dx + Dy*Dy;
			if (DdD == 0) 
			{
				return p.mirror( p1 );
			}
			
			var YmP0x:Number = p.x - p1.x;
			var YmP0y:Number = p.y - p1.y;
			var t:Number = YmP0x * Dx + YmP0y * Dy;
			
			return p.mirror( p1.getLerp( p2, t / DdD ) );
		}
		
		public function getSplitAtT( t:Number, clonePoints:Boolean = true ):Vector.<LineSegment>
		{
			var result:Vector.<LineSegment> = new Vector.<LineSegment>();
			if ( t == 0 || t == 1 )
			{
				result.push( clonePoints ? LineSegment(this.clone()) : this );
			}
			if ( t<=0 || t>=1) return result;
			
			var p_t:Vector2 = getPoint( t );
			
			result.push( new LineSegment( clonePoints ? p1.getClone() : p1, p_t));
			result.push( new LineSegment( clonePoints ? p_t.getClone() : p_t, clonePoints ? p2.getClone() : p2));
			
			return result;
		}
		
		public function getSplitsAtTs( t:Vector.<Number>, clonePoints:Boolean = true ):Vector.<LineSegment>
		{
			t.sort( function( a:Number, b:Number ):int{ return ( a < b ? -1 : ( a > b ? 1 : 0))});
			
			var current:LineSegment = this;
			var last_t:Number = 0;
			var result:Vector.<LineSegment> = new Vector.<LineSegment>();
			for ( var i:int = 0; i < t.length; i++ )
			{
				var parts:Vector.<LineSegment> = current.getSplitAtT( (t[i] - last_t) / ( 1 - last_t ), clonePoints );
				if ( parts.length > 0 )
				{
					result.push( parts[0] );
					current = ( parts.length == 2 ? parts[1] : parts[0] );
				}
				last_t = t[i];
			}
			
			if ( parts.length == 2 ) result.push( parts[1] );
			return result;
		}
		
		public function toString( ): String
		{
			return p1+" - "+p2;
		}
		
		public function toSVG( absolute:Boolean = true ):String
		{
			if ( absolute )
			{
				return "M "+p1.toSVG()+"L "+p2.toSVG();
			} else {
				return "l "+p2.getMinus( p1 ).toSVG();
			}
		}
	}
}