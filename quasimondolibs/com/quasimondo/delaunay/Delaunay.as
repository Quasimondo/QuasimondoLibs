/*
Delaunay Triangulation

based on delaunay.java Code found on Ken Perlin's site:
http://mrl.nyu.edu/~perlin/experiments/incompressible/

original author: Dr. Marcus Apel
http://www.geo.tu-freiberg.de/~apelm/ 

ported and optimized for Actionscript by Mario Klingemann
*/

package com.quasimondo.delaunay
{
	
	
	import com.quasimondo.geom.ConvexPolygon;
	import com.quasimondo.geom.GeometricShape;
	import com.quasimondo.geom.Intersection;
	import com.quasimondo.geom.LineSegment;
	import com.quasimondo.geom.Polygon;
	import com.quasimondo.geom.Triangle;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class Delaunay
	{
		
		public var nodes:DelaunayNodes;  
		public var edges:DelaunayEdges; 
		public var triangles:DelaunayTriangles;   
		
		private var regions:VoronoiRegions;   
		
		private var hullStart:DelaunayEdge;    
		private var actE:DelaunayEdge;
		private var regionsReady:Boolean;
		
		private var min_x:Number;
		private var min_y:Number;
		private var max_x:Number;
		private var max_y:Number;
		private var ill_defined:Boolean;
		
		private var _boundingNodes:Vector.<DelaunayNode>;
		
		private var viewport:Rectangle; 
		
		private var flipCount:int=0;
		
		public function Delaunay( viewport:Rectangle = null)
		{
			triangles = new DelaunayTriangles();
			nodes = new DelaunayNodes();
			edges = new DelaunayEdges();
			regions = new VoronoiRegions();
			_boundingNodes = new Vector.<DelaunayNode>();
			
			regionsReady = false;
			ill_defined = true;
			if ( viewport == null )
			{
				this.viewport = new Rectangle( -20,-20,2000,2000);
			} else {
				this.viewport = viewport;
			}
			regions.viewport = this.viewport;
			
		}
		
		public function createBoundingTriangle( center_x:Number = 0, center_y:Number = 0, radius:Number = 8000, rotation:Number = 0 ):void
		{
			
			for ( var i:int = 0; i < 3; i++ )
			{
				insertXY( center_x + radius * Math.cos( i * 2 * Math.PI / 3 ) , center_y + radius * Math.sin( i * 2 * Math.PI / 3 ), new BoundingTriangleNodeProperties() );
			}
			
		}
		
		public function clear():void
		{
			_boundingNodes.length = 0;
			flipCount=0;
			hullStart = null;
			actE = null;
			nodes.removeAllElements();
			edges.removeAllElements();
			triangles.removeAllElements();
			regions.removeAllElements();
			regionsReady = false;
			ill_defined = true;
			
		}
		
		public function insertXY( px:Number, py:Number, data:DelaunayNodeProperties = null):Boolean
		{
			return insertNode(DelaunayNodes.getNode( px, py, data  ) );
		} 
		
		public function insertVector2( v:Vector2, data:DelaunayNodeProperties = null):Boolean
		{
			return insertNode(DelaunayNodes.getNode( v.x, v.y, data  ) );
		} 
		
		public function insertNode( nd:DelaunayNode ):Boolean
		{
			regionsReady = false;
			
			nodes.addElement(nd);
			
			if (  nodes.size == 1 )
			{
				min_x = max_x = nd.x;
				min_y = max_y = nd.y;
				return false;
			} else if ( ill_defined )
			{
				if ( nd.x < min_x ) min_x = nd.x;
				else if ( nd.x > max_x ) max_x = nd.x;
				
				if ( nd.y < min_y ) min_y = nd.y;
				else if ( nd.y > max_y ) max_y = nd.y;
				
				if (  nodes.size > 2 )
				{
					if ( (min_x != max_x) && (min_y != max_y) )
					{
						if ( makeFirstTriangle( ) )
						{
						
							var insertCount:int = nodes.size - 4;
							var i:int = 0;
							while ( insertCount > -1 )
							{
								insert( nodes.elementAt(insertCount--) );
							}
							
							ill_defined = false;
						}
						
					}
					return false;
					
				} else {
					return false;
				}
			}
			
			return insert( nd );
			
		}
		
		public function canInsert( x:Number, y:Number ):Boolean
		{
			var nd:DelaunayNode = DelaunayNodes.getNode( x, y );
			var eid:int;
			actE = edges.elementAt(0);
			if( actE.onSide(nd) == -1)
			{ 
				if( actE.invE == null ) 
					eid = -1;
				else 
					eid = searchEdge( actE.invE, nd );
			} else {
				eid = searchEdge( actE, nd );
			}
			DelaunayNodes.deleteNode(nd);
			return ( eid != 0 );
		}
		
		private function insert( nd:DelaunayNode ):Boolean
		{
			var eid:int;
			actE = edges.elementAt(0);
			if( actE.onSide(nd) == -1)
			{ 
				if( actE.invE == null ) 
					eid = -1;
				else 
					eid = searchEdge( actE.invE, nd );
			} else {
				eid = searchEdge( actE, nd );
			}
			
			if( eid == 0) 
			{ 
				trace( "could not insert node - eid == 0" );   
				//throw( new Error("could not insert node!"));
				nodes.deleteElement(nd); 
				return false; 
			}
			if( eid > 0 ) 
				expandTri( actE, nd, eid );   // nd is inside or on a triangle
			else 
				if (!expandHull(nd))
				{             
					trace( "could not insert node! expandHull failed" );   
					nodes.deleteElement(nd); 
					return false; 
				} // nd is outside convex hull
			
			if ( nd.data is BoundingTriangleNodeProperties )
			{
				_boundingNodes.push( nd );
			}
			
			return true;
		}
		
		private function makeFirstTriangle( ):Boolean
		{
			
			var p1:DelaunayNode = nodes.elementAt(nodes.size - 3);
			var p2:DelaunayNode = nodes.elementAt(nodes.size - 2);
			var p3:DelaunayNode = nodes.elementAt(nodes.size - 1);
			
			var e1:DelaunayEdge = DelaunayEdges.getEdge(p1,p2);
			e1.setFlip(flipCount++);
			
			if( e1.onSide(p3) == 0 )
			{ 
				DelaunayEdges.deleteEdge(e1);
				//nodes.deleteElement(nd); 
				return false; 
			}
			
			
			if( e1.onSide(p3) == -1 )  // right side
			{
				p1 = nodes.elementAt(nodes.size - 2);
				p2 = nodes.elementAt(nodes.size - 3);
				e1.update(p1,p2);
			}
			
			var e2:DelaunayEdge = DelaunayEdges.getEdge(p2,p3);
			e2.setFlip(flipCount++);
			var e3:DelaunayEdge = DelaunayEdges.getEdge(p3,p1);
			e3.setFlip(flipCount++);
			e1.nextH = e2;
			e2.nextH = e3;
			e3.nextH = e1;
			hullStart = e1;
			triangles.addElement(DelaunayTriangles.getTriangle(e1,e2,e3,edges));
			
			if ( p1.data is BoundingTriangleNodeProperties )
			{
				_boundingNodes.push( p1 );
			}
			if ( p2.data is BoundingTriangleNodeProperties )
			{
				_boundingNodes.push( p2 );
			}
			if ( p3.data is BoundingTriangleNodeProperties )
			{
				_boundingNodes.push( p3 );
			}
			
			
			
			return true;
		}
		
		
		public function removeNearest( px:Number, py:Number ):void
		{
			if( nodes.size <= 3) return;   // not allow deletion for only 1 triangle
			removeNode( getNearestNode(px,py));
		}
		
		public function removeNode( nd:DelaunayNode ):void
		{
			if(nd==null) return;          // not found
			
			var e:DelaunayEdge, ee:DelaunayEdge, start:DelaunayEdge;
			start = e = nd.edge.mostRight;
			var nodetype:int = 0;
			var idegree:int = -1;
			var index:Vector.<DelaunayEdge> = new Vector.<DelaunayEdge>();
			//if ( index.length < edges.size ) index = []
		
			while(nodetype==0)
			{
				edges.removeElement( ee = e.nextE );
				index[++idegree]=ee;
				ee.asIndex();
				triangles.deleteElement( e.inT );
				edges.removeElement(e);
				edges.removeElement(ee.nextE);
				e=ee.nextE.invE;            // next left edge
				if( e == null ) nodetype=2;         // nd on convex hull
				if( e == start ) nodetype=1;        // inner node
			}
			// generate new triangles and add to triangulation
			var cur_i:int=0;
			var cur_n:int=0;
			var last_n:int=idegree;
			var e1:DelaunayEdge;
			var e2:DelaunayEdge;
			var e3:DelaunayEdge;
		
			while(last_n>=1)
			{
				e1=index[cur_i];
				e2=index[cur_i+1];
				if(last_n==2 && nodetype==1)
				{
					triangles.addElement(DelaunayTriangles.getTriangle(e1,e2,index[2],edges));
					swapTest(e1);
					swapTest(e2);
					swapTest(index[2]);
					break;
				}
				if(last_n==1 && nodetype==1)
				{
					index[0].invE.linkSymm(index[1].invE);
					index[0].invE.asIndex();
					index[1].invE.asIndex();
					swapTest(index[0].invE);
					break;
				}
				if(e1.onSide(e2.p2)==1)  // left side
				{
					e3 = DelaunayEdges.getEdge(e2.p2,e1.p1);
					cur_i+=2;
					index[cur_n++]=e3.makeSymm();
					triangles.addElement(DelaunayTriangles.getTriangle(e1,e2,e3,edges));
					swapTest(e1);
					swapTest(e2);
				} else {
					index[cur_n++]=index[cur_i++];
				}
				if(cur_i==last_n) index[cur_n++]=index[cur_i++];
				if(cur_i==last_n+1)
				{
					if(last_n==cur_n-1) break;
					last_n=cur_n-1;
					cur_i=cur_n=0;
				}
			}
			if(nodetype==2)   // reconstruct the convex hull
			{
				index[last_n].invE.mostLeft.nextH = ( hullStart = index[last_n].invE );
				for(var i:int=last_n;i>0;i--)
				{ 
					index[i].invE.nextH = index[i-1].invE;
					index[i].invE.invE = null ;
				}
				index[0].invE.nextH = start.nextH;
				index[0].invE.invE = null ;
			}
			
			nodes.removeElement(nd);
			
		}
		
		
		public function expandTri( e:DelaunayEdge,  nd:DelaunayNode, type:int ):void
		{
			var e1:DelaunayEdge=e;
			var e2:DelaunayEdge=e1.nextE;
			var e3:DelaunayEdge=e2.nextE;
			var p1:DelaunayNode=e1.p1;
			var p2:DelaunayNode=e2.p1;
			var p3:DelaunayNode=e3.p1;
			var e10:DelaunayEdge;
			var e20:DelaunayEdge;
			var e30:DelaunayEdge;
			if( type == 2 )    // nd is inside of the triangle
			{
				e10 = DelaunayEdges.getEdge(p1,nd);
				e20 = DelaunayEdges.getEdge(p2,nd);
				e30 = DelaunayEdges.getEdge(p3,nd);
				e.inT.removeEdges(edges);
				triangles.deleteElement(e.inT);     // remove old triangle
				triangles.addElement(DelaunayTriangles.getTriangle(e1,e20,e10.makeSymm(),edges));
				triangles.addElement(DelaunayTriangles.getTriangle(e2,e30,e20.makeSymm(),edges));
				triangles.addElement(DelaunayTriangles.getTriangle(e3,e10,e30.makeSymm(),edges));
				swapTest(e1);   // swap test for the three new triangles
				swapTest(e2);
				swapTest(e3);
			}
			else           // nd is on the edge e
			{
				var e4:DelaunayEdge=e1.invE;
				if(e4==null || e4.inT==null)           // one triangle involved
				{
					e30=DelaunayEdges.getEdge(p3,nd);
					var e02:DelaunayEdge=DelaunayEdges.getEdge(nd,p2);
					e10=DelaunayEdges.getEdge(p1,nd);
					var e03:DelaunayEdge=e30.makeSymm();
					e10.asIndex();
					e1.mostLeft.nextH = e10;
					e10.nextH = e02;
					e02.nextH = e1.nextH;
					hullStart = e02;
					triangles.deleteElement(e1.inT);                   // remove oldtriangle               // add two new triangles
					edges.deleteElement(e1);
					edges.addElement(e10);
					edges.addElement(e02);
					edges.addElement(e30);
					edges.addElement(e03);
					triangles.addElement(DelaunayTriangles.getTriangle(e2,e30,e02));
					triangles.addElement(DelaunayTriangles.getTriangle(e3,e10,e03));
					swapTest(e2);   // swap test for the two new triangles
					swapTest(e3);
					swapTest(e30);
				} else         
				{
					// two triangle involved
					var e5:DelaunayEdge=e4.nextE;
					var e6:DelaunayEdge=e5.nextE;
					var p4:DelaunayNode=e6.p1;
					e10=DelaunayEdges.getEdge(p1,nd);
					e20=DelaunayEdges.getEdge(p2,nd);
					e30=DelaunayEdges.getEdge(p3,nd);
					var e40:DelaunayEdge=DelaunayEdges.getEdge(p4,nd);
					e.inT.removeEdges(edges);
					triangles.deleteElement(e.inT);                   // remove oldtriangle
					e4.inT.removeEdges(edges);
					triangles.deleteElement(e4.inT);               // remove old triangle
					e5.asIndex();   // because e, e4 removed, reset edge index of node p1 and p2
					e2.asIndex();
					triangles.addElement(DelaunayTriangles.getTriangle(e2,e30,e20.makeSymm(),edges));
					triangles.addElement(DelaunayTriangles.getTriangle(e3,e10,e30.makeSymm(),edges));
					triangles.addElement(DelaunayTriangles.getTriangle(e5,e40,e10.makeSymm(),edges));
					triangles.addElement(DelaunayTriangles.getTriangle(e6,e20,e40.makeSymm(),edges));
					swapTest(e2);   // swap test for the three new triangles
					swapTest(e3);
					swapTest(e5);
					swapTest(e6);
					swapTest(e10);
					swapTest(e20);
					swapTest(e30);
					swapTest(e40);
				}
			}
		}
		
		public function expandHull( nd:DelaunayNode):Boolean
		{
			var e1:DelaunayEdge;
			var e2:DelaunayEdge;
			var e3:DelaunayEdge;
			var enext:DelaunayEdge;
			var e:DelaunayEdge = hullStart;
			var comedge:DelaunayEdge;
			var lastbe:DelaunayEdge
			var round:int = 0;
			while(round<2)
			{
				
				enext = e.nextH;
				if ( enext == hullStart) round++;
				if( e.onSide(nd) == -1 )   // right side
				{
					if( lastbe != null )
					{
						e1 = e.makeSymm();
						e2 = DelaunayEdges.getEdge( e.p1, nd );
						e3 = DelaunayEdges.getEdge( nd, e.p2 );
						if( comedge == null )
						{
							hullStart = lastbe;
							lastbe.nextH = e2;
							lastbe = e2;
						}
						else comedge.linkSymm(e2);
						comedge=e3;
						triangles.addElement(DelaunayTriangles.getTriangle(e1,e2,e3,edges));
						swapTest(e);
					}
				}
				else
				{
					if(comedge!=null) break;
					lastbe=e;
				}
				e=enext;
			}
			
			if ( e3 != null )
			{
				lastbe.nextH = e3;
				e3.nextH = e;
				return true;
			}
			return false;
		}
		
		public function searchEdge( e:DelaunayEdge, nd:DelaunayNode ):int
		{
			
			var s:Number;
			var f2:int, f3:int;
			var ee:DelaunayEdge, enx:DelaunayEdge, e0:DelaunayEdge;
			var lastE:DelaunayEdge;
			while ( true )
			{
				e0 = null;
				enx = e.nextE;
				if ( enx == null  )
				{
					trace("edge missing");
					return 0;
				}
				if(( f2 = enx.onSide(nd)) == -1 )
				{ 
					if( enx.invE != null ) 
					{
						if ( enx.invE == lastE )
						{
							trace("looks like an endless loop");
							return 0;
						}
						e = enx.invE;
						lastE = e;
					} else 
					{ 
						actE = e; 
						return -1;
					}
				} else 
				{
					if( f2 == 0 ) e0 = enx;
					
					ee = enx;
					enx = enx.nextE;
					
					if( ( f3 = enx.onSide(nd) ) == -1 )
					{ 
						if( enx.invE != null ) 
						{
							e = enx.invE;
						} else { 
							actE = enx; 
							return -1;
						}
					} else {
						if( f3 == 0 ) e0 = ee.nextE;
						if( e.onSide(nd) == 0 ) e0 = e;
						if( e0 != null )
						{
							enx = e0.nextE;
							actE = e0;
							if( enx.onSide(nd) == 0) 
							{
								actE = enx; 
								return 0;
							}
							
							if( enx.nextE.onSide(nd) == 0) 
							{
								return 0;
							}
							
							return 1;
							
						} else 
						{
							actE = ee;
							return 2;
						}
					}
				}
			}  
			return -1;
		}
		
		public function swapTest( e11:DelaunayEdge ):void
		{
			var e21:DelaunayEdge;
			var stack:Vector.<DelaunayEdge> = new Vector.<DelaunayEdge>();
			stack.push( e11 );
			
			var visited:Dictionary = new Dictionary();
			
			while ( stack.length > 0 )
			{
				e11 = stack.shift();
				if ( visited[ e11 ] ) continue;
				visited[ e11 ] = true;
				
				e21 = e11.invE;
				
				if( e21 == null || e21.inT == null ) continue;
				
				var e12:DelaunayEdge = e11.nextE;
				var e13:DelaunayEdge = e12.nextE;
				var e22:DelaunayEdge = e21.nextE;
				var e23:DelaunayEdge = e22.nextE;
				
				if( e11.inT.inCircle(e22.p2) || e21.inT.inCircle(e12.p2) )
				{
					e11.update( e22.p2, e12.p2 );
					e21.update( e12.p2, e22.p2 );
					e11.linkSymm( e21);
					e13.inT.update( e13, e22, e11 );
					e23.inT.update( e23, e12, e21 );
					e12.asIndex();
					e22.asIndex();
					stack.push( e12 );
					stack.push( e22 );
					stack.push( e13 );
					stack.push( e23 );
				}
			}
		}
		
		public function getNearestNode( x:Number, y:Number):DelaunayNode
		{
			if ( nodes.size < 10 ) return nodes.nearest(x,y);
			
			var nd:DelaunayNode = DelaunayNodes.getNode( x, y  );
			var eid:int;
			actE = edges.elementAt(0);
			
			if ( actE == null ) {
				DelaunayNodes.deleteNode( nd );
				return null;
			}
			
			if( actE.onSide(nd) == -1)
			{ 
				if( actE.invE == null ) 
					eid = -1;
				else 
					eid = searchEdge( actE.invE, nd );
			} else {
				eid = searchEdge( actE, nd );
			}
			
			if ( actE.inT )
			{
				var nTriangles:Vector.<DelaunayTriangle> = actE.inT.getNeighborTriangles();
				var tested:Dictionary = new Dictionary();
				var bestNode:DelaunayNode;
				var bestDistance:Number = Number.MAX_VALUE;
				for each ( var ta:DelaunayTriangle in nTriangles )
				{
					var nNodes:Vector.<DelaunayNode> = ta.getNodes();
					for each ( var nn:DelaunayNode in nNodes )
					{
						if ( tested[nn] == null )
						{
							tested[nn] = true;
							var dist:Number = nd.distanceTo( nn );
							if ( dist < bestDistance )
							{
								bestDistance = dist;
								bestNode = nn;
							}
						
						}
					}
				}
			}
			DelaunayNodes.deleteNode( nd );
			return bestNode;
		}
		
		/*
		public function nearest( x:Number, y:Number):DelaunayNode
		{
			return nodes.nearest(x,y);
		}
		*/
		
		public function updateRegions():void
		{
			regions.removeAllElements();
			edges.buildVoronoiRegions( regions );
			regionsReady = true;
		}
		
		public function  drawPoints( g:Graphics, colorMap:BitmapData = null):void
		{
			nodes.drawPoints(g,true,colorMap);
			
		}
		
		public function animate( ):void
		{
			edges.animate();
			regionsReady = false;
		}
		
		public function updateNodes( mode:String ):void
		{
			nodes.updateData(mode);
		}
		
		public function updateSprites( ):void
		{
			nodes.updateSprites();
		}
		
		/*
		public function updateNodes( ):void
		{
		nodes.update( this );
		}
		*/
		
		public function drawTriangles( g:Graphics):void
		{
			if(nodes.size==1)
			{
				g.drawRect(nodes.elementAt(0).x-1,nodes.elementAt(0).y-1,2,2);
			} else if(nodes.size==2){
				g.moveTo(nodes.elementAt(0).x,nodes.elementAt(0).y)
				g.lineTo(nodes.elementAt(1).x,nodes.elementAt(1).y)
			} else {
				edges.draw(g);
			}
		}
		
		public function drawCircles( g:Graphics ):void
		{
			triangles.drawCircles(g);
		}
		
		public function drawVoronoiDiagram( g:Graphics, ignoreOuterRegions:Boolean = true ):void
		{
			edges.drawVoronoi(g);
		}
		
		public function drawVoronoiRegions( g:Graphics, colorMap:BitmapData = null ):void
		{
			if ( !regionsReady) updateRegions();
			regions.draw( g, colorMap );
			
		}
		
		public function getVoronoiRegions( ignoreOuterRegions:Boolean = true ):Vector.<VoronoiRegion>
		{
			if ( !regionsReady) updateRegions();
			return regions.getRegions( ignoreOuterRegions );
		}
		
		public function getVoronoiLines():Vector.<LineSegment>
		{
			return edges.getVoronoiLines();
		}
		
		public function getVoronoiRegionsAsConvexPolygons( clone:Boolean = true ):Vector.<ConvexPolygon>
		{
			if ( !regionsReady) updateRegions();
			return regions.getConvexPolygons( clone );
		}
		
		public function getVertices( ignoreOuterVertices:Boolean = true ):Vector.<DelaunayTriangle>
		{
			return triangles.getVertices();
		}
		
		public function getEdges( ignoreOuterEdges:Boolean = true ):Vector.<DelaunayEdge>
		{
			return edges.getEdges( ignoreOuterEdges );
		}
		
		public function getTriangles( ignoreOuterTriangles:Boolean = true ):Vector.<Triangle>
		{
			return triangles.getTriangles();
		}
		
		public function drawVertices( g:Graphics, ignoreOuterTriangle:Boolean = true ):void
		{
			triangles.drawVertex(g, ignoreOuterTriangle );
		}
		
		public function getHull( ignoreOuterTriangle:Boolean = true ):ConvexPolygon
		{
			return ConvexPolygon.fromVector( nodes.getVectors( ignoreOuterTriangle ) ); 
		}
		
		public function relaxVoronoi( minOffset:Number = 1, constrain:GeometricShape = null ):Boolean
		{
			var squaredDistance:Number = minOffset * minOffset;
			var regions:Vector.<VoronoiRegion> = getVoronoiRegions();
			var newCenters:Vector.<Vector2> = new Vector.<Vector2>();
			var relaxable:Vector.<Boolean> = new Vector.<Boolean>();
			if ( constrain == null ) constrain = getHull().toPolygon();
			var changed:Boolean = false;
			var center:Vector2 = new Vector2();
			var centroid:Vector2;
			
			for each ( var region:VoronoiRegion in regions )
			{
				center.x = region.p.x;
				center.y = region.p.y;
				centroid = region.polygon.centroid;
				if (  region.p.data.relaxable == true && centroid.distanceToVector( center ) > squaredDistance )
				{
					if ( constrain.hasPoint( center ))
					{
						centroid = constrain.getClosestPoint( centroid );
					}
					
					if ( !constrain.isInside( centroid, true ) )
					{
						centroid = constrain.getClosestPoint( centroid );
						/*
						var intersection:Intersection = new LineSegment( center, centroid ).intersect( constrain );
						if ( intersection.points.length > 0 )
						{
							centroid = intersection.points[0]
						} else {
							
							centroid = constrain.getClosestPoint( centroid );
						}
						*/
					}
					if ( centroid.distanceToVector( center ) > squaredDistance ) changed = true;
					region.p.x = centroid.x;
					region.p.y = centroid.y;
					
				} 
				if ( !(region.p.data is BoundingTriangleNodeProperties) )
				{
					newCenters.push( new Vector2( region.p.x, region.p.y ) );
					relaxable.push( region.p.data.relaxable );
				}
			}
			if ( changed )
			{
				var boundingNodes:Vector.<DelaunayNode> = getBoundingNodes();
				
				var bounds:Vector.<Vector2> = new Vector.<Vector2>();
				for ( var i:int = 0; i < boundingNodes.length; i++ )
				{
					bounds.push( new Vector2( boundingNodes[i].x, boundingNodes[i].y ) );
				}
				
				clear();
				
				for (  i = 0; i < bounds.length; i++ )
				{
					insertXY( bounds[i].x, bounds[i].y, new BoundingTriangleNodeProperties() );
				}
				
				for ( i = 0; i < newCenters.length; i++ )
				{
					insertXY( newCenters[i].x, newCenters[i].y, new DelaunayColorNodeProperties(0xffff0000, relaxable[i]) );
				}
			}
			return changed;
		}
		
		public function getBoundingNodes():Vector.<DelaunayNode>
		{
			return _boundingNodes.concat();
		}
	}
}