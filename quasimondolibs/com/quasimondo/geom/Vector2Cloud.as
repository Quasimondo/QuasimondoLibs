package com.quasimondo.geom
{
	
	import com.quasimondo.geom.pointStructures.BalancingKDTree;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class Vector2Cloud
	{
		public var points:Vector.<Vector2>;
		
		private var sum:Vector2;
		private var _centroid:Vector2;
		private var covariance:CovarianceMatrix2;
		private var _majorAngle:Number;
		
		private var dirty:Boolean = true;
		private var centroidDirty:Boolean = true;
		
		private var tree:BalancingKDTree;
		private var treeDirty:Boolean;
	
		static private const NUM_STANDARD_DEVIATIONS:Number = 1.7;
		
		public static function fromVector( points:Vector.<Vector2>, clonePoints:Boolean = false ):Vector2Cloud
		{
			var vc:Vector2Cloud = new Vector2Cloud();
			if ( !clonePoints )
			{
				vc.points = points.concat();
				for each ( var point:Vector2 in points )
				{
					vc.sum.plus( point );
				}
			} else {
				for ( var i:int = 0; i < points.length; i++ )
				{
					vc.accumulate( points[i].getClone() );
				}
			}
			
			return vc;
		}
		
		public function Vector2Cloud()
		{
			clear();
		}
		
		public function clear():void
		{
			if ( points == null )
				points = new Vector.<Vector2>();
			else 
				points.length = 0;
			
			sum = new Vector2();
			_centroid = new Vector2();
			covariance = new CovarianceMatrix2();
			_majorAngle = 0;
			dirty = centroidDirty = true;
			tree = new BalancingKDTree();
			treeDirty = false;
		}
		
		
		public function accumulate( vector:Vector2 ):void
		{
			points.push( vector );
			sum.plus( vector );
			tree.insertPoint( vector );
			dirty = centroidDirty = true;
		}
		
		public function compute_covariance_body():void
		{
			if (points.length == 0 || !dirty) return;
			
			covariance = new CovarianceMatrix2();
			var mean:Vector2 = centroid;
			
			for ( var i:int = 0; i < points.length; i++) 
			{
				var c:Vector2 = points[i].getMinus( mean );
				covariance.a += c.x * c.x;
				covariance.b += c.x * c.y;
				covariance.c += c.y * c.y;
			}
			
			var dy:Number = 2 * covariance.b;
			var dx:Number = covariance.a  - covariance.c + Math.sqrt(Math.pow(covariance.a - covariance.c,2) + Math.pow( 2 * covariance.b, 2 ) );
			if ( dy == 0 && dx == 0 )
			{
				_majorAngle = ( covariance.a >= covariance.c ? 0 : Math.PI * 0.5 );
			} else {
				_majorAngle = Math.atan2( dy, dx );
			}
			
			covariance.scale( 1 / points.length );
			dirty = false;
		}
		
		public function get pointCount():int
		{
			return points.length;
		}
		
		public function get centroid():Vector2
		{
			if ( points.length == 0 ) return new Vector2();
			if ( centroidDirty ) {
				_centroid = sum.getDivide( points.length );
				centroidDirty = false;
			}
			return _centroid;
		}
		
		public function get majorAngle():Number
		{
			if ( dirty ) compute_covariance_body();
			return _majorAngle;
		}
		
		public function get_obb():ConvexPolygon
		{
			var angle:Number = majorAngle;
			var center:Vector2 = centroid;
		
			var minX:Number, maxX:Number, minY:Number, maxY:Number;
			var p:Vector2;
			
			p = points[0].getRotateAround( -angle, center );
			minX = maxX = p.x;
			minY = maxY = p.y;
		
			for ( var i:int = 1; i < points.length; i++ )
			{
				p = points[i].getRotateAround( -angle, center );
				if ( p.x < minX ) minX = p.x;
				if ( p.x > maxX ) maxX = p.x;
				if ( p.y < minY ) minY = p.y;
				if ( p.y > maxY ) maxY = p.y;
			}
		 	
			var result:ConvexPolygon = ConvexPolygon.fromArray([ new Vector2( minX, minY ), new Vector2( maxX, minY ), new Vector2( maxX, maxY ), new Vector2( minX, maxY ) ]);
			result.rotate( angle, centroid );
			return result;
		}
		
		public function get density():Number
		{
			return get_obb().area / pointCount;
		}
		
		public function getSplitClouds( line:LineSegment ):Vector.<Vector2Cloud>
		{
			var result:Vector.<Vector2Cloud> = new Vector.<Vector2Cloud>();
			result.push( new Vector2Cloud(), new Vector2Cloud() );
			for each ( var point:Vector2 in points )
			{
				result[( point.isLeft( line.p1, line.p2 ) < 0 ? 0 : 1 )].accumulate(point);
			}
			
			return result;
		}
		
		public function getClusters( radius:Number = 32):Vector.<Vector2Cloud>
		{
			var bounds:Rectangle = getBoundingRect();
			var map:BitmapData = new BitmapData( Math.max(1,bounds.width+3), Math.max(1,bounds.height+3), false, 0 );
			var shp:Shape = new Shape();
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawCircle(0,0,radius);
			shp.graphics.endFill();
			var m:Matrix = new Matrix();
			for each ( var point:Vector2 in points )
			{
				m.tx = point.x - bounds.x + 1;
				m.ty = point.y - bounds.y + 1;
				map.draw( shp, m );
			}
			map.threshold( map, map.rect, map.rect.topLeft, "!=",0,0xffffffff,0xff,true);
			
			var clusters:Vector.<Vector2Cloud> = new Vector.<Vector2Cloud>();
			var cluster:Vector2Cloud;
			
			for each ( point in points )
			{
				var p:int = map.getPixel( point.x - bounds.x + 0.5 + 1, point.y - bounds.y + 0.5 + 1 );
				if (p == 0x000000 ) throw( new Error("zero is bad") );
				if (p == 0xffffff )
				{
					cluster = new Vector2Cloud();
					clusters.push( cluster );	
					map.floodFill( point.x - bounds.x + 0.5 + 1, point.y - bounds.y + 0.5 + 1, 0xff000000 | clusters.length );
				} else {
					cluster = clusters[ p - 1];
				}
				cluster.accumulate( point );
			}
			return clusters;
		}
		
		public function getHalfSplitClouds():Vector.<Vector2Cloud>
		{
			return getSplitClouds( LineSegment.fromPointAndAngleAndLength( centroid, majorAngle + Math.PI * 0.5 , 100 ) );
		}
		
		public function getClosestPoint( point:Vector2 ):Vector2
		{
			if ( treeDirty )
			{
				tree = new BalancingKDTree();
				tree.insertPoints( points );
				treeDirty = false;
			}
			return tree.findNearestFor( point ).point;
		}
		
		public function drawCovarianceEllipse( canvas:Graphics):void 
		{
			
			if ( dirty ) compute_covariance_body();
			
			var axis:Vector.<Vector2> = new Vector.<Vector2>(2,true);
			var lambda:Vector.<Number> = new Vector.<Number>(2,true);
			
			covariance.find_eigenvectors(lambda, axis);
			
			var len0:Number = Math.sqrt(Math.abs(lambda[0])) * NUM_STANDARD_DEVIATIONS;
			var len1:Number = Math.sqrt(Math.abs(lambda[1])) * NUM_STANDARD_DEVIATIONS;
			
			var axis0:Vector2 = axis[0];
			var axis1:Vector2 = axis[1];
			
			axis0.multiply(len0);
			axis1.multiply(len1);
			
			const NUM_VERTICES:int = 300;
			
			// Generate the vertex coordinates for the ellipse.
			
			var theta:Number = 0;
			var ct:Number = Math.cos(theta);
			var st:Number = Math.sin(theta);
			var pos:Vector2 = axis0.getMultiply(ct).plus( axis1.getMultiply(st) ).plus( centroid );
			
			canvas.moveTo( pos.x, pos.y );
			for (var j:int = 1; j < NUM_VERTICES; j++) 
			{
				theta = 2 * Math.PI * (j / NUM_VERTICES);
				ct = Math.cos(theta);
				st = Math.sin(theta);
				pos = axis0.getMultiply(ct).plus( axis1.getMultiply(st) ).plus( centroid );
				canvas.lineTo( pos.x, pos.y );
			}
		}
		
		public function rotate( angle:Number, center:Vector2 = null ):Vector2Cloud
		{
			if ( center == null ) center = centroid;
			for each ( var p:Vector2 in points )
			{
				p.rotateAround( angle, center );
			}
			dirty = true;
			treeDirty = true;
			return this;
		}
		
		public function getBoundingRect():Rectangle
		{
			if ( points.length == 0 ) return new Rectangle();
			var minX:Number, maxX:Number, minY:Number, maxY:Number;
			
			minX = maxX = points[0].x;
			minY = maxY = points[0].y;
			
			for each ( var point:Vector2 in points )
			{
				if ( point.x < minX ) minX = point.x;
				if ( point.x > maxX ) maxX = point.x;
				if ( point.y < minY ) minY = point.y;
				if ( point.y > maxY ) maxY = point.y;
			}
			
			return new Rectangle( minX, minY, maxX - minX + 1, maxY - minY + 1 );
		}
		
		public function convexHull():ConvexPolygon
		{
			return ConvexPolygon.fromVector( points );
		}
		
		public function getInnerCloud():Vector2Cloud
		{
			var hull:ConvexPolygon = convexHull();
			var result:Vector.<Vector2> = points.concat();
			for ( var i:int = 0; i < hull.pointCount; i++ )
			{
				var hullPoint:Vector2 = hull.getPointAt(i);
				for ( var j:int = 0; j < result.length; j++ )
				{
					if ( result[j] == hullPoint )
					{
						result.splice(j,1);
						break;
					}
				}
			}	
			return Vector2Cloud.fromVector( result );
		}
			
		
		public function draw( canvas:Graphics, radius:Number = 2 ):void
		{
			for each ( var point:Vector2 in points )
			{
				point.draw( canvas, radius );
			}
		}
		
		public function clone( deepClone:Boolean = true ):Vector2Cloud
		{
			if ( deepClone )
			{
				var tmp:Vector.<Vector2> = new Vector.<Vector2>();
				for ( var i:int = 0; i < points.length; i++ )
				{
					tmp.push( points[i].getClone() );
				}
				return Vector2Cloud.fromVector( tmp );
			} else {
				return Vector2Cloud.fromVector( points );
			}
		}
		
	}
}