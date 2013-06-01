package com.quasimondo.delaunay
{
	
	import com.quasimondo.geom.ConvexPolygon;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.Graphics;
	
	public class DelaunayTriangle
	{
		public var edge:DelaunayEdge;
		public var next:DelaunayTriangle;
		
		public var c_cx:Number;        // center of circle: X
 		public var c_cy:Number;        // center of circle: Y
 		private var c_r:Number;         // radius of circle
  		private var c_r2:Number;         // squared radius of circle
  		
  		private var x1:Number;
		private var y1:Number;
		private var x2:Number;
		private var y2:Number;
		private var x3:Number;
		private var y3:Number;
		private var a:Number;
		private var a1:Number;
		private var a2:Number;
		
		private var dx:Number;
		private var dy:Number;
		
  		
  		public function DelaunayTriangle( e1:DelaunayEdge, e2:DelaunayEdge, e3:DelaunayEdge, edges:DelaunayEdges = null )
		{
		    update(e1,e2,e3,edges);
		}
		
		public function reset():void
		{
			edge = null;
			next = null;
		}
		
		public function update( e1:DelaunayEdge, e2:DelaunayEdge, e3:DelaunayEdge, edges:DelaunayEdges = null):void
		{
		    edge = e1;
		    e1.nextE = e2;
		    e2.nextE = e3;
		    e3.nextE = e1;
		    e1.inT = this;
		    e2.inT = this;
		    e3.inT = this;
		    
		    findCircle();
		    
		    if (edges != null )
		    {
		    	edges.addElement(e1);
		    	edges.addElement(e2);
		    	edges.addElement(e3);
		    }
		  }
		  
		  public function inCircle( nd:DelaunayNode ):Boolean 
		  { 
		  	dx = c_cx - nd.x;
		    dy = c_cy - nd.y;
		    return dx*dx+dy*dy < c_r2;
		  }
		  
		  public function getNeighborTriangles():Vector.<DelaunayTriangle>
		  {
			 var result:Vector.<DelaunayTriangle> = new Vector.<DelaunayTriangle>()
			 if ( edge.invE &&  edge.invE.inT ) result.push( edge.invE.inT );
			 if ( edge.nextE.invE &&  edge.nextE.invE.inT ) result.push( edge.nextE.invE.inT );
			 if ( edge.nextE.nextE.invE && edge.nextE.nextE.invE.inT ) result.push( edge.nextE.nextE.invE.inT );
			 return result;
		  }
		  
		  public function getNodes():Vector.<DelaunayNode>
		  {
			 var result:Vector.<DelaunayNode> = new Vector.<DelaunayNode>();
			 result.push(edge.p1);
			 result.push(edge.nextE.p2);
			 result.push(edge.p2);
			 return result;
		  }
		  
		  public function removeEdges( edges:DelaunayEdges ):void
		  {
		    edges.removeElement(edge);
		    edges.removeElement(edge.nextE);
		    edges.removeElement(edge.nextE.nextE);
		  }
		  
		  private function findCircle():void
		  {
		    x1 = edge.p1.x;
		    y1 = edge.p1.y;
		    x2 = edge.p2.x;
		    y2 = edge.p2.y;
		    x3 = edge.nextE.p2.x;
		    y3 = edge.nextE.p2.y;
		    a = (y2-y3)*(x2-x1)-(y2-y1)*(x2-x3);
		    if ( a != 0 )
		    {
		    	a1 = (x1+x2)*(x2-x1)+(y2-y1)*(y1+y2);
		    	a2 = (x2+x3)*(x2-x3)+(y2-y3)*(y2+y3);
		   	 	c_cx = (a1*(y2-y3)-a2*(y2-y1))/a*0.5;
		   	 	c_cy = (a2*(x2-x1)-a1*(x2-x3))/a*0.5;
		   	} else {
		   		c_cx = x1;
		   		c_cy = y1;
		   	}
		    c_r2 = edge.p1.squaredDistance(c_cx,c_cy);
		    c_r = -1;
		  }
		  
		  public function drawCircle( g:Graphics ):void
		  {
		  	if (c_r == -1) c_r = Math.sqrt(c_r2);
		    g.drawCircle( c_cx-c_r, c_cy-c_r, 2.0*c_r );
		  }
		  
		  public function drawVertex( g:Graphics, ignoreOuterTriangle:Boolean = true ):void
		  {
			  	if ( !ignoreOuterTriangle || (!(edge.p2.data is BoundingTriangleNodeProperties) && !(edge.p1.data is BoundingTriangleNodeProperties) && !(edge.nextE.p2.data is BoundingTriangleNodeProperties)))
				{
					g.moveTo( edge.p1.x,edge.p1.y );
					g.lineTo( edge.nextE.p2.x,edge.nextE.p2.y);
					g.lineTo( edge.p2.x, edge.p2.y);
					g.lineTo( edge.p1.x,edge.p1.y);
				}
		  }
		  
		  public function toTriangle( ):Triangle
		  {
			  return new Triangle( new Vector2( edge.p1.x,edge.p1.y ), new Vector2( edge.nextE.p2.x,edge.nextE.p2.y ), new Vector2( edge.p2.x, edge.p2.y) );
		  }
		  
		  public function toConvexPolygon():ConvexPolygon
		  {
		  	return ConvexPolygon.fromArray( [new Vector2( edge.p1.x,edge.p1.y ), new Vector2( edge.nextE.p2.x,edge.nextE.p2.y ), new Vector2( edge.p2.x, edge.p2.y)] );
		  }
	}
}
 

  