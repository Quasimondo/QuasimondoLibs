package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class HyperbolicLine
	{
		
		public var A:HyperbolicPoint;
		public var B:HyperbolicPoint;  // this is the line between A and B

  		public var isStraight:Boolean;

  		// if it's a circle, then a center C and radius r are needed

  		public var C:HyperbolicPoint;
  		public var r:Number;

  		// if it's is a straight line, then a point P and a direction D
  		// are needed

		public var P:HyperbolicPoint;
		public var D:HyperbolicPoint;
		
		private var invalid:Boolean = false;


	  	public function HyperbolicLine ( A:HyperbolicPoint, B:HyperbolicPoint) 
	  	{
	    	this.A = A; this.B = B;
	    	// first determine if its a line or a circle
	    	var den:Number = A.x*B.y - B.x*A.y;
	    	isStraight = (Math.abs(den) < 1.0e-14);
	    	
	    	if (isStraight)
	    	{
	      		P = A; // a point on the line}
	      		// find a unit vector D in the direction of the line}
	      		den = Math.sqrt((A.x-B.x)*(A.x-B.x) + (A.y-B.y)*(A.y-B.y)) ;
	      		D = new HyperbolicPoint ((B.x - A.x) / den, (B.y - A.y) / den);
	      		
	      		invalid = isNaN( A.x ) || isNaN( A.y ) || isNaN( D.x ) || isNaN( D.y );
	      
	    	} else { // it's a circle
	      		// find the center of the circle thru these points}
	      		var s1:Number = (1.0 + A.x*A.x + A.y*A.y) / 2.0;
	      		var s2:Number = (1.0 + B.x*B.x + B.y*B.y) / 2.0;
	      		C = new HyperbolicPoint ((s1*B.y - s2*A.y) / den,(A.x*s2 - B.x*s1) / den);
	      		r = Math.sqrt(C.x*C.x+C.y*C.y - 1.0) ;
	      		
	      		invalid = isNaN( A.x ) || isNaN( A.y ) || isNaN( B.x ) || isNaN( B.y )|| isNaN( C.x ) || isNaN( C.y ) || isNaN( r );
	      	} // if/else
	    	
	    	
  		} // Line

  		public function toString():String
  		{
    		return "["+A+","+B+"]";
  		}

		  // Reflect the point R thru the this line to get Q the returned point}
		  public function reflect ( R:HyperbolicPoint):HyperbolicPoint 
		  {
		    var Q:HyperbolicPoint = new HyperbolicPoint();
		    var factor:Number;
		    if (isStraight) 
		    {
		      factor = 2.0 * ((R.x-P.x)*D.x + (R.y-P.y)*D.y) ;
		      Q.x = 2.0 * P.x + factor * D.x - R.x ;
		      Q.y = 2.0 * P.y + factor * D.y - R.y ;
		    } else {  // it's a circle
		      factor = r*r / ((R.x-C.x)*(R.x-C.x) + (R.y-C.y)*(R.y-C.y)) ;
		      Q.x = C.x + factor * (R.x - C.x) ;
		      Q.y = C.y + factor * (R.y - C.y) ;
		    } // if/else
		    return Q;
		  } // reflect
		  

		  // append screen coordinates to the list in order to draw the line
		  public function draw( g:Graphics, viewport:Rectangle, moveToFirst:Boolean = true):void
		  {
		  	if ( invalid ) return;
		  	
		  	var x_center:Number = viewport.x + viewport.width * 0.5;
		    var y_center:Number = viewport.y + viewport.height * 0.5;
		    var radius:Number = Math.min(viewport.width * 0.5, viewport.height * 0.5);
		   
		    
		    if (isStraight) 
		    { // go directly to terminal point B
		    	if ( moveToFirst) g.moveTo(A.x*radius+x_center,A.y*radius+y_center);
		    	g.lineTo(B.x*radius+x_center,B.y*radius+y_center);
		   	} else { // its an arc of a circle
		   	
		   		//var arc:Arc = new Arc( C.toVector2().multiply(radius).plusXY(x_center,y_center), A.toVector2().multiply(radius).plusXY(x_center,y_center), B.toVector2().multiply(radius).plusXY(x_center,y_center) );
		   	
			  // determine starting and ending angles
			  
			  
			  var alpha:Number = Math.atan2((A.y-C.y),(A.x-C.x));
			  var beta:Number  = Math.atan2((B.y-C.y),(B.x-C.x));
			  
			  if (Math.abs(beta-alpha) > Math.PI)
			  {
			  	
			    if (beta < alpha)
				  beta  += 2.0*Math.PI;
				else
				  alpha += 2.0*Math.PI;
				  
			  }
			  
			  var arc:Arc = new Arc( C.toVector2().multiply(radius).plusXY(x_center,y_center), r*radius, alpha,beta );
			  
			  if ( moveToFirst )
			  {
			 	arc.draw( g );
			  } else {
			  	arc.drawTo(g);
			  }
		    }
		  } 
		  
		  
		  public function toMixedPath( viewport:Rectangle, addFirst:Boolean = true):MixedPath
		  {
		  	var mp:MixedPath;
		  	if ( invalid ) return new MixedPath();
		  	
		  	var x_center:Number = viewport.x + viewport.width * 0.5;
		    var y_center:Number = viewport.y + viewport.height * 0.5;
		    var radius:Number = Math.min(viewport.width * 0.5, viewport.height * 0.5);
		   
		    
		    if (isStraight) 
		    { // go directly to terminal point B
		     	mp = new MixedPath();
		    	if ( addFirst) mp.addPoint( new Vector2(A.x*radius+x_center,A.y*radius+y_center));
		    	mp.addPoint( new Vector2(B.x*radius+x_center,B.y*radius+y_center));
		   	} else { // its an arc of a circle
		   	
		   		// determine starting and ending angles
			  var alpha:Number = Math.atan2((A.y-C.y),(A.x-C.x));
			  var beta:Number  = Math.atan2((B.y-C.y),(B.x-C.x));
			  
			  if (Math.abs(beta-alpha) > Math.PI)
			  {
			  	if (beta < alpha)
				  beta  += 2.0*Math.PI;
				else
				  alpha += 2.0*Math.PI;
			   }
			  
			  var arc:Arc = new Arc( C.toVector2().multiply(radius).plusXY(x_center,y_center), r*radius, alpha,beta );
			  mp = arc.toMixedPathQuadratic( addFirst );
			}
			return mp;
		  } 
		
	}
}