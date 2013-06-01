package com.quasimondo.geom
{
	import __AS3__.vec.Vector;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	/*----------------------------------------------------------------------+
	|   Title:  PoincareDisk.java                                           |
	|                                                                       |
	|   Author: David E. Joyce                                              |
	|           Department of Mathematics and Computer Science              |
	|           Clark University                                            |
	|           Worcester, MA 01610-1477                                    |
	|           U.S.A.                                                      |                                                                       |
	|           http://aleph0.clarku.edu/~djoyce/                           |
	|                                                                       |
	|   Date:   April, 1987.  Pascal version for tektronix terminal         |
	|           December, 2002.  Java applet version                        |
	+----------------------------------------------------------------------*/
	
	public class PoincareDisk
	{


 	 	private var par:HyperbolicTilingParameters;// parameters
  		private var alternating:Boolean;

  		private var P:Vector.<HyperbolicPolygon>;  // the list of polygons
  		private var rule:Vector.<int>;			   // previously created neighbors for the polygons
  		private var totalPolygons:int; // the total number of polygons in all the layers
  		private var innerPolygons:int; // the number through one less layer
  	 	private var C:Vector.<int>; // this list of colors for the polygons

  		public function PoincareDisk( par:HyperbolicTilingParameters ) 
  		{
  			par.checkPars();
    		this.par = par;
  		} // Poincare constructor

  		public function calculate():void
  		{
    		alternating = par.alternating && (par.k%2 == 0);
    		countPolygons(par.layers) ;
    		determinePolygons();
  		} // init

  		private function countPolygons( layer:int ):void 
  		{
    		// Determine
    		//   totalPolygons:  the number of polygons there are through that many layers
    		//   innerPolygons:  the number through one less layer
		    totalPolygons = 1;    // count the central polygon
		    innerPolygons = 0;
		    var a:int = par.n * ( par.k - 3 ) ;  // polygons in first layer joined by a vertex
		    var b:int = par.n ;        // polygons in first layer joined by an edge
		    var next_a:int, next_b:int, l:int;
		    if ( par.k == 3) 
		    {
		      for ( l = 1; l <= layer; ++l) 
		      {
		        innerPolygons = totalPolygons;
		        next_a = a + b;
		        next_b = ( par.n - 6 ) * a + ( par.n - 5 ) * b;
		        totalPolygons += a + b;
		        a = next_a;
		        b = next_b;
		      } // for
		    } else { // k >= 4
		      for ( l = 1; l <= layer; ++l) 
		      {
		        innerPolygons = totalPolygons;
		        next_a = ((par.n-2)*(par.k-3) - 1) * a
		               + ((par.n-3)*(par.k-3) - 1) * b;
		        next_b = (par.n-2)*a + (par.n-3)*b;
		        totalPolygons +=  a + b;
		        a = next_a;
		        b = next_b;
		      } // for
		    } // if/else
		  } // countPolygons

		 /* rule codes
		  *   0:  initial polygon.  Needs neighbors on all n sides
		  *   1:  polygon already has 2 neighbors, but one less around corner needed
		  *   2:  polygon already has 2 neighbors
		  *   3:  polygon already has 3 neighbors
		  *   4:  polygon already has 4 neighbors
		  */

		  private function determinePolygons():void 
		  {
		    P = new Vector.<HyperbolicPolygon>(totalPolygons);
		    rule = new Vector.<int>(totalPolygons);
		    C = new  Vector.<int>(totalPolygons);
		    P[0] = HyperbolicPolygon.constructCenterPolygon( par.n, par.k, par.quasiregular, par.angle );
		    rule[0] = 0;
		    C[0] = randomColor();
		    var j:int = 1; // index of the next polygon to create
		    for (var i:int=0; i<innerPolygons; ++i)
		      j = applyRule(i,j);
		  } // determinePolygons

		  private function applyRule( i:int, j:int ):int 
		  {
		    var r:int = rule[i];
		    var special:Boolean = (r==1);
		    if (special) r=2;
		    var start:int = (r==4)? 3 : 2;
		    var quantity:int = (par.k==3 && r!=0)? par.n-r-1 : par.n-r;
		    for (var s:int = start; s<start+quantity; ++s) 
		    {
		      // Create a polygon adjacent to P[i]
		      P[j] = createNextPolygon(P[i],s%par.n);
		      rule[j] = (par.k==3 && s==start && r!=0)? 4 : 3;
		      if (alternating && j>1)
		        C[j] = (C[i] == C[0])? C[1] : C[0];
		      else
		        C[j] = randomColor();
		      j++;
		      var m:int;
		      if (special) m=2;
		      else if (s==2 && r!=0) m=1;
		      else m=0;
		      for ( ; m<par.k-3; ++m) {
		        // Create a polygon adjacent to P[j-1]
		        P[j] = createNextPolygon(P[j-1],1);
		        rule[j] = (par.n==3 && m==par.k-4)? 1 : 2;
		        if (alternating)
		          C[j] = (C[j-1] == C[0])? C[1] : C[0];
		        else
		          C[j] = randomColor();
		        j++;
		      } // for m
		    } // for r
		    return j;
		  } // applyRule
  

		  // reflect P thru the point or the side indicated by the side s
		  //  to produce the resulting polygon Q
		  private function createNextPolygon ( hp:HyperbolicPolygon, s:int ):HyperbolicPolygon
		  {
		  	var i:int, j:int;
		  	var Q:HyperbolicPolygon = new HyperbolicPolygon( par.n );
		    if (par.quasiregular) 
		    {
		      var V:HyperbolicPoint = hp.getVertex(s);
		      for ( i=0; i<par.n; ++i) 
		      { // reflect P[i] thru P[s] to get Q[j]
		        j = (par.n+i-s) % par.n;
		        Q.setVertex(j, V.reflect(hp.getVertex(i)));
		      } 
		    } else { // regular
		      var C:HyperbolicLine = new HyperbolicLine( hp.getVertex(s), hp.getVertex((s+1)%par.n)) ;
		      for ( i=0; i<par.n; ++i) { // reflect P[i] thru C to get Q[j]}
		        j = (par.n+s-i+1) % par.n;
		        Q.setVertex(j, C.reflect(hp.getVertex(i)));
		      } // for
		    } // if/else
		    return Q;
		  } // computeNextPolygon

		  private function randomColor():int 
		  {
		    var c:uint;
		    if (par.grayScale)
		    {
		    	var g:int = 0x100 * Math.random();
		    	c = (g << 16) | (g << 8) | g;
		    } else {
		    	c = 0xffffff * Math.random();
		    }
		    return c;
		  }
  
		  private function gcd( m:int, n:int ):int
		  {  // greatest common divisor
		    	var temp:int
		    	if (m < 0) m = -m;   // Make sure m and n
		    	if (n < 0) n = -n ;  // are nonnegative.
				if (m > n) {         // Make sure m <= n. }
				  temp = n;
				  n = m;
				  m = temp;
				} // if
				while (m != 0) {
				 	temp = n;
				  n = m;
				  m = temp % m;
				} // while
				return n;
		  } // gcd

		  public function draw ( g:Graphics, viewport:Rectangle ):void
		  {
		    var x_center:Number = viewport.x + viewport.width * 0.5;
		    var y_center:Number = viewport.y + viewport.height * 0.5;
		    var radius:Number = Math.min(viewport.width * 0.5, viewport.height * 0.5);
		    var diameter:Number = 2 * radius;
		    
		    g.beginFill( par.bgColor );
		    g.drawRect(viewport.x,viewport.y,viewport.width,viewport.height);
		    g.endFill();
		    g.beginFill( par.diskColor );
		    g.drawCircle( x_center,y_center,radius);
		    g.endFill();
		    
		    var stars:int = gcd(par.skipNumber,par.n);
		    var pointsPerStar:int = par.n / stars;
		    var q:HyperbolicPolygon;
		    
		    for (var i:int=0; i<totalPolygons; ++i) 
		    {
		     	for (var s:int=0; s<stars; ++s) 
		        {
		          q = new HyperbolicPolygon(pointsPerStar);
		          for (var j:int=0; j<pointsPerStar; ++j)
		            q.setVertex(j, P[i].getVertex( j * par.skipNumber % par.n + s ));
		          
		          if (par.outline) g.lineStyle( 0, par.strokeColor );
		          
		       	  if (par.fill) g.beginFill(C[i]);
		          q.draw(g,viewport);  
		          if (par.fill)  g.endFill();      
		        } // for s
		     
		    } // for i
		  } // draw
		  
		  public function getPaths( viewport:Rectangle ):Vector.<MixedPath>
		  {
		  	 var result:Vector.<MixedPath> = new Vector.<MixedPath>();
		  	 
		  	var stars:int = gcd(par.skipNumber,par.n);
		    var pointsPerStar:int = par.n / stars;
		    var q:HyperbolicPolygon;
		    
		    for (var i:int=0; i<totalPolygons; ++i) 
		    {
		     	for (var s:int=0; s<stars; ++s) 
		        {
		          q = new HyperbolicPolygon(pointsPerStar);
		          for (var j:int=0; j<pointsPerStar; ++j)
		            q.setVertex(j, P[i].getVertex( j * par.skipNumber % par.n + s ));
		          
		          result.push( q.toPath( viewport ) );
		        } 
		    } 
		    return result;
		  }
	}
}