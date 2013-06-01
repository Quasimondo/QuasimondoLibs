package com.quasimondo.geom
{
	import com.quasimondo.geom.Circle;
	import com.quasimondo.geom.Vector2;
	import com.signalsondisplay.datastructs.graphs.Graph;
	import com.signalsondisplay.datastructs.graphs.Vertex;
	
	import flash.utils.Dictionary;

	public class DoyleGraph
	{
		private var g:Graph;
		private var circles:Dictionary;
		private var nextID:int;
		public var a:Number;
		public var b:Number;
		
		
		public function DoyleGraph()
		{
			g = new Graph();
			circles = new Dictionary();
			nextID = 0;
		}
		
		public function addFlower( flower:DoyleFlower ):void
		{
			a = flower.a;
			b = flower.b;
			
			flower.centerCircle = addCircle( flower.centerCircle ).circle;
			/*
			if( circles[flower.centerCircle] == null )
			{
				circles[flower.centerCircle] = new DoyleVertex(nextID++,flower.centerCircle);
				g.addVertex( circles[flower.centerCircle] );
			}
			*/
			for ( var i:int = 0; i < flower.circles.length; i++ )
			{
				flower.circles[i] = addCircle( flower.circles[i] ).circle;
				/*
				if ( circles[circle] == null )
				{
					circles[circle] = new DoyleVertex(nextID++,circle);
					g.addVertex(circles[circle]);
				}
				*/
			}
			
			for ( var i:int = 0; i < 6; i++ )
			{
				if ( !g.hasEdge(circles[flower.centerCircle],circles[flower.circles[i]]) )
					g.addEdge( circles[flower.centerCircle],circles[flower.circles[i]]);
				
				if ( !g.hasEdge(circles[flower.circles[i]], circles[flower.centerCircle]))
					g.addEdge( circles[flower.circles[i]], circles[flower.centerCircle]);
					
				if ( !g.hasEdge(circles[flower.circles[i]], circles[flower.circles[(i+1)%6]]))
					g.addEdge( circles[flower.circles[i]],circles[flower.circles[(i+1)%6]]);
				
				if ( !g.hasEdge(circles[flower.circles[(i+1)%6]],circles[flower.circles[i]]))
					g.addEdge( circles[flower.circles[(i+1)%6]], circles[flower.circles[i]]);
			}
		}
		
		public function addCircle( circle:Circle ):DoyleVertex
		{
			if( circles[circle] != null ) return circles[circle];
			
			for ( var i:int = 0; i < g.vertices.length; i++ )
			{
				if ( DoyleVertex( g.vertices[i] ).circle.snaps( circle ) )
				{
					return DoyleVertex( g.vertices[i] );
				}
			}
			
			circles[circle] = new DoyleVertex(nextID++,circle);
			g.addVertex( circles[circle] );
			return circles[circle];
		}
		
		public function getIncompleteFlower():DoyleFlower
		{
			var centerVertex:DoyleVertex;
			for ( var i:int = 0; i < g.vertices.length; i++ )
			{
				if ( g.vertices[i].edgeCount < 6 )
				{
					centerVertex = DoyleVertex(g.vertices[i] );
					break;
				}
			}
			var flower:DoyleFlower;
			if ( centerVertex != null )
			{
				flower = new DoyleFlower( centerVertex.circle, a, b );
				for ( i = 0; i < centerVertex.edgeCount; i++ )
				{
					flower.fixedCircles.push(DoyleVertex(centerVertex.edges[i].dest).circle);
				}
			}
			return flower;
		}
		
		public function getClosestVertexIndex( p:Vector2 ):int
		{
			var centerVertex:DoyleVertex;
			var closestIndex:int = -1;
			var closestdist:Number;
			var dist:Number;
			for ( var i:int = 0; i < g.vertices.length; i++ )
			{
				dist = p.squaredDistanceToVector( DoyleVertex(g.vertices[i] ).circle.c );
				if ( closestIndex == -1 ) 
				{
					closestIndex = i;
					closestdist =dist;
				} else if ( dist < closestdist ) 
				{
					closestIndex = i;
					closestdist = dist;
				}
			}
			return closestIndex;
		}
		
		public function getFlowerAt( p:Vector2 ):DoyleFlower
		{
			var index:int = getClosestVertexIndex( p );
			if (index == -1) return null;
			return getFlowerAtIndex( index );
		}
		
		public function getFlowerAtIndex( index:int ):DoyleFlower
		{
			if (index < 0 || index >= g.vertices.length) return null;
			var centerVertex:DoyleVertex = DoyleVertex(g.vertices[index]);
			
			var flower:DoyleFlower;
			if ( centerVertex != null )
			{
				flower = new DoyleFlower( centerVertex.circle, a, b );
				for ( var i:int = 0; i < centerVertex.edgeCount; i++ )
				{
					flower.fixedCircles.push(DoyleVertex(centerVertex.edges[i].dest).circle);
				}
			}
			return flower;
		}
		
		
		public function getCircles():Vector.<Circle>
		{
			var result:Vector.<Circle> = new Vector.<Circle>();
			for ( var i:int = 0; i < g.vertices.length; i++ )
			{
				result.push( DoyleVertex(g.vertices[i]).circle );
			}
			return result;
		}
		
		public function getEdges():Vector.<LineSegment>
		{
			var edgeMap:Object = {}
			var result:Vector.<LineSegment> = new Vector.<LineSegment>();
			for ( var i:int = 0; i < g.vertices.length; i++ )
			{
				var ifrom:int = g.vertices[i].index;
				for ( var j:int = 0; j < g.vertices[i].edges.length; j++ )
				{
					var ito:int =  g.vertices[i].edges[j].dest.index;
					if ( edgeMap[ifrom+"_"+ito]==null && edgeMap[ito+"_"+ifrom]==null)
					{
						edgeMap[ifrom+"_"+ito]= edgeMap[ito+"_"+ifrom] = true;
						result.push( new LineSegment( DoyleVertex(g.vertices[i]).circle.c,DoyleVertex(g.vertices[i].edges[j].dest).circle.c ));
					}
				}
			}
			return result;
		}
		
		public function getTriples():Vector.<Vector.<DoyleVertex>>
		{
			var edgeMap:Object = {}
			var result:Vector.<Vector.<DoyleVertex>> = new Vector.<Vector.<DoyleVertex>>();
			for ( var i:int = 0; i < g.vertices.length; i++ )
			{
				var first:DoyleVertex = DoyleVertex(g.vertices[i]);
				for ( var j:int = 0; j < first.edges.length; j++ )
				{
					var second:DoyleVertex = DoyleVertex(first.edges[j].dest);
					for ( var k:int = 0; k < second.edges.length; k++ )
					{
						var third:DoyleVertex =  DoyleVertex(second.edges[k].dest);
						for ( var l:int = 0; l < third.edges.length; l++ )
						{
							if ( third.edges[l].dest == first )
							{
								var ids:Array = [first.index, second.index, third.index];
								ids.sort(Array.NUMERIC);
								var id:String = ids.join("_");
								if (edgeMap[id] == null )
								{
									edgeMap[id] = true;
									result.push( new <DoyleVertex>[first,second,third] );
									
									break;
								}
							}
						}
					}
					
					
				}
			}
			return result;
		}
	}
		
}