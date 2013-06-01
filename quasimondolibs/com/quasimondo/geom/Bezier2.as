/*
Quadradic Bezier Curve Class

based on javascript code by Kevin Lindsey
http://www.kevlindev.com/

ported optimized augmented for Actionscript by Mario Klingemann
*/
package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class Bezier2 extends GeometricShape implements IIntersectable
	{
		public var p1:Vector2;
		public var p2:Vector2;
		public var c:Vector2;
		
		private var dirty:Boolean = true;
		private var __length:Number;
		
		private static var CURVE_LENGTH_PRECISION:int = 31;
		private static var OFFSET_PRECISION:Number = 10;
		
		public static function from3Points( p1:Vector2, pt:Vector2, p2:Vector2,t:Number ):Bezier2
		{
			if ( t == 0 ) t = 0.00000001;
			if ( t == 1 ) t = 0.99999999;
			
			var c:Vector2 = new Vector2( 1/(2*(1-t)*t)*pt.x-(1-t)/(2*t)*p1.x-t/(2*(1-t))*p2.x, 1/(2*(1-t)*t)*pt.y-(1-t)/(2*t)*p1.y-t/(2*(1-t))*p2.y );
			return new Bezier2( p1, c, p2 );	
		
		}
		
		public function Bezier2 ( _p1:Vector2, _c:Vector2, _p2:Vector2 )
		{
			p1 = _p1;
			c = _c;
			p2 = _p2;
		}
		
		override public function get type():String
		{
			return "Bezier2";
		}
			
		override public function draw ( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.curveTo( c.x, c.y, p2.x, p2.y );
		}
		
		override public function export ( g:IGraphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.curveTo( c.x, c.y, p2.x, p2.y );
		}
		
		override public function drawExtras ( g:Graphics, factor:Number = 1 ):void 
		{
			g.moveTo( p1.x, p1.y );
			g.lineTo( c.x, c.y);
			g.lineTo( p2.x, p2.y);
			
			p1.draw(g,factor);
			p2.draw(g,factor);
			c.draw(g,factor);
		}
		
		override public function drawTo ( g:Graphics ):void
		{	
			g.curveTo( c.x, c.y, p2.x, p2.y );
		}
		
		override public function moveToStart ( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function exportDrawTo ( g:IGraphics ):void
		{	
			g.curveTo( c.x, c.y, p2.x, p2.y );
		}
		
		override public function exportMoveToStart ( g:IGraphics ):void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function getPoint( t:Number ):Vector2 
		{
			var ti:Number = 1-t;
			
			return new Vector2 ( ti*ti*p1.x+2*t*ti*c.x+t*t*p2.x , ti*ti*p1.y+2*t*ti*c.y+t*t*p2.y);
		}
		
		override public function getPointAtOffset ( offset:Number ):Vector2
		{
			var dsq:Number = offset * offset;
			var p1:Vector2 = getPoint( 0 );
			var p2:Vector2;
			var dt:Number = offset / length;
			var fit:Boolean = false;
			var dx:Number;
			var dy:Number;
			var d:Number;
			
			while (!fit)
			{
				p2 = getPoint( dt );
				dx=p1.x-p2.x;
				dy=p1.y-p2.y;
				d=(dx*dx+dy*dy)-dsq;
				if (d<-OFFSET_PRECISION)
				{
					dt*=1.1;
				} else if (d>OFFSET_PRECISION)
				{
					dt*=0.9;
				} else {
					fit=true;
				}
			}
			return p2;
		}
		
		override public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
			var minP:Vector2 = p1.getMin( p2 ).min( c );
			var size:Vector2 = p1.getMax( p2 ).max( c ).minus( minP );
			return new Rectangle( minP.x, minP.y , size.x, size.y  );
		}
		
		override public function getClosestPoint( p:Vector2 ):Vector2
		{
			// a very bad hack. Only temporary
			var bestD:Number = getPoint(0).squaredDistanceToVector(p);
			var bestT:Number = 0;
			for ( var t:Number = 0.05 ; t <= 1; t+= 0.05 )
			{
				var d:Number = getPoint(t).squaredDistanceToVector(p);
				if ( d < bestD )
				{
					bestD = d;
					bestT = t;
				} 
			}
			var midT:Number = bestT;
			for ( t = Math.max(0,midT - 0.05) ; t <= Math.min(1,midT + 0.05); t+= 0.005 )
			{
				d = getPoint(t).squaredDistanceToVector(p);
				if ( d < bestD )
				{
					bestD = d;
					bestT = t;
				} 
			}
			
			return getPoint(bestT);
		}
		
		override public function getClosestT( p:Vector2 ):Number
		{
			// a very bad hack. Only temporary
			var bestD:Number = getPoint(0).squaredDistanceToVector(p);
			var bestT:Number = 0;
			for ( var t:Number = 0.05 ; t <= 1; t+= 0.05 )
			{
				var d:Number = getPoint(t).squaredDistanceToVector(p);
				if ( d < bestD )
				{
					bestD = d;
					bestT = t;
				} 
			}
			var midT:Number = bestT;
			for ( t = Math.max(0,midT - 0.05) ; t <= Math.min(1,midT + 0.05); t+= 0.005 )
			{
				d = getPoint(t).squaredDistanceToVector(p);
				if ( d < bestD )
				{
					bestD = d;
					bestT = t;
				} 
			}
			
			return bestT;
		}
		
		override public function get length():Number
		{
			if ( !dirty ) return __length;
			
			var min_t:Number = 0;
			var max_t:Number = 1;
			var	i:int;
			var	len:Number = 0;
			var n_eval_pts:int = CURVE_LENGTH_PRECISION;
			if ( !( n_eval_pts & 1 ) ) n_eval_pts++;
		
			var t:Array = [];
			var pt:Array = [];
		
			for ( i = 0 ; i < n_eval_pts ; ++i )
			{
				t[i]  =  i / ( n_eval_pts - 1 );
				pt[i] = getPoint(t[i]);
			}
		
			for ( i = 0 ; i < n_eval_pts - 1 ; i += 2 )
			{
				len += getSectionLength (t[i] , t[int(i+1)] , t[int(i+2)] , pt[i] , pt[int(i+1)] , pt[int(i+2)]);
			}
			
			__length = len;
			dirty = false;
		
			return len;
		}
	
		//	Compute the length of a small section of a parametric curve from
		//	t0 to t2 , recursing if necessary. t1 is the mid-point.
		//	The 3 points at these parametric values are precomputed.
		
		
		 private function getSectionLength (t0:Number , t1:Number , t2:Number , pt0:Vector2 ,pt1:Vector2 , pt2:Vector2 ):Number
		{
		
			var kEpsilon:Number	= 1e-5;
			var kEpsilon2:Number	= 1e-6;
			var kMaxArc:Number	= 1.05;
			var kLenRatio:Number	= 1.2;
		
			var d1:Number ;
			var d2:Number;
			var	len_1:Number;
			var len_2:Number;
			var	da:Number;
			var db:Number;
		
			d1 = pt0.getMinus( pt2 ).length;
		
			da = pt0.getMinus( pt1 ).length;
			db = pt1.getMinus( pt2 ).length;
		
			d2 = da + db;
		
			if ( d2 < kEpsilon || da==0 || db == 0){
				return ( d2 + ( d2 - d1 ) / 3 );
			} else if ( ( d1 < kEpsilon || d2/d1 > kMaxArc ) || ( da < kEpsilon2 || db/da > kLenRatio ) || ( db < kEpsilon2 || da/db > kLenRatio ) ) {
				var	mid_t:Number = ( t0 + t1 ) / 2;
		
				var	pt_mid:Vector2=getPoint ( mid_t );
		
				len_1 = getSectionLength( t0 ,mid_t ,  t1 ,  pt0 ,  pt_mid ,  pt1 );
		
				mid_t = ( t1 + t2 ) / 2;
				
				pt_mid = getPoint ( mid_t );
		
				len_2 = getSectionLength (t1 , mid_t ,t2 , pt1 , pt_mid , pt2 );
		
				return ( len_1 + len_2 );
		
			} else {
				return ( d2 + ( d2 - d1 ) / 3 );
			}
		
		}
		
		 override public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		 {
			 if ( center == null ) center = p1.getClone();
			 p1.rotateAround( angle, center );
			 p2.rotateAround( angle, center );
			 c.rotateAround( angle, center );
			 return this;
		 }
		 
		 override public function scale( factorX:Number, factorY:Number, center:Vector2 = null ):GeometricShape
		 {
			 if ( center == null ) center = p1.getClone();
			 p1.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			 c.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			 p2.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			 return this;
		 }
		 
		 /**
		  * Subdivides a quadratic B&eacute;zier at a given value for the curve's parameter.
		  * The method will return the resulted quadratic B&eacute;zier segments
		  
		  * The method uses de Casteljau algorithm.
		 
		  * @param t the value for parameter where the split should occur.
		  *               If out of the 0..1 range, the function does nothing
		  * @param clonePoints sets if existing curve pointgs should be cloned or reused
		  * Author: Adrian Colomitchi
		  * http://www.caffeineowl.com/graphics/2d/vectorial/index.html
		 */
		 public function getSplitAtT( t:Number, clonePoints:Boolean = true ):Vector.<Bezier2>
		 {
			 var result:Vector.<Bezier2> = new Vector.<Bezier2>();
			 if ( t == 0 || t == 1 )
			 {
				 result.push( clonePoints ? Bezier2(this.clone()) : this );
			 }
			 if ( t<=0 || t>=1) return result;
			
			 var p0x:Number = p1.x + ( t * ( c.x - p1.x));
			 var p0y:Number = p1.y + ( t * ( c.y - p1.y));
			 var p1x:Number = c.x  + ( t * ( p2.x - c.x));
			 var p1y:Number = c.y  + ( t * ( p2.y - c.y));
			 var tp:Vector2 =  new Vector2(p0x + ( t * ( p1x - p0x )), p0y + ( t * ( p1y - p0y )));
			 
			 result.push( new Bezier2( clonePoints ? p1.getClone() : p1, new Vector2(p0x, p0y), tp));
			 result.push( new Bezier2( clonePoints ? tp.getClone() : tp	, new Vector2(p1x, p1y), clonePoints ? p2.getClone() : p2));
				
			 return result;
		}
		 
		 /**
		  * Subdivides a quadratic B&eacute;zier in more than one subdivision points.
		  * The method calls repeatedly the 
		  * {@link #getSplitAtT( t:Number, clonePoints:Boolean = true) single
		  * point split} method.
		  * @param t the array of curve parameters where to split the curve. 
		  * Of course, they need to be in the [0..1) range (1.0 excluded) - otherwise
		  * unpredictable results might happen (in fact they are quite predictable, by I'm
		  * too lazy to check the effect). The method does not check this. Uh, by the
		  * way, the params are supposed to be sorted in ascending order: the method
		  * calls <code>java.utils.Arrays.sort(double[])</code> to make sure they are
		  * (so, if they are not, be warned - the method will have a side effect
		  * on the parameters).
		  * @param clonePoints sets if existing curve pointgs should be cloned or reused 
		  * 
		  * * Author: Adrian Colomitchi
		  * http://www.caffeineowl.com/graphics/2d/vectorial/index.html
		 */
		 public function getSplitsAtTs( t:Vector.<Number>, clonePoints:Boolean = true ):Vector.<Bezier2>
		 {
			 t.sort( function( a:Number, b:Number ):int{ return ( a < b ? -1 : ( a > b ? 1 : 0))});
			 
			 var current:Bezier2 = this;
			 var last_t:Number = 0;
			 var result:Vector.<Bezier2> = new Vector.<Bezier2>();
			 for ( var i:int = 0; i < t.length; i++ )
			 {
				 var parts:Vector.<Bezier2> = current.getSplitAtT( (t[i] - last_t) / ( 1 - last_t ), clonePoints );
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
	
		public function toString( ):String
		{
			return p1+" - " + c + " - "+p2;
		}
		
		public function toSVG( absolute:Boolean = true ):String
		{
			if ( absolute )
			{
				return "M "+p1.toSVG()+"Q "+c.toSVG()+ p2.toSVG();
			} else {
				return "q "+c.getMinus( p1 ).toSVG()+ p2.getMinus( p1 ).toSVG();
			}
		}
	}
}