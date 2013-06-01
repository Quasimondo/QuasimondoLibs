/*
Cubic Bezier Curve Class

based on javascript code by Kevin Lindsey
http://www.kevlindev.com/

ported, optimized and augmented for Actionscript by Mario Klingemann
*/
package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class Bezier3 extends GeometricShape implements IIntersectable
	{
		public var p1:Vector2;
		public var p2:Vector2;
		public var c1:Vector2;
		public var c2:Vector2;
		
		private var ax:Number;
		private var bx:Number;
		private var gx:Number;
		
		private var ay:Number;
		private var by:Number;
		private var gy:Number;
		
		private var pre_pt:Dictionary;
		private var pre_seg:Dictionary;
		
		private var dirty:Boolean = true;
		private var __length:Number;
		
		static private const CURVE_LENGTH_PRECISION:int = 31;
		static private const OFFSET_PRECISION:Number = 10;
		static private const MAXDEPTH:int = 64;    // Maximum depth for recursion
  		static private const EPSILON:Number = Math.pow(2, -MAXDEPTH-1); // Flatness control value
		
		/* Precomputed "z" for cubics   */
	    private static const cubicZ:Array = [  
	        [1.0, 0.6, 0.3, 0.1],
	        [0.4, 0.6, 0.6, 0.4],
	        [0.1, 0.3, 0.6, 1.0],
    	];
		
		public function Bezier3 ( _p1:Vector2, _c1:Vector2, _c2:Vector2, _p2:Vector2 )
		{
			p1 = _p1;
			c1 = _c1;
			c2 = _c2;
			p2 = _p2;
			
			updateFactors();
		}
		
		public function update (  _p1:Vector2, _c1:Vector2, _c2:Vector2, _p2:Vector2  ):void
		{
			p1 = _p1;
			c1 = _c1;
			c2 = _c2;
			p2 = _p2;
			
			updateFactors();
		}
		
		public function updateFromPoints (  _p1:Point, _c1:Point, _c2:Point, _p2:Point  ):void
		{
			p1.x = _p1.x;
			p1.y = _p1.y;
			
			c1.x = _c1.x;
			c1.y = _c1.y;
			
			c2.x = _c2.x;
			c2.y = _c2.y;
			
			p2.x = _p2.x;
			p2.y = _p2.y;
			
			updateFactors();
		}
		
		override public function get type():String
		{
			return "Bezier3";
		}
		
		override public function moveToStart ( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function draw (g:Graphics ):void 
		{
			moveToStart( g );
			drawTo( g );
		}
		
		public function drawNicely(g:Graphics, segments:int = 4 ):void 
		{
			moveToStart( g );
			drawToNicely( g, segments );
		}
		
		override public function drawExtras (g:Graphics, factor:Number = 1):void 
		{
			moveToStart( g );
			g.lineTo(c1.x, c1.y);
			g.moveTo(c2.x, c2.y);
			g.lineTo(p2.x, p2.y);
			
			p1.draw(g,factor);
			p2.draw(g,factor);
			c1.draw(g,factor);
			c2.draw(g,factor);
		}
		
		override public function drawTo (g:Graphics):void 
		{
	
			var PA:Vector2 	 = p1.getLerp( c1, 3/4 );
			var PB:Vector2 	 = p2.getLerp( c2, 3/4 );
			
			var dv:Vector2 	 = p2.getMinus(p1).divide(16);
			
			var Pc_1:Vector2 = p1.getLerp( c1, 3/8 );
			var Pc_2:Vector2 = PA.getLerp( PB, 3/8 ).minus(dv);
			
			var Pc_3:Vector2 = PB.getLerp( PA, 3/8 ).plus(dv);
			var Pc_4:Vector2 = p2.getLerp( c2, 3/8 );
		
			var Pa_1:Vector2 = Pc_1.getLerp( Pc_2, 0.5 );
			var Pa_2:Vector2 = PA.getLerp( PB, 0.5 );
			var Pa_3:Vector2 = Pc_3.getLerp( Pc_4, 0.5 );
		
			g.curveTo(Pc_1.x, Pc_1.y, Pa_1.x, Pa_1.y);
			g.curveTo(Pc_2.x, Pc_2.y, Pa_2.x, Pa_2.y);
			g.curveTo(Pc_3.x, Pc_3.y, Pa_3.x, Pa_3.y);
			g.curveTo(Pc_4.x, Pc_4.y, p2.x, p2.y);
		
		}
		
		
		public function drawToNicely (g:Graphics, nSegment:int = 4):int
		{
			//define the local variables
			var curT:LineSegment; // holds the current Tangent object
			var nextT:LineSegment; // holds the next Tangent object
			var total:int = 0; // holds the number of slices used
			
			// make sure nSegment is within range (also create a default in the process)
			if (nSegment < 2) nSegment = 4;
			
			// get the time Step from nSegment
			var tStep:Number = 1 / nSegment;
			
			// get the first tangent Object
			curT = new LineSegment( p1, c1 );
			
			// move to the first point
			// this.moveTo(P0.x, P0.y);
			
			// get tangent Objects for all intermediate segments and draw the segments
			for (var i:int=1; i<=nSegment; i++) 
			{
				
				// get Tangent Object for next point
				nextT = getTangent( i*tStep );
				nextT.draw(g);
				
				// get segment data for the current segment
				total += sliceCubicBezierSegment((i-1)*tStep, i*tStep, curT, nextT, 0, g );
				
				// prepare for next round
				curT = nextT;
			}
			
			return total;
		}
		
		private function sliceCubicBezierSegment( u1:Number, u2:Number, t1:LineSegment, t2:LineSegment, recurs:int, g:Graphics):Number
		{
		
			// prevents infinite recursion (no more than 10 levels)
			// if 10 levels are reached the latest subsegment is 
			// approximated with a line (no quadratic curve). It should be good enough.
			if (recurs > 10) {
				var p:Vector2 = t2.p1;
				g.lineTo(p.x, p.y);
				return 1;
			}
			
			// recursion level is OK, process current segment
			var ctrlPt:Vector2 = t1.getIntersection( t2 ).pop(); 
			var d:Number = 0;
			
			// A control point is considered misplaced if its distance from one of the anchor is greater 
			// than the distance between the two anchors.
			if ( (ctrlPt == null) || 
			( ( t1.p1.squaredDistanceToVector( ctrlPt ) > (d = t1.p1.squaredDistanceToVector( t2.p1))) ||
			( t2.p1.squaredDistanceToVector( ctrlPt)) > d) ) {
			
				// total for this subsegment starts at 0			
				var tot:int = 0;
				
				// If the Control Point is misplaced, slice the segment more
				var uMid:Number = (u1 + u2) / 2;
				var tMid:LineSegment = getTangent( uMid );
				tot += sliceCubicBezierSegment( u1, uMid, t1, tMid, recurs+1,g);
				tot += sliceCubicBezierSegment( uMid, u2, tMid, t2, recurs+1,g);
				
				// return number of sub segments in this segment
				return tot;
				
			} else {
				// if everything is OK draw curve
				p= t2.p1;
				g.curveTo(ctrlPt.x, ctrlPt.y, p.x, p.y);
				return 1;
			}
		}
		


		
		
		override public function getPoint( t:Number ):Vector2 
		{
			if ( pre_pt[t] == null ) 
			{
				var ts:Number = t*t;
				pre_pt[t] = new Vector2 ( ax*ts*t + bx*ts + gx*t + p1.x , ay*ts*t + by*ts + gy*t + p1.y );
			}
			return pre_pt[t];
			
		}
		
		override public function getBoundingRect(  loose:Boolean = true  ):Rectangle
		{
			var minP:Vector2 = p1.getMin( p2 ).min( c1 ).min( c2 );
			var size:Vector2 = p1.getMax( p2 ).max( c1 ).max( c2 ).minus( minP );
			return new Rectangle( minP.x, minP.y , size.x, size.y  );
		}
		
		
		public function updateFactors():void
		{
			gx = 3 * (c1.x - p1.x);
			bx = (3 * (c2.x - c1.x)) - gx;
			ax = p2.x - p1.x - bx - gx;
			
			gy = 3 * (c1.y - p1.y);
			by = (3 * (c2.y - c1.y)) - gy;
			ay = p2.y - p1.y - by - gy;
			
			pre_pt = new Dictionary();
			pre_seg = new Dictionary();
			
			dirty = true;
			
		}
		
		override public function getPointAtOffset ( offset:Number ):Vector2
		{
			var dsq:Number = offset*offset;
			var p1:Vector2 = getPoint( 0 );
			var p2:Vector2;
			var dt:Number = offset / length;
			var fit:Boolean = false;
			var dx:Number;
			var dy:Number;
			var d:Number;
			while (!fit){
				p2 = getPoint( dt );
				dx=p1.x-p2.x;
				dy=p1.y-p2.y;
				d=(dx*dx+dy*dy)-dsq;
				if (d<-OFFSET_PRECISION){
					dt*=1.1;
				} else if (d>OFFSET_PRECISION){
					dt*=0.9;
				} else {
					fit=true;
				}
			}
			return p2;
		}
		
		public function getStepSize( t:Number, delta:Number = 0.01 ):Number
		{
			
			return Math.sqrt( Math.pow(-2*delta*(ax*delta*delta+3*ax*t*t+2*bx*t+gx),2) + Math.pow(-2*delta*(ay*delta*delta+3*ay*t*t+2*by*t+gy),2));
		}
		
		public function getStepSizeDerivative( t:Number, delta:Number = 0.01 ):Number
		{
			return -6*delta*t*(ax-ay)-4*delta*(bx-by);
		}
		
		
		public function getDerivative(t:Number):Number
		{
			return Math.sqrt(Math.pow(ax*t*t + bx * t + gx, 2 ) + Math.pow(ay*t*t + by * t + gy, 2 )); 
		}
		
		public function getDerivativePoint(t:Number):Vector2
		{
			return new Vector2( 3*ax*t*t + 2*bx*t + gx, 3*ay*t*t + 2*by*t + gy );
		}
		
		public function getTangent( t:Number ):LineSegment
		{
			return new LineSegment( getPoint( t ), getDerivativePoint( t ) );
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
		
			for ( i = 0 ; i < n_eval_pts ; ++i ){
				t[i]  =  i / ( n_eval_pts - 1 );
				pt[i] = getPoint(t[i]);
			}
		
			for ( i = 0 ; i < n_eval_pts - 1 ; i += 2 ){
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
			var hash:String = t0+"|"+t1+"|"+t2;
			if ( pre_seg[hash] == null )
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
			
				if ( d2 < kEpsilon ){
					pre_seg[hash] = ( d2 + ( d2 - d1 ) / 3 );
				} else if ( ( d1 < kEpsilon || d2/d1 > kMaxArc ) || ( da < kEpsilon2 || db/da > kLenRatio ) || ( db < kEpsilon2 || da/db > kLenRatio ) ) {
					var	mid_t:Number = ( t0 + t1 ) / 2;
			
					var	pt_mid:Vector2=getPoint ( mid_t );
			
					len_1 = getSectionLength( t0 ,mid_t ,  t1 ,  pt0 ,  pt_mid ,  pt1 );
			
					mid_t = ( t1 + t2 ) / 2;
					
					pt_mid = getPoint ( mid_t );
			
					len_2 = getSectionLength (t1 , mid_t ,t2 , pt1 , pt_mid , pt2 );
			
					pre_seg[hash] = ( len_1 + len_2 );
			
				} else {
					pre_seg[hash] = ( d2 + ( d2 - d1 ) / 3 );
				}
			} 
			return  pre_seg[hash];
		}
		
		
		override public function translate(offset:Vector2):GeometricShape
		{
			p1.plus( offset );
			p2.plus( offset );
			c1.plus( offset );
			c2.plus( offset );
			
			updateFactors();
			return this;
		}
		
		override public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = p1.getClone();
			p1.rotateAround( angle, center );
			p2.rotateAround( angle, center );
			c1.rotateAround( angle, center );
			c2.rotateAround( angle, center );
			return this;
		}
		
		override public function scale( factorX:Number, factorY:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = p1.getClone();
			p1.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			c1.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			c2.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			p2.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			return this;
		}
		
		public function getPoints( n:int ):Array
		{
			if (n<2) n=2;
			var pts:Array = []
			var f:Number = 1 / (n-1);
			for (var i:Number=0;i<=1;i+=f)
			{
				pts.push( getPoint(i) );
			}
			if (pts.length<n) pts.push( getPoint(1) );
			return pts;
		}
		
		
		public function getEquidistantPoints( n:int, n_eval_pts:int = 4 ):Array
		{
			if (n<1) n=1;
		
				
			var n_segs:int=n+1;
			var b_len:Number = segmentLength();
			var seg_len:Number = b_len / n_segs;
			var start_t:Number = 0;
			var avg_t:Number = 1 / n_segs;
			var end_t:Number;
		
			var pts:Array = []
			pts[0] = getPoint(0);
			for (var i:int = 0; i<n_segs-1;i++)
			{
				end_t = start_t+avg_t;
				start_t = getCurveSegmentByLength(seg_len,start_t,end_t,n_eval_pts);
				avg_t = (1-start_t)/((n_segs-1)-i);
				pts[i+1] = getPoint(start_t);
			}
		
			return pts;
		}
		
		private function getCurveSegmentByLength( seg_len:Number, start_t:Number, end_t:Number, n_eval_pts:int = 4):Number
		{
			var Epsilon:Number = 1;
			var len:Number, d:Number;
			var done:Boolean = false;
			var max_t:Number=2*end_t-start_t;
			var min_t:Number=start_t;
			var f:Number = .2
			var step:Number=(end_t-start_t)*f;
			var dir:Number = 1;
			
			do{
				len = segmentLength(start_t,end_t,n_eval_pts);
				d = len - seg_len;
				if ( d > Epsilon || d < -Epsilon )
				{
					if ((d<0) == (dir==-1))
					{
						dir=-dir;
						step *= f;
					}
					end_t+=dir*step;
				} else 
				{
					done=true;
				}
			} while(!done)

			return end_t;
		}
		
		//	Calculates the length of a parametric curve from min_t to max_t.
		//	n_eval_pts points along the curve will be determined ( not
		//	allowing for any recursion that may be necessary )
		
		public function segmentLength( min_t:Number = 0,max_t:Number = 1, n_eval_pts:int = 31 ):Number
		{
		
			var	i:int;
			var	len:Number = 0;
			
			if ( !( n_eval_pts & 1 ) )
				n_eval_pts++;
			
			var t:Array = [ ];
			var pt:Array =  [];
		
			for ( i = 0 ; i < n_eval_pts; ++i )
			{
				t[i]  =  min_t + ( max_t - min_t ) *i / ( n_eval_pts - 1 );
				pt[i]= getPoint(t[i]);
			}
		
			for ( i = 0 ; i < n_eval_pts - 1; i += 2 ){
				len += getSectionLength (t[i] , t[int(i+1)] , t[int(i+2)] , pt[i] , pt[i+1] , pt[int(i+2)]);
			}
		
			return len;
		}
	
	
		/**
	     * Return the nearest point  on cubic bezier curve nearest to point pa.
	     *
	     */    
	    override public function getClosestPoint( pa:Vector2 ):Vector2 
	    {
	                                    
	        var tCandidate:Vector.<Number> = new Vector.<Number>();     // Possible roots
	       
	        // Convert problem to 5th-degree Bezier form
	        var w:Vector.<Vector2> = convertToBezierForm( pa );
	
	        // Find all possible roots of 5th-degree equation
	        var nSolutions:int = findRoots( w, tCandidate, 0);
	
	        // Compare distances of P5 to all candidates, and to t=0, and t=1
	        // Check distance to beginning of curve, where t = 0
	        //var minDistance:Number = pa.distanceToVector( p1 );
	        var minDistance:Number = pa.squaredDistanceToVector( p1 );
	        var p:Vector2;
			var bestP:Vector2 = p1;
			
	        // Find distances for candidate points
	       
	        var distance:Number;
	        for (var i:int = 0; i < nSolutions; i++) 
	        {
	        	p = getPoint(tCandidate[i]);
	            //distance = pa.distanceToVector( p );
	            distance = pa.squaredDistanceToVector( p );
	            if (distance < minDistance) 
	            {
	                minDistance = distance;
	                bestP = p;
	            }
	        }
	
	        // Finally, look at distance to end point, where t = 1.0
	        //distance =  pa.distanceToVector( p2 );
	        distance =  pa.squaredDistanceToVector( p2 );
	        if (distance < minDistance) {
	            minDistance = distance;
	            bestP = p2;
	        }
	
			return bestP;
	    }
		
		
		/**
		 * Return the nearest t on cubic bezier curve nearest to point pa.
		 *
		 */    
		override public function getClosestT( pa:Vector2 ):Number 
		{
			
			var tCandidate:Vector.<Number> = new Vector.<Number>();     // Possible roots
			
			// Convert problem to 5th-degree Bezier form
			var w:Vector.<Vector2> = convertToBezierForm( pa );
			
			// Find all possible roots of 5th-degree equation
			var nSolutions:int = findRoots( w, tCandidate, 0);
			
			// Compare distances of P5 to all candidates, and to t=0, and t=1
			// Check distance to beginning of curve, where t = 0
			var minDistance:Number = pa.squaredDistanceToVector( p1 );
			var p:Vector2;
			var bestT:Number = 0;
			
			// Find distances for candidate points
			
			var distance:Number;
			for (var i:int = 0; i < nSolutions; i++) 
			{
				p = getPoint(tCandidate[i]);
				distance = pa.squaredDistanceToVector( p );
				if (distance < minDistance) 
				{
					minDistance = distance;
					bestT = tCandidate[i];
				}
			}
			
			// Finally, look at distance to end point, where t = 1.0
			distance =  pa.squaredDistanceToVector( p2 );
			if (distance < minDistance) {
				minDistance = distance;
				bestT = 1;
			}
			
			return bestT;
		}
		
		
		/**
		 * Return the distance to the nearest point (pn) on cubic bezier curve c nearest to point pa.
		 *
		 * @param c cubice curve
		 * @param pa arbitrary point
		 * @param pn nearest point found (return param)
		 * @return distance squared between pa and nearest point (pn)
		 */    
		public function squaredDistanceToPoint( pa:Vector2 ):Number 
		{
			
			var tCandidate:Vector.<Number> = new Vector.<Number>();     // Possible roots
			
			// Convert problem to 5th-degree Bezier form
			var w:Vector.<Vector2> = convertToBezierForm( pa );
			
			// Find all possible roots of 5th-degree equation
			var nSolutions:int = findRoots( w, tCandidate, 0);
			
			// Compare distances of P5 to all candidates, and to t=0, and t=1
			// Check distance to beginning of curve, where t = 0
			//var minDistance:Number = pa.distanceToVector( p1 );
			var minDistance:Number = pa.squaredDistanceToVector( p1 );
			var p:Vector2;
			
			// Find distances for candidate points
			
			var distance:Number;
			for (var i:int = 0; i < nSolutions; i++) 
			{
				p = getPoint(tCandidate[i]);
				//distance = pa.distanceToVector( p );
				distance = pa.squaredDistanceToVector( p );
				if (distance < minDistance) 
				{
					minDistance = distance;
				}
			}
			
			// Finally, look at distance to end point, where t = 1.0
			//distance =  pa.distanceToVector( p2 );
			distance =  pa.squaredDistanceToVector( p2 );
			if (distance < minDistance) {
				minDistance = distance;
			}
			
			return minDistance;
		}
	    
	    /**
	     *  FindRoots :
	     *  Given a 5th-degree equation in Bernstein-Bezier form, find
	     *  all of the roots in the interval [0, 1].  Return the number
	     *  of roots found.
	     */
	    private function findRoots( w:Vector.<Vector2>, t:Vector.<Number>,  depth:int ):int 
	    {  
	
	        switch ( crossingCount(w, 5)) 
	        {
	            case 0 : { // No solutions here
	                return 0;   
	            }
	            case 1 : { // Unique solution
	                // Stop recursion when the tree is deep enough
	                // if deep enough, return 1 solution at midpoint
	                if (depth >= MAXDEPTH) 
	                {
	                    t[0] = ( w[0].x + w[5].x) / 2.0;
	                    return 1;
	                }
	                if (controlPolygonFlatEnough(w, 5)) 
	                {
	                    t[0] = computeXIntercept(w, 5);
	                    return 1;
	                }
	                break;
	            }
	        }
	
	        // Otherwise, solve recursively after
	        // subdividing control polygon
	        var left:Vector.<Vector2> = new Vector.<Vector2>();    // New left and right
	        var right:Vector.<Vector2> = new Vector.<Vector2>();   // control polygons
	        var leftT:Vector.<Number> = new Vector.<Number>();            // Solutions from kids
	        var rightT:Vector.<Number> = new Vector.<Number>();
	        
	        var p:Vector.<Vector.<Vector2>> = Vector.<Vector.<Vector2>>([new Vector.<Vector2>(),
																		 new Vector.<Vector2>(),
																		 new Vector.<Vector2>(),
																		 new Vector.<Vector2>(),
																		 new Vector.<Vector2>(),
																		 new Vector.<Vector2>()]);
        	var i:int, j:int;
         	for ( j=0; j <= 5; j++) 
         	{
           	 	p[0][j] = new Vector2( w[j] );
        	}
	       
            /* Triangle computation */
	        for ( i = 1; i <= 5; i++) {  
	            for ( j = 0 ; j <= 5 - i; j++) {
	                p[i][j] = new Vector2(
	                    0.5 * p[i-1][j].x + 0.5 * p[i-1][j+1].x,
	                    0.5 * p[i-1][j].y + 0.5 * p[i-1][j+1].y
	                );
	            }
	        }
        
	        if (left != null) {
	            for ( j = 0; j <= 5; j++) {
	                left[j]  = p[j][0];
	            }
	        }
        
	        if (right != null) {
	            for ( j = 0; j <= 5; j++) {
	                right[j] = p[5-j][j];
	            }
	        }
        
        	var leftCount:int  = findRoots(left,  leftT, depth+1);
	        var rightCount:int = findRoots(right, rightT, depth+1);
	    
	        // Gather solutions together
	        for ( i = 0; i < leftCount; i++) 
	        {
	            t[i] = leftT[i];
	        }
	        for ( i = 0; i < rightCount; i++) 
	        {
	            t[i+leftCount] = rightT[i];
	        }
	    
	        // Send back total number of solutions  */
	        return leftCount+rightCount;
	    }
		
		/**
	     * CrossingCount :
	     *  Count the number of times a Bezier control polygon 
	     *  crosses the 0-axis. This number is >= the number of roots.
	     *
	     */
	    	
	     private function crossingCount( v:Vector.<Vector2>,  degree:int ):int 
	     {
	        var nCrossings:int = 0;
	        var sign:int = v[0].y < 0 ? -1 : 1;
	        var oldSign:int = sign;
	        for (var i:int = 1; i <= degree; i++) 
	        {
	            sign = v[i].y < 0 ? -1 : 1;
	            if (sign != oldSign) nCrossings++;
	            oldSign = sign;
	        }
	        return nCrossings;
	    }
    
    
	    /*
	     *  ComputeXIntercept :
	     *  Compute intersection of chord from first control point to last
	     *      with 0-axis.
	     * 
	     */
	    private function computeXIntercept( v:Vector.<Vector2>,  degree:int ):Number
	     {
	    
	        var XNM:Number = v[degree].x - v[0].x;
	        var YNM:Number = v[degree].y - v[0].y;
	        var XMK:Number = v[0].x;
	        var YMK:Number = v[0].y;
	    
	        var detInv:Number = - 1.0/YNM;
	    
	        return (XNM*YMK - YNM*XMK) * detInv;
	    }
    
    	 /*  ControlPolygonFlatEnough :
	     *  Check if the control polygon of a Bezier curve is flat enough
	     *  for recursive subdivision to bottom out.
	     *
	     */
	     private function controlPolygonFlatEnough( v:Vector.<Vector2>, degree:int ):Boolean
	     {
	
	        // Find the  perpendicular distance
	        // from each interior control point to
	        // line connecting v[0] and v[degree]
	    
	        // Derive the implicit equation for line connecting first
	        // and last control points
	        var a:Number = v[0].y - v[degree].y;
	        var b:Number = v[degree].x - v[0].x;
	        var c:Number = v[0].x * v[degree].y - v[degree].x * v[0].y;
	    
	        var abSquared:Number = (a * a) + (b * b);
	        
	        var distance:Vector.<Number> = new Vector.<Number>(degree,true);      // Distances from pts to line
    
	        for (var i:int = 1; i < degree; i++) {
	        // Compute distance from each of the points to that line
	            distance[i] = a * v[i].x + b * v[i].y + c;
	            if (distance[i] > 0.0) {
	                distance[i] = (distance[i] * distance[i]) / abSquared;
	            }
	            if (distance[i] < 0.0) {
	                distance[i] = -((distance[i] * distance[i]) / abSquared);
	            }
	        }
            
	       
	        // Find the largest distance
	        var maxDistanceAbove:Number = 0.0;
	        var maxDistanceBelow:Number = 0.0;
	       
            for ( i = 1; i < degree; i++) {
	            if (distance[i] < 0.0) {
	                maxDistanceBelow = Math.min(maxDistanceBelow, distance[i]);
	            }
	            if (distance[i] > 0.0) {
	                maxDistanceAbove = Math.max(maxDistanceAbove, distance[i]);
	            }
	        }
	        
	    
	        // Implicit equation for zero line
	        var a1:Number = 0.0;
	        var b1:Number = 1.0;
	        var c1:Number = 0.0;
	    
	        // Implicit equation for "above" line
	        var a2:Number = a;
	        var b2:Number = b;
	        var c2:Number = c + maxDistanceAbove;
	    
	        var det:Number = a1 * b2 - a2 * b1;
	        var dInv:Number = 1.0/det;
	        
	        var intercept1:Number = (b1 * c2 - b2 * c1) * dInv;
	    
	        //  Implicit equation for "below" line
	        a2 = a;
	        b2 = b;
	        c2 = c + maxDistanceBelow;
	        
	        det = a1 * b2 - a2 * b1;
	        dInv = 1.0/det;
	        
	        var intercept2:Number = (b1 * c2 - b2 * c1) * dInv;
	    
	        // Compute intercepts of bounding box
	        var leftIntercept:Number = Math.min(intercept1, intercept2);
	        var rightIntercept:Number = Math.max(intercept1, intercept2);
	    
	        var error:Number = 0.5 * (rightIntercept-leftIntercept);    
	        
	        return error < EPSILON;
	    }
    
		
		 /**
	     *  ConvertToBezierForm :
	     *      Given a point and a Bezier curve, generate a 5th-degree
	     *      Bezier-format equation whose solution finds the point on the
	     *      curve nearest the user-defined point.
	     */
	    
	    private function convertToBezierForm( pa:Vector2 ):Vector.<Vector2> 
	    {
			var lb:int, ub:int, i:int, j:int, k:int
			var v:Vector2;
	        var c:Vector.<Vector2> = new Vector.<Vector2>();   // v(i) - pa
	        var d:Vector.<Vector2> = new Vector.<Vector2>();    // v(i+1) - v(i)
	        var cdTable:Vector.<Vector.<Number>> = Vector.<Vector.<Number>>([new Vector.<Number>(),new Vector.<Number>(),new Vector.<Number>()])  // Dot product of c, d
	        var w:Vector.<Vector2> = new Vector.<Vector2>(); // Ctl pts of 5th-degree curve
	
	        // Determine the c's -- these are vectors created by subtracting
	        // point pa from each of the control points
	        c.push( p1.getMinus( pa ) );
	        c.push( c1.getMinus( pa ) );
	        c.push( c2.getMinus( pa ) );
	        c.push( p2.getMinus( pa ) );
	        
	        // Determine the d's -- these are vectors created by subtracting
	        // each control point from the next
	        var s:Number = 3;
	        d.push( c1.getMinus( p1 ).newLength( s ) );
	        d.push( c2.getMinus( c1 ).newLength( s ) );
	        d.push( p2.getMinus( c2 ).newLength( s ) );
	        
	        
	        // Create the c,d table -- this is a table of dot products of the
	        // c's and d's                          */
	        for (var row:int = 0; row <= 2; row++) 
	        {
	            for (var column:int = 0; column <= 3; column++) 
	            {
	                cdTable[row][column] = d[row].dot(c[column]);
	            }
	        }
	
	        // Now, apply the z's to the dot products, on the skew diagonal
	        // Also, set up the x-values, making these "points"
	        for ( i = 0; i <= 5; i++) {
	            w[i] = new Vector2( Number(i) / 5, 0 );
	        }
			
	        var n:int = 3;
	        var m:int = 2;
	        for ( k = 0; k <= n + m; k++) 
	        {
	            lb = Math.max(0, k - m);
	            ub = Math.min(k, n);
	            for ( i = lb; i <= ub; i++) 
	            {
	                j = k - i;
	                w[i+j].y += cdTable[j][i] * cubicZ[j][i];
	            }
	        }
	
	        return w;
	    }
		
		/**
		 * Converts a cubic B&eacute;zier to a quadratic one, using the
		 * <a href="http://www.caffeineowl.com/graphics/2d/vectorial/cubic2quad01.html#mid-point-approx">mid-point
		 * approximation</a>
		 * 
		 * Author: Adrian Colomitchi
		 * http://www.caffeineowl.com/graphics/2d/vectorial/index.html
		 */
		public function toBezier2( cloneEndpoints:Boolean = true):Bezier2
		{
			var p0x:Number = ( 3 * c1.x - p1.x)/2.0;
			var p0y:Number = ( 3 * c1.y - p1.y)/2.0;
			
			var p1x:Number = ( 3 * c2.x - p2.x )/2.0;
			var p1y:Number = ( 3 * c2.y - p2.y )/2.0;
			return new Bezier2( cloneEndpoints ? p1.getClone() : p1, new Vector2( (p0x+p1x)/2, (p0y+p1y)/2), cloneEndpoints ? p2.getClone() : p2 )
		}
		
		/**
		 * Subdivides a cubic B&eacute;zier at a given value for the curve's parameter.
		 * The method uses de Casteljau algorithm.
		 * Author: Adrian Colomitchi
		 * http://www.caffeineowl.com/graphics/2d/vectorial/index.html
		 */
		
		public function getSplitAtT( t:Number, clonePoints:Boolean = true ):Vector.<Bezier3>
		{
			var result:Vector.<Bezier3> = new Vector.<Bezier3>();
			if ( t == 0 || t == 1 )
			{
				result.push( clonePoints ? Bezier3(this.clone()) : this );
			}
			if ( t<=0 || t>=1) return result;
			
			var p0x:Number = p1.x + ( t * (c1.x - p1.x ));
			var p0y:Number = p1.y + ( t * (c1.y - p1.y ));
			var p1x:Number = c1.x + ( t * (c2.x - c1.x ));
			var p1y:Number = c1.y + ( t * (c2.y - c1.y ));
			var p2x:Number = c2.x + ( t * (p2.x - c2.x ));
			var p2y:Number = c2.y + ( t * (p2.y - c2.y ));
			
			var p01x:Number = p0x + ( t * (p1x-p0x));
			var p01y:Number = p0y + ( t * (p1y-p0y));
			var p12x:Number = p1x + ( t * (p2x-p1x));
			var p12y:Number = p1y + ( t * (p2y-p1y));
			
			var dpx:Number = p01x+(t*(p12x-p01x));
			var dpy:Number = p01y+(t*(p12y-p01y));
			var t_p:Vector2 = new Vector2( dpx, dpy );
			result.push( new Bezier3( clonePoints ? p1.getClone() : p1, new Vector2( p0x, p0y ), new Vector2( p01x, p01y ), t_p));
			result.push( new Bezier3( clonePoints ? t_p.getClone() : t_p, new Vector2( p12x, p12y ), new Vector2( p2x, p2y ),  clonePoints ? p2.getClone() : p2));
			
			return result;
		}
		
		/**
		 * Subdivides a cubic B&eacute;zier in more than one subdivision points.
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
		public function getSplitsAtTs( t:Vector.<Number>, clonePoints:Boolean = true ):Vector.<Bezier3>
		{
			t.sort( function( a:Number, b:Number ):int{ return ( a < b ? -1 : ( a > b ? 1 : 0))});
			
			var current:Bezier3 = this;
			var last_t:Number = 0;
			var result:Vector.<Bezier3> = new Vector.<Bezier3>();
			for ( var i:int = 0; i < t.length; i++ )
			{
				var parts:Vector.<Bezier3> = current.getSplitAtT( (t[i] - last_t) / ( 1 - last_t ), clonePoints );
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
			return p1+" - " + c1 + " - "+ c2 + " - "+p2;
		}
		
		public function toSVG( absolute:Boolean = true ):String
		{
			if ( absolute )
			{
				return "M "+p1.toSVG()+"C "+c1.toSVG() + c2.toSVG() + p2.toSVG();
			} else {
				return "c "+c1.getMinus( p1 ).toSVG()+ c2.getMinus( p1 ).toSVG()+p2.getMinus( p1 ).toSVG();
			}
		}
	}
}