package com.quasimondo.delaunay
{
	import com.quasimondo.geom.LineSegment;
	
	import flash.display.Graphics;
	
	public class DelaunayEdges {
		
		private var first:DelaunayEdge;
		public var size:int = 0;
		private var marker1:int = 0;
		
		private var ep1:DelaunayNode;
		private var ep2:DelaunayNode;
		
		private static var depot:Vector.<DelaunayEdge> = new Vector.<DelaunayEdge>();
		private static const retries:int = 3;
		
		public static function getEdge( $p1:DelaunayNode, $p2:DelaunayNode ):DelaunayEdge
		{
			var edge:DelaunayEdge;
			if ( depot.length>0){
				edge = depot.pop();
				edge.update( $p1,$p2 );
			} else {
				edge = new DelaunayEdge( $p1,$p2 );
			}
			return edge;
		}
		
		public static function deleteEdge( edge:DelaunayEdge ):void
		{
			edge.reset();
			depot.push(edge);
		}
		
		public function DelaunayEdges()
		{
		}

		public function addElement( e:DelaunayEdge ):void
		{
			e.next = first;
			first = e;
			size++;
		}
	
		public function elementAt( index:int ):DelaunayEdge
		{
			var eg:DelaunayEdge = first;
			while ( index-- > 0 && eg )
			{ 
				eg = eg.next 
			}
			return eg;
		}
		
		public function removeFirstElement():DelaunayEdge
		{
			var eg:DelaunayEdge;
			if (first!=null)
			{
				size--;
				eg = first;
				first = first.next;
				eg.next = null;
			}
			return eg;
		}
		
		public function deleteElement( e:DelaunayEdge ):void
		{
			var eg:DelaunayEdge;
			var teg:DelaunayEdge;
			
			if ( first === e )
			{
				size--;
				eg = first;
				first = first.next;
				deleteEdge(eg);
				return;
			}
			eg = first;
			while ( eg!=null )
			{
				if ( eg.next === e )
				{
					size--;
					teg = eg.next
					eg.next = eg.next.next;
					deleteEdge(teg);
					return;
				}
				eg = eg.next;
			}
		}
		
		public function removeElement( e:DelaunayEdge ):void
		{
			var eg:DelaunayEdge;
			var teg:DelaunayEdge;
			if ( first === e )
			{
				size--;
				eg = first;
				first = first.next;
				eg.next = null;
				return;
			}
			eg = first;
			while ( eg!=null )
			{
				if ( eg.next === e )
				{
					size--;
					teg = eg.next ;
					eg.next = eg.next.next;
					teg.next = null;
					return;
				}
				eg = eg.next;
			}
		}
		
		public function removeAllElements():void
		{
			while ( first != null )
		 	{
		 		deleteEdge(removeFirstElement());
		 	}
		}
		
		public function draw( g:Graphics ):void
		{
			var eg:DelaunayEdge = first;
			while ( eg!=null )
			{
				eg.draw(g);
				eg = eg.next;
			}
		}
		
		public function apply( f:Function ):void
		{
			var eg:DelaunayEdge = first;
			while ( eg!=null )
			{
				f(eg);
				eg = eg.next;
			}
		}
		
		public function buildVoronoiRegions( regions:VoronoiRegions ):void
		{
			var eg:DelaunayEdge = first;
			while ( eg!=null )
			{
				regions.addEdge( eg );
				eg = eg.next;
			}
		}
		
		public function drawVoronoi( g:Graphics ):void
		{
		    var e:DelaunayEdge = first;
		    var line:LineSegment;
		    while ( e!=null )
			{
			  line = e.getVoronoiLine();
			  line.clip( -4000,4000,-4000,4000);
			  line.draw( g );
			  e = e.next;
		    }
		 }
		
		public function getVoronoiLines():Vector.<LineSegment>
		{
			var result:Vector.<LineSegment> = new Vector.<LineSegment>();
			var e:DelaunayEdge = first;
			var line:LineSegment;
			while ( e!=null )
			{
				
				result.push( e.getVoronoiLine() );
				e = e.next;
			}
			return result;
		}
		 
		 
		public function animate():void
		{
		    var dx:Number, dy:Number, rr:Number, d:Number, dd:Number;
			
			var ep1d:DelaunayNodeProperties
			var ep2d:DelaunayNodeProperties;
			var tries:int = 0;
			var collision:Boolean;
			var eg:DelaunayEdge;
			do {
				collision = false
				eg = first;
		   		while ( eg!=null )
				{
					ep1 = eg.p1;
					ep2 = eg.p2;
					ep1d = ep1.data;
					ep2d = ep2.data;
					if ( ep1d == null || ep2d == null ) {
						eg = eg.next;
						continue;
					}
					
					collision = ep1d.solve( ep2d, marker1 );
					eg = eg.next;
		    	}
			} while ( collision && tries++ < retries );
		    marker1++;
		    
		   
		}
		
		public function getEdges( ignoreOuterEdges:Boolean = true ):Vector.<DelaunayEdge>
		{
			var result:Vector.<DelaunayEdge> = new Vector.<DelaunayEdge>();
			var eg:DelaunayEdge = first;
			while ( eg!=null )
			{
				if ( !ignoreOuterEdges || !(eg.p1.data is BoundingTriangleNodeProperties || eg.p2.data is BoundingTriangleNodeProperties ))
					result.push( eg );
				eg = eg.next;
			}
			
			return result;
		}
		
	}		
}