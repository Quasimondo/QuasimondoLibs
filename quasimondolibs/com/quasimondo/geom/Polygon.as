/**
* Description here...
* @author Default
* @version 0.1
*/

package com.quasimondo.geom
{
	import com.quasimondo.geom.pointStructures.BalancingKDTree;
	import com.quasimondo.geom.pointStructures.KDTreeNode;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class Polygon extends GeometricShape implements IIntersectable, ICountable, IPolygonHelpers
	{
		
		public static const NON_CONVEX_CCW:String = "NON_CONVEX_CCW";
		public static const NON_CONVEX_CW:String = "NON_CONVEX_CW";
		public static const NON_CONVEX_DEGENERATE:String = "NON_CONVEX_DEGENERATE";
		public static const CONVEX_DEGENERATE:String = "CONVEX_DEGENERATE";
		public static const CONVEX_CCW:String = "CONVEX_CCW";
		public static const CONVEX_CW:String = "CONVEX_CW";
		
		public static const SPLIT_FAST:String      = "SPLIT_FAST";
		public static const SPLIT_SIMPLE:String    = "SPLIT_SIMPLE";
		public static const SPLIT_MAX_AREA:String  = "SPLIT_MAX_AREA";
		public static const SPLIT_MAX_ANGLE:String = "SPLIT_MAX_ANGLE";
		
		
		protected var points:Vector.<Vector2>;
		
		public var treeCleanupCycle:uint = 500;
		protected var treeOperationCount:uint;
		protected var tree:BalancingKDTree;
		
		
		protected var dirty:Boolean = true;
		protected var __classification:String;
		protected var __selfIntersects:Boolean;
		protected var selfIntersectionIndex_side1:int;
		protected var selfIntersectionIndex_side2:int;
		
		public static function fromArray( points:Array ):Polygon
		{
			var cv:Polygon = new Polygon();
			for ( var i:int = 0; i < points.length; i++ )
			{
				cv.points.push( Vector2(points[i]) );
			}
			cv.tree.insertPoints( cv.points );
			return cv;
		}
		
		public static function fromXML( xml:XML  ):Polygon
		{
			var cv:Polygon = new Polygon();
			var pts:Array = xml.@points.split(",");
			for ( var i:int = 0; i < pts.length; i+=2 )
			{
				cv.points.push( new Vector2( Number(pts[i]), Number( pts[i+1])) );
			}
			cv.tree.insertPoints( cv.points );
			return cv;
		}
		
		public static function fromVector( points:Vector.<Vector2>, clonePoints:Boolean = false ):Polygon
		{
			var cv:Polygon = new Polygon();
			if ( !clonePoints )
				cv.points = points.concat();
			else
				for ( var i:int = 0; i < points.length; i++ )
				{
					cv.points.push( points[i].getClone() );
				}
			cv.tree.insertPoints( cv.points );
			return cv;
		}
		
		public static function fromRectangle( rect:Rectangle ):Polygon
		{
			return Polygon.fromArray( [
										new Vector2( rect.x,rect.y ),
										new Vector2( rect.x + rect.width,rect.y ),
										new Vector2( rect.x + rect.width,rect.y+  rect.height ),
										new Vector2( rect.x,rect.y+ rect.height )
									 ]);
		}
		
		public static function getRectangle( x:Number, y:Number, width:Number, height:Number ):Polygon
		{
			return Polygon.fromArray( [
				new Vector2( x,y ),
				new Vector2( x + width,y ),
				new Vector2( x + width,y+height ),
				new Vector2( x , y+height )
			]);
		}

		public static function getRegularPolygon( sideLength:Number, sides:int, center:Vector2 = null, rotation:Number = 0 ):Polygon
		{
			var angle:Number  = 2 * Math.PI / sides;
			var radius:Number = (sideLength * 0.5 ) / Math.sin(angle*0.5);
			if ( center == null ) center = new Vector2();
			
			var points:Vector.<Vector2> = new Vector.<Vector2>();
			for ( var i:int = 0; i< sides; i++ )
			{
				points.push( new Vector2( center.x + radius * Math.cos( rotation + i * angle ),center.y + radius * Math.sin( rotation + i * angle )  ) );
			}	
			return Polygon.fromVector( points );
		}
		
		public static function getCircle( center:Vector2, radius:Number, maxSegmentLength:Number = 2):Polygon
		{
			var c:Circle = new Circle( center, radius );
			return c.toPolygon( maxSegmentLength );
		}
		
		public static function getRegularCenteredPolygon( radius:Number, sides:int, center:Vector2 = null, rotation:Number = 0 ):Polygon
		{
			var angle:Number  = 2 * Math.PI / sides;
			if ( center == null ) center = new Vector2();
			
			var points:Vector.<Vector2> = new Vector.<Vector2>();
			for ( var i:int = 0; i< sides; i++ )
			{
				points.push( new Vector2( center.x + radius * Math.cos( rotation + i * angle ),center.y + radius * Math.sin( rotation + i * angle )  ) );
			}	
			return Polygon.fromVector( points );
		}
		
		public static function getCenteredStar( outerRadius:Number, innerRadius:Number, spokes:int, center:Vector2 = null, rotation:Number = 0 ):Polygon
		{
			var sides:int = spokes * 2;
			var angle:Number  = 2 * Math.PI / sides;
			if ( center == null ) center = new Vector2();
			
			var points:Vector.<Vector2> = new Vector.<Vector2>();
			for ( var i:int = 0; i< sides; i++ )
			{
				var radius:Number = ( i % 2 == 0 ? outerRadius : innerRadius );
				points.push( new Vector2( center.x + radius * Math.cos( rotation + i * angle ),center.y + radius * Math.sin( rotation + i * angle )  ) );
			}	
			return Polygon.fromVector( points );
		}
		
		public function Polygon()
		{
			points = new Vector.<Vector2>();
			tree = new BalancingKDTree();
		}
		
		public function addSegment( line:LineSegment ):void
		{
			addPoint( line.p1 );
			addPoint( line.p2 );
		}
		
		public function addPoint( p:Vector2 ):void
		{
			if ( p == null ) return;
			dirty = true;
			points.push( p );
			tree.insertPoint( p );
		}
		
		public function addPointAt( index:int, p:Vector2 ):void
		{
			if ( p == null ) return;
			dirty = true;
			index = int(((index % (points.length+1)) + (points.length+1))% (points.length+1));
			points.splice(index,0,p);
			tree.insertPoint( p );
		}
		
		public function removePointAt( index:int ):void
		{
			dirty = true;
			index = int(((index % points.length) + points.length)% points.length);
			var p:Vector2 = points[index];
			tree.removePoint( p );
			points.splice(index,1);
			
		}
		
		
		public function getPointAt( index:int ):Vector2
		{
			return points[int(((index % points.length) + points.length)% points.length) ];
		}
		
		public function addPointAtClosestSide( p:Vector2 ):void
		{
			if ( points.length > 2 )
			{
				addPointAt( getClosestSideIndex(p) 	+ 1, p );
			} else {
				addPoint( p );
			}
		}
		
		public function shiftIndices( offset:int ):void
		{
			offset %= points.length;
			if ( offset == 0 ) return;
			var i:int;
			
			if ( offset > 0 )
			{
				for ( i = 0; i < offset; i++ )
				{
					points.unshift( points.pop() );
				}
			} else {
				for ( i = 0; i < -offset; i++ )
				{
					points.push( points.shift() );
				}
			}
		}
		
		public function getNormalAtIndex( index:int, length:Number = 1 ):Vector2
		{
			var p1:Vector2 = getPointAt( index-1 );
			var p2:Vector2 = getPointAt( index );
			var p3:Vector2 = getPointAt( index+1 );
			
			var p4:Vector2 = p3.getMinus(p2).newLength( p1.distanceToVector(p2) ).plus( p2 ).lerp(p1,0.5).minus(p2).newLength( -p3.windingDirection( p1,p2 ) * length);
			return p4;
		}
		
		public function getInsidePoint():Vector2
		{
			var triangles:Vector.<ConvexPolygon> = getConvexPolygons( Polygon.SPLIT_FAST, false );
			if ( triangles.length == 0 )
			{
				return points[0];
			}
			return triangles[0].centroid;
		}
		
		override public function hasPoint( p:Vector2 ):Boolean
		{
			var nearest:KDTreeNode = tree.findNearestFor( p );
			return nearest != null && p.squaredDistanceToVector( nearest.point ) < SNAP_DISTANCE * SNAP_DISTANCE;
		}
		
		public function getIndexOfPoint( p:Vector2 ):int
		{
			var nearest:KDTreeNode = tree.findNearestFor( p );
			if (  nearest != null && p.squaredDistanceToVector( nearest.point ) < SNAP_DISTANCE * SNAP_DISTANCE )
			{
				for ( var i:int = points.length; --i>-1;)
				{
					if ( points[i] == nearest.point ) return i;
				}
			}
			return -1;
		}
		
		public function getGradientMatrix( angle:Number = 0):Matrix
		{
			var m:Matrix = new Matrix();
			
			if ( pointCount < 3 ) return m;
			
			var p:Polygon = Polygon(clone());
			if ( angle != 0 ) p.rotate(-angle)
			var r:Rectangle = p.getBoundingRect();
			
			m.createGradientBox( 200,200 );
			m.translate( -100, -100 );
			m.scale( r.width / 200, r.height / 200 );
			if ( angle != 0 ) m.rotate( angle );
			
			var r2:Polygon = Polygon.fromRectangle(r);
			if ( angle != 0 ) r2.rotate( angle, centroid );
			var c:Vector2 = r2.centroid;
			m.translate( c.x, c.y );
			return m;
			
		}	
		
		//warning this can also be a negative value!
		public function get area():Number
		{
			
			var sx:Number = 0;
			var sy:Number = 0;
			var a:Number = 0;
			
			var p1:Vector2;
			var p2:Vector2;
			
			for ( var i:int = 0; i< points.length; i++ )
			{
				p1 = points[i];
				p2 = points[int((i+1) % points.length)];
				a +=  p1.x * p2.y - p2.x * p1.y;
				
			} 
			
			return a * 0.5;
		}
		
		public function get centroid():Vector2
		{
			var sx:Number = 0;
			var sy:Number = 0;
			var a:Number = 0;
			
			var p1:Vector2;
			var p2:Vector2;
			var f:Number;
			
			for ( var i:int = 0; i< points.length; i++ )
			{
				p1 = points[i];
				p2 = points[int((i+1) % points.length)];
				a += ( f = p1.x * p2.y - p2.x * p1.y );
				sx += (p1.x + p2.x) * f;
				sy += (p1.y + p2.y) * f;
			}
			
			f = 1 / ( 3 * a );
			
			
			return new Vector2( sx * f, sy * f );
		}
		
		public function joinAtCommonSide( p:Polygon ):Polygon
		{
			var count1:int = pointCount;
			var count2:int = p.pointCount;
			var v:Vector2, v2:Vector2;
			var sideIndexThis:int;
			var sideIndexThat:int;
			var sideIndexThat2:int;
			var match:Boolean = false;
			
			for ( var i:int = 0; i < count1; i++ )
			{
				v = getPointAt( i );
				for ( var j:int = 0; j < count2; j++ )
				{
					if (v.snaps( p.getPointAt( j ) ))
					{
						sideIndexThis = i;
						sideIndexThat = j;
						v2 = getPointAt( i + 1 );
						if ( v2.snaps( p.getPointAt( j+1 )))
						{
							sideIndexThat2 = j+1;
							i = count1;
							match = true
							break;
						} else if ( v2.snaps( p.getPointAt( j-1 )))
						{
							sideIndexThat2 = j-1;
							i = count1;
							match = true
							break;
						}
					}
				}
			}
			
			if ( !match ) return null;
			
			
			var polyPoints1:Vector.<Vector2> = new Vector.<Vector2>();
			var polyPoints2:Vector.<Vector2> = new Vector.<Vector2>();
			
			
			for ( i = 0; i <  count1; i++ )
			{
				polyPoints1.push( points[i] );
				polyPoints2.push( points[i] );
				if ( i == sideIndexThis )
				{
					if ( sideIndexThat > sideIndexThat2 )
					{
						for ( j = sideIndexThat + 1; j <  sideIndexThat+count2-1;j++ )
						{
							polyPoints1.push( p.getPointAt(j));
							polyPoints2.push( p.getPointAt(count2-j-1));
						}
					} else {
						for ( j = sideIndexThat2+1; j <  sideIndexThat2+count2-1;j++ )
						{
							polyPoints1.push( p.getPointAt(j));
							polyPoints2.push( p.getPointAt(count2-j-1));
						}
					}
				}
			}
			
			var poly1:Polygon = Polygon.fromVector( polyPoints1 );
			if ( !poly1.selfIntersects ) 
			{
				return poly1;
			}
			
			return Polygon.fromVector( polyPoints2 );
			
		}
		
		public function getSplit( index1:int, index2:int ):Vector.<Polygon>
		{
			var pCount:int = pointCount;
			if ( index1 < index2 )
			{
				var minIndex:int = index1;
				var maxIndex:int = index2;
			} else {
				minIndex = index2;
				maxIndex = index1;
			}
			
			if ( points.length < 4 || Math.abs( index1 - index2 ) < 2 || (maxIndex+1)%pCount == minIndex ) return new Vector.<Polygon>();
			
			var temp:Vector.<Vector2> = points.concat();
			var p1:Polygon = Polygon.fromVector( temp.slice( minIndex, maxIndex+1 ) );
			temp.splice( minIndex+1, (maxIndex-minIndex)-1 )
			var p2:Polygon = Polygon.fromVector( temp );
			
			return Vector.<Polygon>([p1,p2]);
		}
		
		
		
		public function getConvexPolygons( mode:String = Polygon.SPLIT_FAST, optimize:Boolean = true ):Vector.<ConvexPolygon>
		{
			var result:Vector.<ConvexPolygon> = new Vector.<ConvexPolygon>();
			
			if ( selfIntersects ) return result;
			
			var stack:Vector.<Polygon>;
			
			switch ( mode )
			{
				case Polygon.SPLIT_FAST:
					stack = getConvexPolygons_fast();
					break;
				case Polygon.SPLIT_SIMPLE:
					stack = getConvexPolygons_simple();
				break;
				case Polygon.SPLIT_MAX_AREA:
					stack = getConvexPolygons_maxArea();
				break;
				case Polygon.SPLIT_MAX_ANGLE:
					stack = getConvexPolygons_biggestAngle();
				break;
			}
			
			if ( optimize )
			{
				var p1:Polygon;
				var p2:Polygon;
				
				for ( i = stack.length; --i > 0;)
				{
					p1 = stack[i];
					for ( var j:int = i; --j>-1;)
					{
						p2 = p1.joinAtCommonSide( stack[j] );
						if ( p2 != null )
						{
							if ( p2.classification == Polygon.CONVEX_CCW || p2.classification == Polygon.CONVEX_CW )
							{
								stack.splice(i,1);
								stack.splice(j,1);
								stack.unshift( p2 );
								i = stack.length
								break;
							}
						}
					}
				}
			}
			
			for ( var i:int = 0; i < stack.length; i++ )
			{
				result[i] = stack[i].convexHull();
			}
			
			return result;
		}
		
		
		/**
		 * Simple polygon tesselator.
		 * <p>This handles both concave and convex non-selfintersecting polygons.</p>
		 * @return Array of Polygon2D objects.
		 */
		public function getConvexPolygons_fast():Vector.<Polygon>
		{
			var result:Vector.<Polygon> = new Vector.<Polygon>();
			var rest:Polygon = Polygon.fromVector( points );
			var o:Number = area;
			var i:int = 0, j:int, k:int, n:int, m:int;
			var ok:Boolean;
			
			while ( rest.pointCount> 2)
			{
				n = rest.pointCount;
				var tri:Polygon = Polygon.fromArray(
					[rest.points [(i + n - 1) % n], rest.points [i], rest.points [(i + 1) % n]]
				);
				
				// a triangle goes into mesh, if:
				// 1) it has same orientation with the polygon
				// 2) none of other vertices fall inside of triangle
				// 3) it has no open intersections with polygon edges
				ok = false;
				if (tri.area * o > 0)
				{
					ok = true;
					m = pointCount;
					for (k = 0; k < m; k++)
						if (tri.isInside( points[k], false ))
						{
							ok = false; k = m;
						}
					
					if (ok)
					{
						for (j = 0; j < 3; j++)
							for (k = 0; k < m; k++)
								if ( tri.getSide(j).crosses(getSide(k)))
								{
									ok = false; j = 3; k = m;
								}
					}
				}
				
				if (ok)
				{
					result.push(tri);
					rest.points.splice(i, 1);
					// if we have orphan link left, remove it
					rest.cleanEdges();
					// start all over
					i = 0;
				}
				else
				{
					i++;
					if (i > n - 1)
						// whatever is left, cannot be handled
						// either because this tesselator sucks, or because vertices list is malformed
						return result;
				}
			}
			return result;
		}
		
		
		
		public function getConvexPolygons_simple():Vector.<Polygon>
		{
			var result:Vector.<Polygon> = Vector.<Polygon>([ clone() ]);
			
			var index:int = 0;
			var currentPolygon:Polygon;
			var splitPolygon1:Polygon;
			var splitPolygon2:Polygon;
			
			var i:int, j:int, k:int;
			var splits:Vector.<Polygon>;
			var splitLine:LineSegment;
			var selfIntersection:Intersection;
			var currentArea:Number;
			
			var areaTolerance:Number;
			var areaToleranceFactor:Number = 0.01;
			
			while( index < result.length && ( result[index].classification != CONVEX_CCW && result[index].classification != CONVEX_CW ) )
			{
				currentPolygon = result[index];
				currentArea = Math.abs( currentPolygon.area );
				areaTolerance = currentArea * areaToleranceFactor;
					
				for ( i = 0; i < currentPolygon.pointCount - 2; i++ )
				{
					for ( j = i + 2; j < currentPolygon.pointCount; j++ )
					{
						
						if ( i == 0 && j == currentPolygon.pointCount - 1  ) continue;
			
						splitLine = new LineSegment( currentPolygon.getPointAt(i), currentPolygon.getPointAt( j ) );
						
						selfIntersection = currentPolygon.intersect( splitLine );
						
						if ( selfIntersection.points.length == 2 )
						{
							splits = currentPolygon.getSplit( i, j );
							if ( splits.length == 0 ) continue;
							
							splitPolygon1 = splits[0];
							splitPolygon2 = splits[1];
							if ( Math.abs( currentArea - ( Math.abs( splitPolygon1.area ) +  Math.abs( splitPolygon2.area )) ) < areaTolerance )
							{
							
								if ( ( splitPolygon1.classification == CONVEX_CCW || splitPolygon1.classification == CONVEX_CW ) )
								{
									result.splice( index, 1 );
									result.unshift( splitPolygon1 );
									if ( ( splitPolygon2.classification == CONVEX_CCW || splitPolygon2.classification == CONVEX_CW ) )
									{
										result.unshift( splitPolygon2 );
									} else {
										result.push( splitPolygon2 );
									}
									index++;
									i =  currentPolygon.pointCount;
									break;
								} else if ( ( splitPolygon2.classification == CONVEX_CCW || splitPolygon2.classification == CONVEX_CW ) )
								{
									result.splice( index, 1 );
									result.unshift( splitPolygon2 );
									result.push( splitPolygon1 );	
									index++;
									i =  currentPolygon.pointCount;
									break;
								} 
							}
						}
					}
				}
			}
			
			return result;
		}
		
		
		public function getConvexPolygons_maxArea():Vector.<Polygon>
		{
			var result:Vector.<Polygon> = Vector.<Polygon>([ clone() ]);
			
			var index:int = 0;
			var currentPolygon:Polygon;
			var splitPolygon1:Polygon;
			var splitPolygon2:Polygon;
			
			var i:int, j:int, k:int;
			var splits:Vector.<Polygon>;
			var splitLine:LineSegment;
			var selfIntersection:Intersection;
			var currentArea:Number;
			var area1:Number;
			var area2:Number;
			
			var areaToleranceFactor:Number = 0.01;
			var areaTolerance:Number;
			
			var bestArea:Number;
			var bestSplitPolygon1:Polygon;
			var bestSplitPolygon2:Polygon;
			
			while( index < result.length && ( result[index].classification != CONVEX_CCW && result[index].classification != CONVEX_CW ) )
			{
				currentPolygon = result[index];
				currentArea = Math.abs( currentPolygon.area );
				areaTolerance = currentArea * areaToleranceFactor;
				bestArea = 0;
				
				for ( i = 0; i < currentPolygon.pointCount - 2; i++ )
				{
					for ( j = i + 2; j < currentPolygon.pointCount; j++ )
					{
						
						if ( i == 0 && j == currentPolygon.pointCount - 1  ) continue;
			
						splitLine = new LineSegment( currentPolygon.getPointAt(i), currentPolygon.getPointAt( j ) );
						
						selfIntersection = currentPolygon.intersect( splitLine );
						
						if ( selfIntersection.points.length == 2 )
						{
							splits = currentPolygon.getSplit( i, j );
							if ( splits.length == 0 ) continue;
							
							splitPolygon1 = splits[0];
							splitPolygon2 = splits[1];
							area1 = Math.abs( splitPolygon1.area );
							area2 = Math.abs( splitPolygon2.area );
							if (  Math.abs(currentArea - (area1 +  area2) ) < areaTolerance )
							{
								if ( ( splitPolygon1.classification == CONVEX_CCW || splitPolygon1.classification == CONVEX_CW ) )
								{
									if ( ( splitPolygon2.classification == CONVEX_CCW || splitPolygon2.classification == CONVEX_CW ) )
									{
										if ( area1 + area2 > bestArea )
										{
											bestArea = area1 + area2;
											bestSplitPolygon1 = splitPolygon1;
											bestSplitPolygon2 = splitPolygon2;
										}
									} else {
										if ( area1 > bestArea )
										{
											bestArea = area1;
											bestSplitPolygon1 = splitPolygon1;
											bestSplitPolygon2 = splitPolygon2;
										}
									}
									
								} else if ( ( splitPolygon2.classification == CONVEX_CCW || splitPolygon2.classification == CONVEX_CW ) )
								{
									if ( area2 > bestArea )
									{
										bestArea = area2;
										bestSplitPolygon1 = splitPolygon1;
										bestSplitPolygon2 = splitPolygon2;
									}
								} 
							}
						}
					}
				}
				
				if ( ( bestSplitPolygon1.classification == CONVEX_CCW || bestSplitPolygon1.classification == CONVEX_CW ) )
				{
						result.splice( index, 1 );
						result.unshift( bestSplitPolygon1 );
						if ( ( bestSplitPolygon2.classification == CONVEX_CCW || bestSplitPolygon2.classification == CONVEX_CW ) )
						{
							result.unshift( bestSplitPolygon2 );
						} else {
							result.push( bestSplitPolygon2 );
						}
						index++;
				} else if ( ( bestSplitPolygon2.classification == CONVEX_CCW || bestSplitPolygon2.classification == CONVEX_CW ) )
				{
					result.splice( index, 1 );
					result.unshift( bestSplitPolygon2 );
					result.push( bestSplitPolygon1 );	
					index++;
									
				} 
			}
			
			return result;
		}
		
		
		public function getConvexPolygons_biggestAngle():Vector.<Polygon>
		{
			var result:Vector.<Polygon> = Vector.<Polygon>([ clone() ]);
			
			var index:int = 0;
			var currentPolygon:Polygon;
			var splitPolygon1:Polygon;
			var splitPolygon2:Polygon;
			
			var i:int, j:int, k:int;
			var splits:Vector.<Polygon>;
			var splitLine:LineSegment;
			var selfIntersection:Intersection;
			var currentArea:Number;
			var area1:Number;
			var area2:Number;
			var angle1:Number;
			var angle2:Number;
			
			var areaToleranceFactor:Number = 0.01;
			var areaTolerance:Number;
			
			
			var bestAngle:Number;
			var bestSplitPolygon1:Polygon;
			var bestSplitPolygon2:Polygon;
			
			while( index < result.length && ( result[index].classification != CONVEX_CCW && result[index].classification != CONVEX_CW ) )
			{
				currentPolygon = result[index];
				currentArea = Math.abs( currentPolygon.area );
				areaTolerance = currentArea * areaToleranceFactor;
				bestAngle = 0;
				
				for ( i = 0; i < currentPolygon.pointCount - 2; i++ )
				{
					for ( j = i + 2; j < currentPolygon.pointCount; j++ )
					{
						
						if ( i == 0 && j == currentPolygon.pointCount - 1  ) continue;
			
						splitLine = new LineSegment( currentPolygon.getPointAt(i), currentPolygon.getPointAt( j ) );
						
						selfIntersection = currentPolygon.intersect( splitLine );
						
						if ( selfIntersection.points.length == 2 )
						{
							splits = currentPolygon.getSplit( i, j );
							if ( splits.length == 0 ) continue;
							
							splitPolygon1 = splits[0];
							splitPolygon2 = splits[1];
							
							if ( Math.abs(currentArea -(  Math.abs( splitPolygon1.area ) +  Math.abs( splitPolygon2.area ))) < areaTolerance )
							{
								angle1 = splitPolygon1.getSmallestAngle();
								angle2 = splitPolygon2.getSmallestAngle();
							
								if ( ( splitPolygon1.classification == CONVEX_CCW || splitPolygon1.classification == CONVEX_CW ) )
								{
									if ( ( splitPolygon2.classification == CONVEX_CCW || splitPolygon2.classification == CONVEX_CW ) )
									{
										if ( Math.max(angle1,angle2) > bestAngle )
										{
											bestAngle = Math.min(angle1,angle2);
											bestSplitPolygon1 = splitPolygon1;
											bestSplitPolygon2 = splitPolygon2;
										}
									} else {
										if (angle1 > bestAngle )
										{
											bestAngle = angle1;
											bestSplitPolygon1 = splitPolygon1;
											bestSplitPolygon2 = splitPolygon2;
										}
									}
									
								} else if ( ( splitPolygon2.classification == CONVEX_CCW || splitPolygon2.classification == CONVEX_CW ) )
								{
									if (  angle2 > bestAngle )
									{
										bestAngle = angle2;
										bestSplitPolygon1 = splitPolygon1;
										bestSplitPolygon2 = splitPolygon2;
									}
								} 
							}
						}
					}
				}
				
				if ( bestSplitPolygon1 != null && ( bestSplitPolygon1.classification == CONVEX_CCW || bestSplitPolygon1.classification == CONVEX_CW ) )
				{
						result.splice( index, 1 );
						result.unshift( bestSplitPolygon1 );
						if ( ( bestSplitPolygon2.classification == CONVEX_CCW || bestSplitPolygon2.classification == CONVEX_CW ) )
						{
							result.unshift( bestSplitPolygon2 );
						} else {
							result.push( bestSplitPolygon2 );
						}
						index++;
				} else if (  bestSplitPolygon2 != null && ( bestSplitPolygon2.classification == CONVEX_CCW || bestSplitPolygon2.classification == CONVEX_CW ) )
				{
					result.splice( index, 1 );
					result.unshift( bestSplitPolygon2 );
					result.push( bestSplitPolygon1 );	
					index++;
									
				} 
			}
			
			return result;
		}
		
		
		public function get classification():String
		{
			if ( dirty )
			{
				update();
			}
			return __classification;
		}
		
		public function get selfIntersects():Boolean
		{
			if ( dirty )
			{
				update();
			}
			return __selfIntersects;
		}
		
		override public function clone(deepClone:Boolean = true ):GeometricShape
		{
			if ( deepClone )
			{
				var tmp:Vector.<Vector2> = new Vector.<Vector2>();
				for ( var i:int = 0; i < points.length; i++ )
				{
					tmp.push( points[i].getClone() );
				}
				return Polygon.fromVector( tmp );
			} else {
				return Polygon.fromVector( points );
			}
		}
		
		override public function get length():Number
		{
			return circumference;
		}
		
		public function get pointCount():int
		{
			return points.length;
		}
		
		public function get circumference():Number
		{
			var result:Number = 0;
			for ( var i:int = 0; i< points.length; i++ )
			{
				result += getSide(i).length;
			}
			return result;
		}
		
		override public function getPointAtOffset( t:Number ):Vector2
		{
		    t %= 1;
		    if ( t<0) t+= 1;
		    
			var side:LineSegment;
			var totalLength:Number = circumference;
			var t_sub:Number;
			
			for ( var i:int = 0; i< points.length; i++ )
			{
				side =  getSide(i);
				t_sub = side.length / totalLength;
				if ( t > t_sub )
				{
				 	t-= t_sub;
				}else {
					return side.getPoint( t / t_sub );
				}
			}
			return null;
		}
		
		public function getSide( index:int ):LineSegment
		{
			index = ( index % points.length + points.length) % points.length;
			return new LineSegment( points[index], points[int((index+1)% points.length)] );
		}
		
		public function squaredDistanceToPoint( p:Vector2 ):Number
		{
			var minDist:Number = getSide( 0 ).getClosestPoint( p ).squaredDistanceToVector( p );
			var dist:Number;
			for ( var i:int = 1; i < points.length; i++ )
			{
				dist = getSide( i ).getClosestPoint( p ).squaredDistanceToVector( p );
				if ( dist < minDist ) minDist = dist;
			}
			return minDist;
		}
		
		override public function getClosestPoint( p:Vector2 ):Vector2
		{
			var closest:Vector2 = getSide( 0 ).getClosestPoint( p );
			var minDist:Number = closest.squaredDistanceToVector( p );
			var dist:Number;
			var pt:Vector2;
			for ( var i:int = 1; i < points.length; i++ )
			{
				pt = getSide( i ).getClosestPoint( p );
				dist = pt.squaredDistanceToVector( p );
				if ( dist < minDist ) {
					minDist = dist ;
					closest = pt;
				}
			}
			return closest;
		}
		
		public function distanceToVector2( p:Vector2 ):Number
		{
			var closest:Vector2 = getSide( 0 ).getClosestPoint( p );
			var minDist:Number = closest.squaredDistanceToVector( p );
			var dist:Number;
			var pt:Vector2;
			for ( var i:int = 1; i < points.length; i++ )
			{
				pt = getSide( i ).getClosestPoint( p );
				dist = pt.squaredDistanceToVector( p );
				if ( dist < minDist ) {
					minDist = dist ;
				}
			}
			return Math.sqrt( minDist);
		}
		
		public function getClosestIndexToClosestPoint( p:Vector2 ):int
		{
			var closest:Vector2 = getSide( 0 ).getClosestPoint( p );
			var closestIndex:int = 0;
			var minDist:Number = closest.squaredDistanceToVector( p );
			var dist:Number;
			var pt:Vector2;
			for ( var i:int = 1; i < points.length; i++ )
			{
				pt = getSide( i ).getClosestPoint( p );
				dist = pt.squaredDistanceToVector( p );
				if ( dist < minDist ) {
					minDist = dist ;
					closestIndex = i;
					closest = pt;
				}
			}
			
			var p1:Vector2 = getPointAt( closestIndex );
			var p2:Vector2 = getPointAt( closestIndex+1 );
			if ( p1.squaredDistanceToVector( closest ) < p2.squaredDistanceToVector( closest ))
			{
				return closestIndex
			}
			
			return closestIndex+1;
		}
		
		public function getClosestSideIndex( p:Vector2 ):int
		{
			var closestIndex:int = 0;
			var minDist:Number = getSide( closestIndex ).getClosestPoint( p ).squaredDistanceToVector( p );
			var dist:Number;
			var pt:Vector2;
			for ( var i:int = 1; i < points.length; i++ )
			{
				pt = getSide( i ).getClosestPoint( p );
				dist = pt.squaredDistanceToVector( p );
				if ( dist < minDist ) {
					minDist = dist ;
					closestIndex = i;
				}
			}
			return closestIndex;
		}
		
		public function getClosestConnectionToLine( l:LineSegment ):LineSegment
		{
			var shortest:LineSegment = getSide( 0 ).getShortestConnectionToLine( l );
			var connection:LineSegment;
			if (shortest.length == 0 ) return shortest;
			for ( var i:int = 1; i < points.length; i++ )
			{
				connection = getSide( i ).getShortestConnectionToLine( l );
				if ( connection.length < shortest.length )
				{
					if (shortest.length == 0 ) return shortest;
					shortest = connection;
				} 
			}
			return shortest;
		}
		
		public function getClosestIndex( v:Vector2 ):int
		{
			var nearest:KDTreeNode = tree.findNearestFor( v );
			if (  nearest != null )
			{
				for ( var i:int = points.length; --i>-1;)
				{
					if ( points[i] == nearest.point ) return i;
				}
			}
			return -1;
		}
		
		
		public function distanceToLine( l:LineSegment ):Number
		{
			return getClosestConnectionToLine( l ).length;
		}
		
		public function getSmallestAngle():Number
		{
			var smallestAngle:Number = 10; // > Math.PI * 2;
			var angle:Number;
			var p:Vector2;
			for ( var i:int = 0; i < points.length; i++ )
			{
				p = getPointAt(i);
				angle = (getPointAt(i-1).getMinus(p).angleBetween( getPointAt(i+1).getMinus(p) ) + Math.PI * 2) % (Math.PI * 2);
				if ( angle < smallestAngle )
				{
					smallestAngle = angle;
				}
			}
			return smallestAngle;
		}
		
		public function convexHull():ConvexPolygon
		{
			return ConvexPolygon.fromVector( points );
		}
		
		
		public function getOffsetPolygon( offset:Number ):Polygon
		{
			var f:Number = area > 0 ? 1 : -1;
			var poly:Polygon = new Polygon();
			
			for ( var i:int; i < points.length; i++ )
			{
				var norm:Vector2 = getNormalAtIndex( i, 10 );
				var l1:LineSegment = new LineSegment( points[i].getMinus(norm), points[i].getPlus(norm) );
				var l2:LineSegment = getSide( i ).getParallel( -offset * f);
				var intersection:Vector.<Vector2> = l1.getIntersection(l2);
				if ( intersection.length > 0 ) poly.addPoint(intersection[0]);
			}
			
			return poly;
		}
		
		
		public function getOffsetPolygons( offset:Number ):Vector.<Polygon>
		{
			var poly1:Polygon = getOffsetPolygon( Math.abs(offset) );
			var poly2:Polygon = getOffsetPolygon( -Math.abs(offset) );
			var result:Vector.<Polygon> = new Vector.<Polygon>();
			result.push(poly1);
			if ( Math.abs(poly1.area) < Math.abs(poly2.area)) result.push(poly2);
			else result.unshift(poly2);
			return result;
		}
		
		private function update():void
		{
			__classification = updateClassification();
			__selfIntersects = updateSelfIntersection();
			dirty = false;
		}
		
		private function updateClassification():String
		{
			var curDir:int, thisDir:int, thisSign:int, dirChanges:int = 0, angleSign:int = 0, iread:int ;
		    var cross:Number;
		  	var pCount:int = pointCount;
		   
		    if ( points.length < 3 ) return CONVEX_DEGENERATE;
		   
		   	var index:int = 0;
		   	
		    var first:Vector2  = points[index++];
			var second:Vector2 = points[index++];
		    var third:Vector2;
		    
		    curDir = first.compare( second );
			
			while( index < pCount + 2 )
			{
				third = points[int(index%points.length)];
				if ( (thisDir = second.compare(third)) == -curDir )		
			    ++dirChanges;						
				curDir = thisDir;		
				thisSign = third.windingDirection( first,second )				
				if ( thisSign ) {		
				    if ( angleSign == -thisSign )
					{
						return area > 0 ? NON_CONVEX_CCW : NON_CONVEX_CW;					
					}
					angleSign = thisSign;					
				}								
				first = second; 
				second = third;
				index++;
		    }
		    
		    /* Decide on polygon type given accumulated status */
		    if ( dirChanges > 2 ) return angleSign ? ( area > 0 ? NON_CONVEX_CCW : NON_CONVEX_CW ) : NON_CONVEX_DEGENERATE;
		
		    if ( angleSign > 0 ) return CONVEX_CCW;
		    if ( angleSign < 0 ) return CONVEX_CW;
		    return CONVEX_DEGENERATE;
		}
		
		private function updateSelfIntersection():Boolean
		{
			 if ( points.length < 4 ) return false;
			 var pCount:int = pointCount;
		     var side1:LineSegment;
		     var side2:LineSegment;
		    
			 for ( var i:int = 0; i < pCount - 2; i++ )
			 {
			 	side1 = getSide( i );
			 	for ( var j:int = i+2; j < pCount; j++ )
			 	{
			 		if ( (j+1) % pCount != i && side1.crosses(getSide(j)) )
			 		{
						//side1.intersect( getSide(j) ).status == Intersection.INTERSECTION
			 			selfIntersectionIndex_side1 = i
						selfIntersectionIndex_side2 = j;
		 				return true;
			 		}
			 	}	
			 	
			 }
			 return false;
		}
		
		public function getCubicBezierPath( smoothFactor:Number ):MixedPath
		{
			var path:MixedPath = new MixedPath();
			var p0:Vector2, p1:Vector2, p2:Vector2, p3:Vector2;
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				p0 = points[ int((i-4+2*points.length) % points.length)];
				p1 = points[ int((i-3+2*points.length) % points.length)];
				p2 = points[ int((i-2+2*points.length) % points.length)];
				p3 = points[ int((i-1+2*points.length) % points.length)];
				
				var v0:Vector2 = p0.getMinus( p1 );
				var v1:Vector2 = p1.getMinus( p2 );
				
				var tangentLength:Number = v1.length * smoothFactor;
				v1.newLength( v0.length );
				v0 = p1.getPlus( v0 ).lerp( p1.getPlus( v1 ), 0.5 ).minus(p1);
				v0.newLength(tangentLength );
				
				v1 = p1.getMinus( p2 );
				var v2:Vector2 = p2.getMinus( p3 );
				
				tangentLength =  v1.length * smoothFactor;
				var tangentLength2:Number =  v2.length * smoothFactor;
				v2.newLength( v1.length );
				v1 = p2.getPlus( v1 ).lerp( p2.getPlus( v2 ), 0.5 ).minus(p2);
				v1.newLength(tangentLength );
				
				path.addPoint( p1 );
				path.addControlPoint( p1.getMinus(v0) );
				path.addControlPoint( p2.getPlus( v1 ) );
			}
			
			path.setClosed( true );
			
			return path;	
		}
		
		public function getSmoothPath( factor:Number, mode:int = 0):MixedPath
		{
			var mp:MixedPath = LinearPath.fromVector( points, true ).getSmoothPath( factor, mode, true );
			return mp;
		}
		
		public function getHatchingPath( distance:Number, angle:Number, offsetFactor:Number, mode:String = HatchingMode.ZIGZAG ):LinearPath
		{
			if ( distance == 0 ) return null;
			distance = Math.abs( distance );
			angle %= Math.PI;
			offsetFactor %= 2;
			
			var bounds:Rectangle = getBoundingRect();
			var lineLength:Number = 3 * Math.sqrt( bounds.width * bounds.width + bounds.height *  bounds.height );
			
			
			var center:Vector2 = centroid;
			var line:LineSegment = LineSegment.fromPointAndAngleAndLength( center, angle,lineLength,true);
			var normalOffset:Vector2 = line.getNormalAtPoint( center );
			
			var sortedPoints:Array = [];
			for ( var i:int = 0; i < points.length; i++ )
			{
				var offset:Number = line.distanceToPoint( points[i]);
				var direction:Number = ( line.isLeft( points[i] ) > 0 ? 1 : -1 );
				sortedPoints.push( { index:i, d: direction * offset } );
			}
			
			sortedPoints.sort( function( a:Object, b:Object ):int{
				if ( a.d > b.d ) return 1;
				if ( a.d < b.d ) return -1;
				return 0;
			});
			
			
			var startIndex:int = sortedPoints[0].index;
			var endIndex:int = sortedPoints[sortedPoints.length-1].index ;
			
			var pts:Intersection;
			var middle:Vector2;
			var startLength:Number =  - (Math.abs(sortedPoints[0].d) - (Math.abs(sortedPoints[0].d) % distance) - distance * offsetFactor);
			
			normalOffset.newLength( startLength );
			line.translate( normalOffset );
			normalOffset.newLength(-distance);
			
			
			var path:LinearPath = new LinearPath();
			var zigzag:int = 0;
			var startLeft:Boolean = ( Math.abs(startLength) % (distance * 4 ) < distance * 2 );
			
			var maxIterations:int = 2 + points[startIndex].distanceToVector(points[endIndex]) / distance;
			while ( maxIterations-- > -1)
			{
				pts = this.intersect( line );
				if ( pts.points.length == 2) 
				{
					middle = pts.points[0].getLerp( pts.points[1], 0.5 );
					if ( (pts.points[0].isLeft(middle,middle.getPlus(normalOffset)) < 0) == startLeft )
					{
						var tmp:Vector2 = pts.points[0];
						pts.points[0] = pts.points[1];
						pts.points[1] = tmp;
					}
					
					path.addPoint(pts.points[1-zigzag]);
					if ( mode != HatchingMode.SAWTOOTH ) path.addPoint(pts.points[zigzag]);
					if ( mode != HatchingMode.CRISSCROSS	) zigzag = 1 - zigzag;
				}
				line.translate( normalOffset );
			}
			
			return path;
		}
		
		public function getScribblePath( minFactor:Number, maxFactor:Number ):MixedPath
		{
			var path:MixedPath = new MixedPath();
			var p0:Vector2, p1:Vector2, p2:Vector2, p3:Vector2;
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				p0 = points[ int((i-4+2*points.length) % points.length)];
				p1 = points[ int((i-3+2*points.length) % points.length)];
				p2 = points[ int((i-2+2*points.length) % points.length)];
				p3 = points[ int((i-1+2*points.length) % points.length)];
				
				var v0:Vector2 = p0.getMinus( p1 );
				var v1:Vector2 = p1.getMinus( p2 );
				
				var tangentLength:Number = v1.length * ( minFactor + Math.random() * ( maxFactor - minFactor ) );
				v1.newLength( v0.length );
				v0 = p1.getPlus( v0 ).lerp( p1.getPlus( v1 ), 0.5 ).minus(p1);
				v0.newLength(tangentLength );
				
				v1 = p1.getMinus( p2 );
				var v2:Vector2 = p2.getMinus( p3 );
				
				tangentLength =  v1.length * ( minFactor + Math.random() * ( maxFactor - minFactor ) );
				var tangentLength2:Number =  v2.length * ( minFactor + Math.random() * ( maxFactor - minFactor ) );
				v2.newLength( v1.length );
				v1 = p2.getPlus( v1 ).lerp( p2.getPlus( v2 ), 0.5 ).minus(p2);
				v1.newLength(tangentLength );
				
				path.addPoint( p1 );
				path.addControlPoint( p1.getMinus(v0) );
				path.addControlPoint( p2.getPlus( v1 ) );
			}
			
			path.setClosed( true );
			
			return path;	
		}
		
		public function blur( radius:uint, falloff:Number = 0.5, extrapolate:Number = 1, keepCentroidDistance:Boolean = false, centroidFactor:Number = 1.0 ):void
		{
			if ( radius == 0 ) return;
			var blurredPoints:Vector.<Vector2> = new Vector.<Vector2>();
			var factor:Number;
			for ( var i:int = 0; i < points.length; i++ )
			{
				factor = 1;
				var sumPoint:Vector2 = points[i].getClone();
				var sum:Number = factor;
				for ( var j:int = 0; j < radius; j++ )
				{
					factor *= falloff;
					var p:Vector2 = getPointAt( i+j);
					sumPoint.x += p.x * factor;
					sumPoint.y += p.y * factor;
					p = getPointAt( i-j);
					sumPoint.x += p.x * factor;
					sumPoint.y += p.y * factor;
					sum += 2 * factor;
				}
				blurredPoints.push( sumPoint );
			}
			
			sum = 1 / sum;
			for ( i = 0; i < points.length; i++ )
			{
				blurredPoints[i].multiply( sum ); 
			}
			
			if ( keepCentroidDistance )
			{
				var sx:Number = 0;
				var sy:Number = 0;
				var a:Number = 0;
				for ( i = 0; i< blurredPoints.length; i++ )
				{
					var p1:Vector2 = blurredPoints[i];
					var p2:Vector2 = blurredPoints[int((i+1) % blurredPoints.length)];
					a += ( f = p1.x * p2.y - p2.x * p1.y );
					sx += (p1.x + p2.x) * f;
					sy += (p1.y + p2.y) * f;
				}
				if ( a != 0 )
				{
					var f:Number = 1 / ( 3 * a );
					var newCentroid:Vector2 = new Vector2( sx * f, sy * f );
				} else {
					newCentroid = centroid.getClone();
				}
				var c:Vector2 = centroid;
				
				for ( i = 0; i < points.length; i++ )
				{
					var d:Number = centroidFactor * c.distanceToVector( points[i] ) + ( 1 - centroidFactor ) * newCentroid.distanceToVector(blurredPoints[i]);
					
					blurredPoints[i].minus(newCentroid).newLength( d ).plus(c);
				}
			}
			for ( i = 0; i < points.length; i++ )
			{
				points[i].x += extrapolate * (blurredPoints[i].x - points[i].x);
				points[i].y += extrapolate * (blurredPoints[i].y - points[i].y);
			}
			
			
			dirty = true;
		}
		
		public function joinNeighbors( radius:Number = 1 ):void
		{
			
			var r2:Number = radius * radius;
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( points[i].snaps( points[ (i + 1) % points.length] , r2 ) )
				{
					points[i].lerp(	points[ (i + 1) % points.length], 0.5 );
					points.splice((i + 1) % points.length,1);
					i--;
					dirty = true;
				}
			}
			
		}
		
		override public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
			var p:Vector2 = points[0];
			var minX:Number = p.x;
			var maxX:Number = minX;
			var minY:Number = p.y;
			var maxY:Number = minY;
			for ( var i:int = 1; i< points.length; i++ )
			{
				p = points[i];
				if ( p.x < minX ) minX = p.x;
				else if ( p.x > maxX ) maxX = p.x;
				if ( p.y < minY ) minY = p.y;
				else if ( p.y > maxY ) maxY = p.y;
			}
			
			return new Rectangle( minX, minY, maxX - minX, maxY - minY );
		}
		
		override public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			if ( points.length < 3 ) return false;
			
			if ( hasPoint( p ) ) return includeVertices;
			
			if ( getClosestPoint( p ).squaredDistanceToVector( p ) < SNAP_DISTANCE * SNAP_DISTANCE ) return includeVertices;
			
			var i:int, n:int = points.length;
			
			// due to some topology theorem, if the ray intersects shape
			// perimeter odd number of times, the point is inside
			
			// shorter and faster code thanks to Alluvian
			// http://board.flashkit.com/board/showpost.php?p=4037392&postcount=5
			
			var V:Vector.<Vector2> = points.concat(); 
			V.push (V[0]);
			
			var crossing:int = 0; 
			n = V.length - 1;
			for (i = 0; i < n; i++) 
			{
				if (((V[i].y <= p.y) && (V[i+1].y > p.y)) || ((V[i].y > p.y) && (V[i+1].y <= p.y)))
				{
					var vt:Number = (p.y - V[i].y) / (V[i+1].y - V[i].y);
					if (p.x < V[i].x + vt * (V[i+1].x - V[i].x)) {
						crossing++;
					}
				}
			}
			
			return (crossing % 2 != 0);
			
			
		}
		
		override public function draw( canvas:Graphics ):void
		{
			
			if ( points.length > 0 )
			{
				canvas.moveTo( points[int(points.length-1)].x, points[int(points.length-1)].y );
				for (var i:int=0; i < points.length; i++ )
				{
					canvas.lineTo( points[i].x, points[i].y );
				}
			} 
		}
		
		override public function export( canvas:IGraphics ):void
		{
			
			if ( points.length > 0 )
			{
				canvas.moveTo( points[int(points.length-1)].x, points[int(points.length-1)].y );
				for (var i:int=0; i < points.length; i++ )
				{
					canvas.lineTo( points[i].x, points[i].y );
				}
			} 
		}
		
		
		public function drawWithOffset( canvas:Graphics, offset:Vector2 ):void
		{
			
			if ( points.length > 0 )
			{
				canvas.moveTo( points[int(points.length-1)].x + offset.x, points[int(points.length-1)].y + offset.y);
				for (var i:int=0; i < points.length; i++ )
				{
					canvas.lineTo( points[i].x + offset.x, points[i].y + offset.y);
				}
			} 
		}
		
		public function getLinearPathSegment( startIndex:int, endIndex:int, clonePoints:Boolean = true ):LinearPath
		{
			endIndex = ((endIndex % pointCount )+ pointCount) % pointCount;
			var p:LinearPath = new LinearPath();
			var index:int = startIndex;
			while ( index != endIndex )
			{
				p.addPoint( clonePoints ? getPointAt( index ).getClone() : getPointAt( index ) );
				index = (index+1) % pointCount;
			}
			p.addPoint( clonePoints ? getPointAt( index ).getClone() : getPointAt( index ) );
			return p;
		}
		
		public function invalidate():void
		{
			dirty = true;
		}
		
		override public function translate( offset:Vector2 ):GeometricShape
		{
			for each ( var p:Vector2 in points )
			{
				p.plus(offset);
			}
			dirty = true;
			return this;
		}
		
		override public function scale( factorX:Number, factorY:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = centroid;
			for each ( var p:Vector2 in points )
			{
				p.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			}
			return this;
		}
		
		override public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = centroid;
			for each ( var p:Vector2 in points )
			{
				p.rotateAround(angle, center );
			}
			dirty = true;
			return this;
		}
		
		public function getBoundingCircle( method:int = BoundingCircle.BOUNDINGCIRCLE_EXACT):Circle
		{
			switch ( method )
			{
				case BoundingCircle.BOUNDINGCIRCLE_SIMPLE:
					return BoundingCircle.boundingCircle1( points );
				break;
				case BoundingCircle.BOUNDINGCIRCLE_EFFICIENT:
					return BoundingCircle.boundingCircle2( points );
				break;
				case BoundingCircle.BOUNDINGCIRCLE_EXACT:
					return BoundingCircle.boundingCircle3( points );
				break;
			}
			return null;
		}
		
		public function getTurningProfile( stepSize:Number = 1, center:Vector2 = null ):Vector.<Number>
		{
			if ( center == null ) center = centroid;
			var result:Vector.<Number> = new Vector.<Number>;
			var tstep:Number = stepSize / length;
			for ( var t:Number = 0; t < 1; t+= tstep )
			{
				result.push( center.angleTo( getPoint(t)) );
			}
			return result;
		}
		
		public function getNormalizedAngleProfile( bins:int = 256 ):Vector.<Number>
		{
			var angles:Vector.<Number> = new Vector.<Number>();
			var lengths:Vector.<Number> = new Vector.<Number>();
			var accumulatedLength:Number = 0;
			var lastAngle:Number = getSide(0).angle;
			for ( var i:int = 0; i < pointCount; i++)
			{
				var s:LineSegment = getSide(i);
				angles.push( lastAngle - s.angle );
				lastAngle = s.angle;
				accumulatedLength += s.length;
				lengths.push( accumulatedLength );
			}
			
			var result:Vector.<Number> = new Vector.<Number>();
			var currentAngle:Number = 0;
			var step:Number = 0;
			var maxStep:Number = length;
			var stepSize:Number = maxStep / bins;
			var currentIndex:int = 0;
			while ( step < maxStep )
			{
				while ( step > lengths[currentIndex] )
				{
					currentIndex++;
					currentAngle = angles[currentIndex];
				}
				result.push( currentAngle );
				step += stepSize;
			}
			
			return result;
		}
		
		public function get majorAngle():Number
		{
			var centerOfMass:Vector2 = centroid;
			
			var dx_sum:Number = 0;
			var dy_sum:Number = 0;
			var dxy_sum:Number = 0;
			
			for each ( var p:Vector2 in points )
			{
				dx_sum += Math.pow(p.x - centerOfMass.x,2);
				dy_sum += Math.pow(p.y - centerOfMass.y,2);
				dxy_sum += (p.x - centerOfMass.x) * (p.y - centerOfMass.y)
			}
			var dy:Number = 2*dxy_sum;
			var dx:Number = dx_sum  - dy_sum + Math.sqrt(Math.pow(dx_sum-dy_sum,2) + Math.pow(2 * dxy_sum,2) );
			if ( dy == 0 && dx == 0 )
			{
				return ( dx_sum >= dy_sum ? 0 : Math.PI * 0.5 );
			}
			return Math.atan2( dy, dx );
		}
		
		public function detangle():void
		{
			var result:Vector.<Vector2> = new Vector.<Vector2>();
			var temp:Vector.<Vector2> = new Vector.<Vector2>();
			
			var lowerIndex:int, upperIndex:int, i:int;
		
			while ( selfIntersects )
			{
				result.length = 0;
			
				lowerIndex = Math.min( selfIntersectionIndex_side1, selfIntersectionIndex_side2 )+1 ;
				upperIndex = Math.max( selfIntersectionIndex_side1, selfIntersectionIndex_side2 )+1;
			
				for ( i = lowerIndex; i < upperIndex; i++ )
				{
					result.push( points[i % points.length ] );
				}
			
				temp.length = 0
				for ( i = upperIndex; i < points.length; i++ )
				{
					temp.push( points[i] );
				}
				for ( i = 0; i < lowerIndex; i++ )
				{
					temp.push( points[i] );
				}
				temp.reverse();
			
				for ( i = 0; i < temp.length; i++ )
				{
					result.push( temp[i] );
				}
				if ( points.length != result.length )
				{
					throw new Error("wrong length");
				}
				points = result.concat();
				dirty = true;
			}
		}
		
		private function cleanEdges():void
		{
			var ok:Boolean, i:int, n:int;
			do
			{
				ok = true;
				n = pointCount;
				for (i = 0; i < n; i++)
				{
					if ( getPointAt(i).squaredDistanceToVector(getPointAt(i+1)) < SNAP_DISTANCE * SNAP_DISTANCE )
					{
						points.splice (((i + 1) % n == 0) ? 0 : i, 2); 
						i = n; 
						ok = false;
						dirty = true;
					}
				}
			}
			while (!ok);
		}
		
		public function drawIntersectingEdges( g:Graphics):void
		{
			if ( !selfIntersects ) return;
			
			getSide(selfIntersectionIndex_side1).draw(g);
			getSide(selfIntersectionIndex_side2).draw(g);
			
			var lowerIndex:int = Math.min( selfIntersectionIndex_side1, selfIntersectionIndex_side2 )+1 ;
			var upperIndex:int = Math.max( selfIntersectionIndex_side1, selfIntersectionIndex_side2 );
			
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( i < lowerIndex || i > upperIndex )
				getPointAt(i).draw(g,4);
			}
			
		}
		
		
		public function toMixedPath( clonePoints:Boolean = false):MixedPath
		{
			var path:MixedPath = new MixedPath();
			for ( var i:int = 0; i < points.length; i++ )
			{
				path.addPoint( clonePoints ? points[i].getClone() : points[i] );
			}
			path.setClosed(true);
			return path;
		}
		
		public function getCopyOfPoints():Vector.<Vector2>
		{
			return points.concat();
		}
		
		public function fractalize( factor:Number = 0.5, range:Number = 0.5, minSegmentLength:Number = 2, iterations:int = 1 ):void
		{
			for ( var j:int = 0; j < iterations; j++)
			{
				for ( var i:int = 0; i < points.length; i++ )
				{
					var p1:Vector2 = points[i];
					var p2:Vector2 = points[int((i+1)%points.length)];
					var l:Number = p1.distanceToVector( p2 );
					if ( l >= minSegmentLength )
					{
						var m:Vector2 = p1.getLerp( p2, 0.5 + Math.random() * range - range * 0.5 );
						var n:Vector2 = p1.getMinus(p2);
						n.multiply( Math.random() * factor ).rotateBy( Math.PI * 0.5 );
						if ( Math.random() < 0.5 ) n.multiply(-1);
						m.plus( n );
						addPointAt( i+1, m );
						i++;
					}
				}
			}
			detangle();
		}
		
		public function getAngleAt( index:int ):Number
		{
			return getPointAt( index ).cornerAngle( getPointAt( index-1 ), getPointAt( index+1 ));
		}
		
		public function simplify( threshold:Number ):void
		{
			var run:Boolean = true;
			var i1:int = 0;
			var bestLineRun:int;
			var lineOK:Boolean;
			var i2:int;
			var reducedPoints:Vector.<Vector2> = new Vector.<Vector2>();
			
			var d:Number, x:Number, y:Number, dx:Number, dy:Number;
			var px:Number, py:Number, p1x:Number, p2x:Number, p1y:Number, p2y:Number;
			var slope1:Number, slope2:Number;
			var p:Vector2, p1:Vector2, p2:Vector2;
			var i:int;
			var count:int = points.length;
			
			p1 = points[ 0 ] ;
			p1x = p1.x;
			p1y = p1.y;
			
			while (run)
			{
				bestLineRun = 1;
				lineOK = true;
				while (lineOK)
				{
					bestLineRun++;
					i2 = i1 + bestLineRun;
					if ( i2 < count + 1 )
					{
						p2 = points[ int( i2 % count )];
						p2x = p2.x;
						p2y = p2.y;
						
						if ( p1x != p2x)
						{
							slope1 = (p1y - p2y) / ( p1x - p2x );
							slope2 = - 1 / slope1;
						}
						
						for ( i = i1 + 1; i < i2;i++)
						{
							p = points[ int( i % count )];			  
							px = p.x;
							py = p.y;
							
							if ( p1x == p2x)
							{
								x = p1x;
								y = py;
							} else if ( p1y == p2y)
							{
								x = px;
								y = p1y;
							} else
							{
								x = ( -1 * slope2 * px + py - p1y + slope1 * p1x) / ( slope1 - slope2 );
								y = slope1 * ( x - p1x ) + p1y;
							}
							
							dx = x - px;
							dy = y - py;
							
							d = dx * dx + dy * dy;			  
							
							if ( d > threshold)
							{
								lineOK = false;
								break;
							}
						}
						
					} else {
						lineOK = false;
					}
				}
				bestLineRun--;
				reducedPoints.push( p1 );
				i1 += bestLineRun;
				
				p1 = points[ int( i1 % count )] ;
				p1x = p1.x;
				p1y = p1.y;
				
				if (i1 >= count ) run = false;
			}
			
			points = reducedPoints.concat();
			dirty = true;	
		}
		
		public function getSlices( l:LineSegment ):Vector.<Polygon>
		{
			var mesh:LinearMesh = new LinearMesh();
			mesh.addPolygon( Polygon(clone(true)) );
			var ls:LineSegment = LineSegment(l.clone( true ));
			var bounds:Rectangle = getBoundingRect();
			ls.fit( bounds.x, bounds.x + bounds.width, bounds.y, bounds.y + bounds.height );
			mesh.addLineSegment( ls );
			var polys:Vector.<Polygon> = mesh.getPolygons();
			for ( var i:int = polys.length; --i > -1; )
			{
				for ( var j:int = 0; j < polys[i].pointCount; j++ )
				{
					if ( !isInside( polys[i].getSide(j).getPoint(0.5), true ) )
					{
						polys.splice( i,1);
						break;
					}
				}
				
			}
			return polys;
		}
		
		override public function reflect( lineSegment:LineSegment ):GeometricShape
		{
			for ( var i:int = 0; i < points.length; i++ )
			{
				points[i] = lineSegment.mirrorPoint( points[i] );
			}
			dirty = true;
			return this;
		}
		
		override public function get type():String
		{
			return "Polygon";
		}
		
		public function toString():String
		{
			return "Polygon.fromArray(["+points.toString()+"])";
		}
		
		public function toXML():XML
		{
			var xml:XML = <Polygon points=""/>;
			var pts:Array = [];
			for ( var i:int = 0; i < points.length; i++ )
			{
				pts.push(" "+points[i].x,points[i].y);
			}
			xml.@points = pts.toString();
			return xml;
		}
		
	}
}