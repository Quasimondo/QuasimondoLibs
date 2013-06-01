package com.quasimondo.delaunay
{
	import com.quasimondo.geom.LineSegment;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.Graphics;
	
	public class DelaunayEdge
	{
		public var p1:DelaunayNode; // start point of the edge
		public var p2:DelaunayNode; // end point of the edge
		public var invE:DelaunayEdge;     // inverse edge (p2->p1)
		public var nextE:DelaunayEdge;    // next edge in the triangle in countclickwise
		public var nextH:DelaunayEdge;    // convex hull link
		public var inT:DelaunayTriangle;      // triangle containing this edge
		public var flip:int=0;
		
		public var next:DelaunayEdge;
		
		private var a:Number;
		private var b:Number;
		private var c:Number;  // line equation parameters. aX+bY+c=0
		
		private var s:Number;
		
  		
		public function DelaunayEdge( $p1:DelaunayNode, $p2:DelaunayNode ):void
		{
			update( $p1, $p2 ); 
		}
		
		public function update( $p1:DelaunayNode, $p2:DelaunayNode ):void
		{ 
			//if (p1 == $p1 && p2 == $p2) return;
			p1 = $p1;
			p2 = $p2;
			
			a = p2.y - p1.y; 
			b = p1.x - p2.x; 
			c = p2.x * p1.y - p1.x * p2.y; 
			
			p1.edge = this;
		}
		
		public function reset():void
		{
			p1 = null;
			p2 = null;
			invE = null; 
			nextE = null;
			nextH = null;
			inT = null;
			next = null;
			flip = 0;
		}
		
		public function makeSymm():DelaunayEdge 
		{ 
			var e:DelaunayEdge = DelaunayEdges.getEdge(p2,p1); 
			invE = e; 
 			e.invE = this; 
			
			return e; 
		}
		
		public function getVoronoiLine():LineSegment
		{
			var ee:DelaunayEdge = invE;
		    if( ee == null || ee.inT==null)
		    {
			  var v1:Vector2 = new Vector2( inT.c_cx, inT.c_cy );
			  var v2:Vector2 = new Vector2( - p2.y + p1.y, - p1.x + p2.x ).newLength(1000).plus(v1);
				  
		      return new LineSegment( v1, v2 );
		    } 
		    
		    return LineSegment.fromXY( inT.c_cx,inT.c_cy,ee.inT.c_cx,ee.inT.c_cy);
		}
		
 		public function linkSymm( $e:DelaunayEdge ):void 
 		{ 
 			invE = $e; 
 			if( $e != null ) $e.invE = this; 
 		}
 		
  		public function onSide( nd:DelaunayNode ):int
  		{ 
  		  s = a * nd.x + b * nd.y + c;
  		  //return ( s > 0 ? 1 : ( s < 0 ? -1 : 0 ) );
  		  return ( s > 0.00000001 ? 1 : ( s < -0.00000001 ? -1 : 0 ) );
  		}
		
		public function setabc():void
		{ 
			a = p2.y - p1.y; 
			b = p1.x - p2.x; 
			c = p2.x * p1.y - p1.x * p2.y; 
		}
		
		public function asIndex():void  { 
			p1.edge = this;
		}
		
		
   		public function get mostLeft():DelaunayEdge
  		{ 
			var e:DelaunayEdge = this;
			var ee:DelaunayEdge;
  			while( ( ee = e.nextE.nextE.invE ) != null && ee !== this ) e = ee;
    		return e.nextE.nextE;
  		}
  
  		public function get mostRight():DelaunayEdge
 		{ 
 			var e:DelaunayEdge = this;
			var ee:DelaunayEdge;
    		while( e.invE!=null && (ee=e.invE.nextE) !== this) e = ee;
    		return e;
  		}
  		
   		public function setFlip( f:int):void
   		{
    		flip = f%6;
  		}

		public function get nodeDistance():Number
   		{
    		return p1.distance(p2.x,p2.y);
  		}
	
		public function toLine():LineSegment
		{
			return new LineSegment( p1.x,p1.y,p2.x,p2.y);
		}
		
		public function draw( g:Graphics):void
		{ 
			g.moveTo(p1.x,p1.y);
			g.lineTo(p2.x,p2.y); 
		}
		
	}
}