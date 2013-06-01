package com.quasimondo.geom
{
	import __AS3__.vec.Vector;
	
	import com.quasimondo.geom.HyperbolicLine;
	import com.quasimondo.geom.HyperbolicPoint;
	import com.quasimondo.geom.MixedPath;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class HyperbolicPolygon
	{
		private var n:int;  // the number of sides
		public var pts:Vector.<HyperbolicPoint>; // the list of vertices
		
		public function HyperbolicPolygon( n:int = 0 ) 
		{
		    this.n = n;
		    pts = new Vector.<HyperbolicPoint>(n);
		}
		
		public function getVertex( i:int ):HyperbolicPoint 
		{ return pts[i]; }
		
		public function setVertex( i:int, P:HyperbolicPoint ):void { 
			pts[i] = P; 
		}
		
	  	public function toString():String 
		{
		    var S:String = "[";
		    for (var i:int=0; i<n; ++i) {
		      S += pts[i];
		      if (i < n-1)
		        S += ",";
		    } // for
		    S += "]";
		    return S;
		 } // toString
		
		  public static function constructCenterPolygon( n:int, k:int, quasiregular:Boolean, angle:Number = 0 ):HyperbolicPolygon 
		  {
		    // Initialize P as the center polygon in an n-k regular or quasiregular tiling.
		    // Let ABC be a triangle in a regular (n,k0-tiling, where
		    //    A is the center of an n-gon (also center of the disk),
		    //    B is a vertex of the n-gon, and
		    //    C is the midpoint of a side of the n-gon adjacent to B.
		    var angleA:Number = Math.PI/n;
		    var angleB:Number = Math.PI/k;
		    var angleC:Number = Math.PI/2.0;
		    // For a regular tiling, we need to compute the distance s from A to B.
		    var sinA:Number = Math.sin(angleA);
		    var sinB:Number = Math.sin(angleB);
		    var s:Number = Math.sin(angleC - angleB - angleA)
		             / Math.sqrt(1.0 - sinB*sinB - sinA*sinA);
		      
		   
		    // But for a quasiregular tiling, we need the distance s from A to C.
		    if (quasiregular) 
		    {
		      s = (s*s + 1.0) /  (2.0*s*Math.cos(angleA));
		      s = s - Math.sqrt(s*s - 1.0);
		    }
		    // Now determine the coordinates of the n vertices of the n-gon.
		    // They're all at distance s from the center of the Poincare disk.
		    var P:HyperbolicPolygon = new HyperbolicPolygon(n);
		    for (var i:int=0; i<n; ++i)
		      P.pts[i] = new HyperbolicPoint( s * Math.cos(angle + (3+2*i)*angleA),
		                         		    s * Math.sin(angle + (3+2*i)*angleA));
		    return P;
		  } // constructCenterPolygon
		
		  public function draw( g:Graphics, viewport:Rectangle ):void 
		  {
		  	for (var i:int = 0; i<n; ++i )
		  	{
		  		new HyperbolicLine( pts[i], pts[(i+1)%n]).draw( g, viewport, i==0 );
		  	}
		  } // draw
		  
		  public function toPath( viewport:Rectangle ):MixedPath
		  {
		  		var path:MixedPath = new MixedPath();
		  		var l:HyperbolicLine;
		  		for (var i:int = 0; i<n; ++i )
		  		{
		  			l = new HyperbolicLine( pts[i], pts[(i+1)%n]);
		  			path.appendPath( l.toMixedPath(  viewport, i == 0 ));
		  		}
		  		path.setClosed( true );
		  		return path;
		  }
	}
}