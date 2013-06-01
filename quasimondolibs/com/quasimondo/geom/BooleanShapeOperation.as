/*

	Boolean Shape Operation  Class v1.0

	released under MIT License (X11)
	http://www.opensource.org/licenses/mit-license.php

	Author: Mario Klingemann
	http://www.quasimondo.com
	
	Copyright (c) 2006-2010 Mario Klingemann
*/

	package com.quasimondo.geom
	{
	
		public class BooleanShapeOperation 
		{
			public static const UNION:String 			= "UNION";
			public static const INTERSECTION:String  	= "INTERSECTION";
			public static const EXCLUSION:String 		= "EXCLUSION";
			public static const SUBTRACTION:String 		= "SUBTRACT";
			public static var POLYGONIZATION_LENGTH:int = 10;
			
			public static function operate( shape1:GeometricShape, shape2:GeometricShape, operation:String ):CompoundShape
			{
				// temporary hack:
				if ( shape1.type == "MixedPath" )
				{
					shape1 = MixedPath(shape1).toPolygon(POLYGONIZATION_LENGTH);
				}
				if ( shape2.type == "MixedPath" )
				{
					shape2 = MixedPath(shape2).toPolygon(POLYGONIZATION_LENGTH);
				}
				
				switch(  operation )
				{
					case UNION:
						return new BooleanShapeOperation().union( shape1, shape2 );
					break;
					case INTERSECTION:
						return new BooleanShapeOperation().intersection( shape1, shape2 );
					break;
					case EXCLUSION:
						return new BooleanShapeOperation().exclusion( shape1, shape2 );
					break;
					case SUBTRACTION:
						return new BooleanShapeOperation().subtraction( shape1, shape2 );
					break;
				
				}
				return null;
			
			}
			
			function BooleanShapeOperation() 
			{
			}
	
			public function union( shape1:GeometricShape, shape2:GeometricShape ):CompoundShape
			{
				
				switch(  shape1.type + shape2.type )
				{
					case "PolygonPolygon":
						return union_Polygon_Polygon( Polygon(shape2), Polygon(shape1) );
						break;
					case "CompoundShapeCompoundShape":
						return union_CompoundShape_CompoundShape( CompoundShape(shape2), CompoundShape(shape1) );
						break;
					case "CompoundShapePolygon":
						return union_CompoundShape_Polygon( CompoundShape(shape1), Polygon(shape2) );
						break;
					case "PolygonCompoundShape":
						return union_CompoundShape_Polygon( CompoundShape(shape2), Polygon(shape1) );
						break;
				}
				
				return null;
			}
			
			public function union_Polygon_Polygon( p1:Polygon, p2:Polygon ):CompoundShape
			{
				// one is fully contained in the other one  - return inner
				var result:CompoundShape = getAllInsideUnion( p1, p2 );
				if ( result != null ) return result;
				
				var mesh:LinearMesh = new LinearMesh();
				mesh.addPolygon( p1 );
				mesh.addPolygon( p2 );
				
				return getUnionResult( mesh, p1, p2 );
			}
			
			public function union_CompoundShape_CompoundShape( p1:CompoundShape, p2:CompoundShape ):CompoundShape
			{
				// one is fully contained in the other one  - return inner
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideUnion( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				for ( i = 0; i < p2.shapeCount; i++ )
				{
					shape = p2.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				
				return getUnionResult( mesh, p1, p2 );
			}
			
			
			public function union_CompoundShape_Polygon( p1:CompoundShape, p2:Polygon ):CompoundShape
			{
				// one is fully contained in the other one  - return inner
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideUnion( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				
				mesh.addPolygon( p2 );
			
				return getUnionResult( mesh, p1, p2 );
			}
			
			private function getAllInsideUnion( p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				var result:CompoundShape;
				if ( allInside(p1,p2) && allOutside(p2,p1)) 
				{
					result = new CompoundShape();
					result.addShape( p2 );
					return result;
				}
				if ( allInside(p2,p1) && allOutside(p1,p2)) 
				{
					result = new CompoundShape();
					result.addShape( p1 );
					return result;
				}
				return null;
			}
			
			private function getUnionResult( mesh:LinearMesh, p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				var allPolys:Vector.<Polygon> = mesh.getPolygons();
				
				var edges:Vector.<MeshEdgeInfo> = mesh.getInnerEdges();
				if ( edges.length > 0 )
				{
					for each ( var edgeInfo:MeshEdgeInfo in edges )
					{
						mesh.removeConnection( edgeInfo.id );
					}
					mesh.removeOrphans();
				}
				
				var mergedPolys:Vector.<Polygon> = mesh.getPolygons();
				var points:Vector.<Vector2>;
				for ( var i:int = allPolys.length; --i > -1; )
				{
					for ( var j:int = 0; j < mergedPolys.length; j++ )
					{
						points = allPolys[i].getCopyOfPoints();
						for ( var k:int = 0; k < points.length; k++ )
						{
							if ( mergedPolys[j].hasPoint( points[k] ) )
							{
								allPolys.splice(i,1);
								j = mergedPolys.length;
								break;
							}
						}
					}
				}
				
				for ( i = allPolys.length; --i > -1; )
				{
					var p:Vector2 = allPolys[i].getInsidePoint();
					if (  p1.isInside( p, false ) ||  p2.isInside( p, false ) )
					{
						allPolys.splice(i,1);
					}
				}
				
				for ( i = allPolys.length; --i > -1; )
				{
					mesh.addPolygon( allPolys[i] );
				}
				
				return CompoundShape.fromPolygons( mesh.getPolygons());
			}
			
			public function intersection( shape1:GeometricShape, shape2:GeometricShape ):CompoundShape
			{
				switch( shape1.type + shape2.type )
				{
					case "PolygonPolygon":
						return intersection_Polygon_Polygon( Polygon(shape1), Polygon(shape2) );
						break;
					case "CompoundShapeCompoundShape":
						return intersection_CompoundShape_CompoundShape( CompoundShape(shape2), CompoundShape(shape1) );
						break;
					case "CompoundShapePolygon":
						return intersection_CompoundShape_Polygon( CompoundShape(shape1), Polygon(shape2) );
						break;
					case "PolygonCompoundShape":
						return intersection_CompoundShape_Polygon( CompoundShape(shape2), Polygon(shape1) );
						break;
				}
				return null;
			}
			
			public function intersection_Polygon_Polygon( p1:Polygon, p2:Polygon ):CompoundShape
			{
				// one is fully contained in the other one  - return inner
				var result:CompoundShape = getAllInsideIntersection( p1, p2 );
				if ( result != null ) return result;
				
				var mesh:LinearMesh = new LinearMesh();
				mesh.addPolygon( p1 );
				mesh.addPolygon( p2 );
				
				return getIntersectionResult( mesh, p1, p2);
				
			}
			
			public function intersection_CompoundShape_CompoundShape( p1:CompoundShape, p2:CompoundShape ):CompoundShape
			{
				// one is fully contained in the other one  - return inner
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideIntersection( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				for ( i = 0; i < p2.shapeCount; i++ )
				{
					shape = p2.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				
				return getIntersectionResult( mesh, p1, p2);
				
			}
			
			public function intersection_CompoundShape_Polygon( p1:CompoundShape, p2:Polygon ):CompoundShape
			{
				// one is fully contained in the other one  - return inner
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideIntersection( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				mesh.addPolygon(p2 );
				
				return getIntersectionResult( mesh, p1, p2);
				
			}
			
			private function getAllInsideIntersection( p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				var result:CompoundShape;
				if ( allInside(p1,p2) && allOutside(p2,p1)) 
				{
					result = new CompoundShape();
					result.addShape( p1 );
					return result;
				}
				if ( allInside(p2,p1) && allOutside(p1,p2)) 
				{
					result = new CompoundShape();
					result.addShape( p2 );
					return result;
				}
				return null;
			}
			
			
			private function getIntersectionResult( mesh:LinearMesh, p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				var allPolys:Vector.<Polygon> = mesh.getPolygons();
				mesh = new LinearMesh();
				for ( var i:int = allPolys.length; --i > -1; )
				{
					var p:Vector2 = allPolys[i].getInsidePoint();
					if ( p1.isInside( p, false ) && p2.isInside( p, false )  )
					{
						mesh.addPolygon( allPolys[i] );
					}
				}
				
				return CompoundShape.fromPolygons( mesh.getPolygons());
			}
			
			public function subtraction( shape1:GeometricShape, shape2:GeometricShape ):CompoundShape
			{
				switch( shape1.type + shape2.type )
				{
					case "PolygonPolygon":
						return subtraction_Polygon_Polygon( Polygon(shape1), Polygon(shape2) );
						break;
					case "CompoundShapeCompoundShape":
						return subtraction_CompoundShape_CompoundShape( CompoundShape(shape1), CompoundShape(shape2) );
						break;
					case "CompoundShapePolygon":
						return subtraction_CompoundShape_Polygon( CompoundShape(shape1), Polygon(shape2) );
						break;
					case "PolygonCompoundShape":
						return subtraction_Polygon_CompoundShape( Polygon(shape1), CompoundShape(shape2) );
						break;
				}
				return null;
			}
			
			public function subtraction_Polygon_Polygon( p1:Polygon, p2:Polygon ):CompoundShape
			{
				var result:CompoundShape = getAllInsideSubtraction( p1, p2 );
				if ( result != null ) return result;
				
				var mesh:LinearMesh = new LinearMesh();
				mesh.addPolygon( p1 );
				mesh.addPolygon( p2 );
				
				return getSubtractionResult( mesh, p1, p2 );		
			
			}
			
			public function subtraction_CompoundShape_CompoundShape( p1:CompoundShape, p2:CompoundShape ):CompoundShape
			{
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideSubtraction( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				for ( i = 0; i < p2.shapeCount; i++ )
				{
					shape = p2.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				
				
				return getSubtractionResult( mesh, p1, p2 );		
				
			}
			
			public function subtraction_CompoundShape_Polygon( p1:CompoundShape, p2:Polygon ):CompoundShape
			{
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideSubtraction( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				mesh.addPolygon(p2);
				
				return getSubtractionResult( mesh, p1, p2 );		
				
			}
			
			public function subtraction_Polygon_CompoundShape( p1:Polygon, p2:CompoundShape ):CompoundShape
			{
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideSubtraction( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p2.shapeCount; i++ )
				{
					shape = p2.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				mesh.addPolygon(p1);
				
				return getSubtractionResult( mesh, p1, p2 );		
				
			}
			
			private function getAllInsideSubtraction( p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				// p1 is fully contained in p2 - return empty mesh
				if ( allInside(p1,p2)  && allOutside(p2,p1)  ) return new CompoundShape();
				
				// p2 is fully contained in p1 - return both polygons
				if ( allInside(p2,p1)  && allOutside(p1,p2) ) {
					var result:CompoundShape = new CompoundShape();
					result.addShape( p1 );
					result.addShape( p2 );
					return result;
				}
				
				return null;
			}
			
			private function getSubtractionResult( mesh:LinearMesh, p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				var allPolys:Vector.<Polygon> = mesh.getPolygons();
				mesh = new LinearMesh();
				var potentialCandidates:Vector.<Polygon> = new Vector.<Polygon>();
				var polysAdded:int = 0;
				for ( var i:int = allPolys.length; --i > -1; )
				{
					var intersections:int = 0;
					var p1_outside:int = 0;
					var p2_outside:int = 0;
					var p1_in_p2:int = 0;
					var p2_in_p1:int = 0;
					var lastOnP2:Boolean = false;
					var lastP:Vector2;
					var inP1:Boolean, inP2:Boolean, onP1:Boolean, onP2:Boolean;
					var pointCount:int =  allPolys[i].pointCount;
					var hasOutsideLine:Boolean = false;
					for ( var j:int = pointCount; --j > -1; )
					{
						var p:Vector2 = allPolys[i].getPointAt( j );
						
						inP1 = p1.isInside( p, true );
						inP2 = p2.isInside( p, true );
						onP2 = ( inP2 && !p2.isInside( p, false ) );
						onP1 = ( inP1 && !p1.isInside( p, false ) );
						
						if ( onP2 && !inP1 )
						{
							p2_outside++;
							break;
						} else if ( onP1 && onP2 )
						{
							//TODO: handle case overlapping corners
							intersections++;
						} else if ( onP1 && inP2 )
						{
							p1_in_p2++;
							break;
						} else if ( onP1 && !inP2 )
						{
							p1_outside++;
						} else if ( onP2 && inP1 )
						{
							p2_in_p1++;
						}
						if ( lastOnP2 && onP2 )
						{
							if ( !p1.isInside( lastP.getLerp(p,0.5), true ) )
							{
								hasOutsideLine = true;
								break;
							}
						}
						lastOnP2 = onP2;
						lastP = p;
					}
					/*
					trace( "Count: "+pointCount );
					trace( "intersections",intersections);
					trace( "p1_outside",p1_outside);
					trace( "p2_outside",p2_outside);
					trace( "p1_in_p2",p1_in_p2);
					trace( "p2_in_p1",p2_in_p1);
					trace( "hasOutsideLine",hasOutsideLine);
					*/
					if ( !hasOutsideLine && ( p1_in_p2 == 0 ))
					{
						if (  (p1_outside == ICountable(p1).pointCount && intersections > 0) )
						{
							potentialCandidates.push( allPolys[i] );
							//trace( "POTENTIAL")
						} else if ( !(p2_outside > 0) && (intersections != pointCount)   )
						{
							if (( p1_outside + p1_in_p2 > 0 ) && 
								!(p2_outside + p1_in_p2 + p2_in_p1 == 0 && p1_outside > 0 && intersections > 0) && 
								!(p1_in_p2 == pointCount) ||
								 (p2_in_p1 == pointCount) ||
								 ( p1_outside + intersections == pointCount ))
							{
								mesh.addPolygon( allPolys[i] );
								polysAdded++;
								//trace( "ADDED")
							} else if ( intersections > 0 && intersections + p2_in_p1 == pointCount )
							{
								//trace( "outlier");
								var splits:Vector.<ConvexPolygon> =  allPolys[i].getConvexPolygons( Polygon.SPLIT_FAST, false );
								for ( j = 0; j < splits.length; j++ )
								{
									p = splits[j].centroid;
									if ( p1.isInside( p, false ) && !p2.isInside( p, false )  )
									{
										mesh.addPolygon( allPolys[i] );
										//trace( "outlier ADDED");
										break;
									}
								}
							}	 
						} 
					}
				}
				if ( polysAdded == 0 )
				{
					for ( i = 0; i < potentialCandidates.length; i++ )
					{
						mesh.addPolygon( potentialCandidates[i] );
						//trace( "POTENTIAL ADDED")
					}
				}
				
				return CompoundShape.fromPolygons( mesh.getPolygons());
			}
			
			public function exclusion( shape1:GeometricShape, shape2:GeometricShape ):CompoundShape
			{
				switch( shape1.type + shape2.type )
				{
					case "PolygonPolygon":
						return exclusion_Polygon_Polygon( Polygon(shape1), Polygon(shape2) );
						break;
					case "CompoundShapeCompoundShape":
						return exclusion_CompoundShape_CompoundShape( CompoundShape(shape2), CompoundShape(shape1) );
						break;
					case "CompoundShapePolygon":
						return exclusion_CompoundShape_Polygon( CompoundShape(shape1), Polygon(shape2) );
						break;
					case "PolygonCompoundShape":
						return exclusion_CompoundShape_Polygon( CompoundShape(shape2), Polygon(shape1) );
						break;
				}
				return null;
			}
			
			
			
			public function exclusion_Polygon_Polygon( p1:Polygon, p2:Polygon ):CompoundShape
			{
				var result:CompoundShape = getAllInsideExclusion( p1, p2 );
				if ( result != null ) return result;
				
				var mesh:LinearMesh = new LinearMesh();
				mesh.addPolygon( p1 );
				mesh.addPolygon( p2 );
				
				return getExclusionResult( mesh, p1, p2 );	
				
			}
			
			public function exclusion_CompoundShape_CompoundShape( p1:CompoundShape, p2:CompoundShape ):CompoundShape
			{
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideExclusion( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				for ( i = 0; i < p2.shapeCount; i++ )
				{
					shape = p2.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				};
				
				return getExclusionResult( mesh, p1, p2 );	
				
			}
			
			public function exclusion_CompoundShape_Polygon( p1:CompoundShape, p2:Polygon ):CompoundShape
			{
				if ( p1.intersect(p2).points.length == 0 )
				{
					var result:CompoundShape = getAllInsideExclusion( p1, p2 );
					if ( result != null ) return result;
				}
				
				var mesh:LinearMesh = new LinearMesh();
				var shape:GeometricShape;
				for ( var i:int = 0; i < p1.shapeCount; i++ )
				{
					shape = p1.getShapeAt( i );
					if ( shape is Polygon ) mesh.addPolygon( Polygon(shape) );
					else return result;
				}
				mesh.addPolygon( p2 );
				
				return getExclusionResult( mesh, p1, p2 );	
				
			}
			
			private function getAllInsideExclusion( p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				var result:CompoundShape = new CompoundShape();
				
				// one is fully contained in the other one  - return inner
				if ( ( allInside(p1,p2) && allOutside(p2,p1)) || ( allInside(p2,p1) && allOutside(p1,p2)) ) 
				{
					result.addShape( p1 );
					result.addShape( p2 );
					return result;
				}
				return null;
			}
			
			private function getExclusionResult( mesh:LinearMesh, p1:GeometricShape, p2:GeometricShape ):CompoundShape
			{
				var result:CompoundShape = new CompoundShape();
				var allPolys:Vector.<Polygon> = mesh.getPolygons();
				mesh = new LinearMesh();
				for ( var i:int = allPolys.length; --i > -1; )
				{
					var p:Vector2 = allPolys[i].getInsidePoint();
					if ( p1.isInside( p, false ) != p2.isInside( p, false )  )
					{
						result.addShape( allPolys[i] );
					}
				}
				
				return result;
			}
			
			
			private function allInside( p1:GeometricShape, p2:GeometricShape ):Boolean
			{
				var points:Vector.<Vector2> = new Vector.<Vector2>();
				if ( p1 is Polygon )
				{
					points = Polygon(p1).getCopyOfPoints();
				} else if ( p1 is CompoundShape )
				{
					for ( i = 0; i < CompoundShape(p1).shapeCount; i++ )
					{
						var shape:GeometricShape = CompoundShape(p1).getShapeAt( i );
						if ( shape is Polygon ) points = points.concat(Polygon(shape).getCopyOfPoints());
					}	
				}
				
				for ( var i:int = points.length; --i > -1; )
				{
					if ( !p2.isInside(points[i]) )
					{
						return false
					}
				}
				return true;
			}
			
			private function allOutside( p1:GeometricShape, p2:GeometricShape ):Boolean
			{
				var points:Vector.<Vector2> = new Vector.<Vector2>();
				if ( p1 is Polygon )
				{
					points = Polygon(p1).getCopyOfPoints();
				} else if ( p1 is CompoundShape )
				{
					for ( i = 0; i < CompoundShape(p1).shapeCount; i++ )
					{
						var shape:GeometricShape = CompoundShape(p1).getShapeAt( i );
						if ( shape is Polygon ) points = points.concat(Polygon(shape).getCopyOfPoints());
					}	
				}
				for ( var i:int = points.length; --i > -1; )
				{
					if ( p2.isInside(points[i]) )
					{
						return false
					}
				}
				return true;
			}
			
			
	}
}