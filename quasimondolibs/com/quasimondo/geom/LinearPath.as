package  com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.effects.easing.Linear;
	

	public class LinearPath extends GeometricShape
	{
		public static const SMOOTH_PATH_RELATIVE_EDGEWISE:int = 0;
		public static const SMOOTH_PATH_ABSOLUTE_EDGEWISE:int = 1;
		public static const SMOOTH_PATH_RELATIVE_MINIMUM:int = 2;
		public static const SMOOTH_PATH_ABSOLUTE_MINIMUM:int = 3;
		
		public static const CUBIC_PATH_RELATIVE:int = 0;
		public static const CUBIC_PATH_ABSOLUTE:int = 1;
		
		
		private var _points:Vector.<Vector2>;
		private var distances:Vector.<Number>;
		private var totalLength:Number;
		
		private var t_cache:Vector.<int>;
		private var l_cache:Vector.<Number>;
		
		private const CACHE_SIZE:Number = 200;
		
		protected var dirty:Boolean = true;
		
		public static function fromVector( points:Vector.<Vector2>, clonePoints:Boolean = false ):LinearPath
		{
			var p:LinearPath = new LinearPath();
			for ( var i:int = 0; i < points.length; i++ )
			{
				p.addPoint( clonePoints ? points[i].getClone() : points[i] );
			}
			
			return p;
		}
		
		public static function fromLine( l:LineSegment ):LinearPath
		{
			var p:LinearPath = new LinearPath();
			p.addPoint(l.p1);
			p.addPoint(l.p2);
			return p;
		}
		
		public static function fromBezier2( bezier2:Bezier2, segmentLength:Number ):LinearPath
		{
			var p:LinearPath = new LinearPath();
			var ti:Number;
			var t:Number;
			var steps:int = bezier2.length / segmentLength;
			steps--;
			for ( var i:int = 0; i <= steps; i++ )
			{
				t = i / steps;
				p.addPoint( bezier2.getPoint( t ) );
			}
			return p;
		}
		
		public static function fromBezier3( bezier3:Bezier3, segmentLength:Number, equidistant:Boolean = false ):LinearPath
		{
			var p:LinearPath = new LinearPath();
			var i:int;
			var steps:int = bezier3.length / segmentLength;
			steps--;
			if ( equidistant )
			{
				 var pts:Array = bezier3.getEquidistantPoints( steps, 2 );
				 for ( i = 0; i < pts.length; i++ )
				 {
				 	p.addPoint( pts[i] );
				 }
			} else {
				var t:Number;
				for ( i=0;i<=steps;i++)
				{
					t = i / steps;
					
					p.addPoint( bezier3.getPoint( t ) );
				}
			}
			return p;
		}
		
		public function LinearPath()
		{
			_points = new Vector.<Vector2>();
			distances = new Vector.<Number>();
			totalLength = 0;
		}
		
		public function removeAll():void
		{
			_points.length = 0;
			distances.length = 0;
			totalLength = 0;
		}
		
		public function addXY( x:Number, y:Number ):void
		{
			var p:Vector2 = new Vector2( x, y);
			if ( _points.length>0 && _points[_points.length-1].equals(p)) return;
			
			_points.push( p );
			if ( _points.length>1)
			{
				var d:Number = p.distanceToVector( _points[int(_points.length - 2)] );
				if ( d > 0 )
				{
					distances.push(d);
					totalLength += d;
				} else {
					_points.pop();
				}
			}
			dirty = true;
		}
		
		public function addPoint( p:Vector2 ):void
		{
			if ( _points.length>0 && _points[_points.length-1].equals(p)) return;
			
			_points.push( p.getClone() );
			if ( _points.length>1)
			{
				var d:Number = p.distanceToVector( _points[int(_points.length - 2)] );
				if ( d > 0 )
				{
					distances.push(d);
					totalLength += d;
				} else {
					_points.pop();
				}
			}
			
			dirty = true;
		}
		
		public function addPath( lp:LinearPath ):void
		{
			for ( var i:int = 0; i < lp.points.length; i++ )
			{
				addPoint( lp.points[i] );
			}
			dirty = true;
		}
		
		private function calculateIndex( ):void
		{
			var l:Number, f:Number;
			var dl:int = distances.length;
			
			t_cache = new Vector.<int>;
			l_cache = new Vector.<Number>;
			l = 0;
			
			var t:int = 0;
			var last_t:int = -1;
			
			var old_cache_t:int = 0;
			var old_cache_l:Number = 0;
		
			for ( var i:int = 0; i < dl; i++ )
			{
				t = int( CACHE_SIZE * l / totalLength );
				if ( t != last_t )
				{
					if ( t - last_t > 1)
					{
						old_cache_t = int(t_cache[last_t]);
						old_cache_l = Number(l_cache[last_t]);
						while ( t - last_t > 1 )
						{
							t_cache[int(++last_t)] = old_cache_t;
							l_cache[last_t] = old_cache_l;
						}
						
					}
					t_cache[t] = i;
					l_cache[t] = l;
					last_t = t;
				}
				l += distances[i];
			}
			
			while ( t < CACHE_SIZE ) 
			{
				t_cache[++t] = old_cache_t;
				l_cache[t] = old_cache_l;
			}
			
			dirty = false;
		}
		
		public function getPointAt( t:Number ):Vector2
		{
			if ( t <= 0 || _points.length == 1) return _points[0];
			if ( t >= 1) return _points[int(_points.length - 1)] ;
			
			if ( dirty ) calculateIndex( );
			
			var i:int = t_cache[int( t*CACHE_SIZE )];
			
			var l:Number =  t * totalLength - l_cache[int(t*CACHE_SIZE)];
			
			while ( l > distances[int(i++)] && i < distances.length )
			{
				l -= distances[int(i-1)];
			}
			
			i--;
			
			return _points[ i].getLerp( _points[int(i+1)],  ( l / distances[i] ) );
			
		}
		
		public function getPointAtIndex( index:int ):Vector2
		{
			return points[int(((index % points.length) + points.length)% points.length) ];
		}
		
		override public function translate(offset:Vector2):GeometricShape
		{
			for each ( var point:Vector2 in _points )
			{
				point.plus( offset );
			}
			return this;
		}
		
		public function getNormalAt( t:Number, radius:int = 3 ):Vector2
		{
			if ( t <= 0 ) 
			{
				t = 0;
			}
			
			if ( t >= 1) 
			{
				t = 1;
			}
			
			if ( dirty ) calculateIndex( );
			
			
			var i:int = t_cache[int( t*CACHE_SIZE )];
			var vl:Vector2 = points[i].getClone();
			var vr:Vector2 = points[i].getClone();
			var v:Vector2
			var lc:int = 1;
			var rc:int = 1;
			
			for ( var j:int = 1;j<=radius;j++)
			{
				if ( i-j >= 0 )
				{
					vl.plus( points[i-j] );
					lc++;
				}
				if ( i+j < points.length )
				{
					vr.plus( points[i+j] );
					rc++;
				}
			}
			
			vl.multiply( 1 / lc );
			vr.multiply( 1 / rc );
			return vl.getMinus(vr).normal();
			/*
			
			var ts:Number = getTStep(radius);
			var v1:Vector2 = getPointAt( t-ts);
			var v2:Vector2 = getPointAt( t+ts);
			return v1.getMinus(v2).normal();
			*/
		}
		
		override public function getNormalAtPoint( p:Vector2 ):Vector2
		{
			var bestI:int = 0
			var d:Number;
			var bestD:Number = points[0].squaredDistanceToVector( p );
			for ( var i:int = 1;i < points.length; i++)
			{
				if ( (d = points[i].squaredDistanceToVector( p ) ) < bestD )
				{
					bestD = d;
					bestI = i;
				}
			}	
			
			var l:LineSegment;
			if (bestI > 0 && getPointAtIndex(bestI-1).squaredDistanceToVector( p ) < getPointAtIndex(bestI+1).squaredDistanceToVector( p ))
			{
				l = getSegment(bestI-1);
			} else {
				l = getSegment(bestI);
			}
			return l.getNormalAtPoint(null);
		}
		
		
		public function equalize( segmentLength:Number, mode:int = 0 ):void
		{
			 var mp:MixedPath = MixedPath.fromLinearPath( this, false );
			 var lp:LinearPath = ( mp.length == 0 || !mp.isValidPath() ? new LinearPath() : mp.toLinearPath( segmentLength, mode ) );
			 _points = lp.points;
			 distances = lp.distances;
			 totalLength = lp.totalLength;
			 t_cache = lp.t_cache;
			 l_cache = lp.l_cache;
			 dirty = lp.dirty;
		}
		
		public function getEqualizedPath( segmentLength:Number, mode:int = 0, clonePoints:Boolean = true ):LinearPath
		{
			var mp:MixedPath = MixedPath.fromLinearPath( this, clonePoints );
			return mp.length == 0 || !mp.isValidPath() ? new LinearPath() : mp.toLinearPath( segmentLength, mode );
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
		
		override public function get length():Number
		{
			return totalLength;
		}
		
		public function get pointCount():int
		{
			return _points.length;
		}
		
		public function getTStep( l:Number ):Number
		{
			return l / totalLength;
		}
		
		public function get points():Vector.<Vector2>
		{
			return _points.concat() ;
		}
		
		override public function draw( g:Graphics ):void
		{
			if ( _points.length > 0 )
			{
				var i:int = 0;
				var p:Vector2 = _points[int(i++)];
				g.moveTo( p.x, p.y );
				while ( i < _points.length )
				{
					p = _points[int(i++)];
					g.lineTo( p.x, p.y );
				}
			}
		}
		
		public function drawWithOffset( g:Graphics, offset:Vector2 ):void
		{
			if ( _points.length > 0 )
			{
				var i:int = 0;
				var p:Vector2 = _points[int(i++)];
				g.moveTo( p.x + offset.x, p.y + offset.y );
				while ( i < _points.length )
				{
					p = _points[int(i++)];
					g.lineTo( p.x + offset.x, p.y + offset.y );
				}
			}
		}
		
		override public function drawExtras( g:Graphics, factor:Number = 1 ):void
		{
			if ( _points.length > 0 )
			{
				var i:int = 0;
				while ( i < _points.length )
				{
					_points[int(i++)].draw(g,factor);
				}
			}
		}
		
		public function getSmoothPath( factor:Number, mode:int = 0, loop:Boolean = false):MixedPath
		{
			if ( mode < 0 || mode > 3 )
			{
				throw( new Error("getSmoothPath: illegal mode "+mode) );
				return;
			}
			var segments:Vector.<LineSegment> = new Vector.<LineSegment>();
			var s:LineSegment;
			var l:Number = Number.MAX_VALUE;;
			var p1:Vector2, p2:Vector2;
			 
			for ( var i:int = 0; i < points.length-(loop ? 0 : 1); i++ )
			{
				s = getSegment(i);
				segments.push( s );
				switch ( mode )
				{
					case SMOOTH_PATH_RELATIVE_MINIMUM:
					case SMOOTH_PATH_ABSOLUTE_MINIMUM:
						 l = Math.min( l, s.length ) ;
					break;
				}
			}
			
			switch ( mode )
			{
				case SMOOTH_PATH_RELATIVE_MINIMUM:
					l *= 0.5 * factor;
				break;
				case SMOOTH_PATH_ABSOLUTE_MINIMUM:
					 l = Math.min( l*0.5, factor ) ;
				break;
			}
			
			
			var mp:MixedPath = new MixedPath();
			if ( segments.length > 0 )
			{
				if ( !loop )
					mp.addPoint( segments[0].getPoint(0) );
				
			}
			for ( i = 0; i < segments.length; i++ )
			{
				s = segments[i];
				if ( s.length > 0 )
				{
					switch ( mode )
					{
						case SMOOTH_PATH_RELATIVE_EDGEWISE:
							l = s.length * 0.5 * factor;
						break;
						case SMOOTH_PATH_ABSOLUTE_EDGEWISE:
							 l = Math.min( s.length*0.5, factor ) ;
						break;
					}
					
					p1 = s.getPoint( l / s.length );
					p2 = s.getPoint( 1- ( l / s.length ) );
				
					mp.addPoint(p1);
					if ( !p1.equals(p2 )) mp.addPoint(p2);
					mp.addControlPoint( s.p2.getClone() );
				}
			}
			if (  segments.length > 0 )
			{
				if (!loop)
					mp.addPoint( segments[segments.length-1].getPoint(1) );
				//else
				//	mp.deletePointAt(0);
			} 
			mp.setClosed( loop );
			return mp;
		}
		
		public function getSegment( index:int ):LineSegment
		{
			index = ( index % points.length + points.length) % points.length;
			return new LineSegment( points[index], points[int((index+1)% points.length)] );
		}
		
		public function getCubicBezierPath( smoothFactor:Number, loop:Boolean = false, mode:int = CUBIC_PATH_RELATIVE ):MixedPath
		{
			if ( points.length < 2 ) return null;
			var path:MixedPath = new MixedPath();
			var p0:Vector2, p1:Vector2, p2:Vector2, p3:Vector2, v0:Vector2, v1:Vector2, v2:Vector2;
			var tangentLength:Number;
			//tangentLength2:Number;
			for ( var i:int = 0; i < points.length; i++ )
			{
			
					p0 = points[ int((i-1 + 2*points.length) % points.length)];
					p1 = points[ int((i) % points.length)];
					p2 = points[ int((i+1) % points.length)];
					p3 = points[ int((i+2) % points.length)];
					
					v0 = p0.getMinus( p1 );
					v1 = p1.getMinus( p2 );
					
					tangentLength = ( mode == CUBIC_PATH_RELATIVE ? v1.length * smoothFactor : smoothFactor );
					v1.newLength( v0.length );
					v0 = p1.getPlus( v0 ).lerp( p1.getPlus( v1 ), 0.5 ).minus(p1);
					v0.newLength(tangentLength );
					
					v1 = p1.getMinus( p2 );
					v2 = p2.getMinus( p3 );
					
					tangentLength =  ( mode == CUBIC_PATH_RELATIVE ? v1.length * smoothFactor : smoothFactor );
					//tangentLength2 = ( mode == CUBIC_PATH_RELATIVE ? v2.length * smoothFactor : smoothFactor );
					v2.newLength( v1.length );
					v1 = p2.getPlus( v1 ).lerp( p2.getPlus( v2 ), 0.5 ).minus(p2);
					v1.newLength(tangentLength );
					
					path.addPoint( p1.getClone() );
					path.addControlPoint( p1.getMinus(v0) );
					path.addControlPoint( p2.getPlus( v1 ) );
				
			}
			if (!loop)
			{
				path.deletePointAt(path.pointCount-1);
				path.deletePointAt(path.pointCount-1);
				v1 = path.getPointAt(0).getMinus(path.getPointAt(2));
				v1.newLength( -( mode == CUBIC_PATH_RELATIVE ?  path.getPointAt(0).distanceToVector( path.getPointAt(3)) * smoothFactor : smoothFactor ) );
				v1.plus(path.getPointAt(0));
				path.getPointAt(1).setValue( v1 );
				
				v1 = path.getPointAt(path.pointCount-1).getMinus(path.getPointAt(path.pointCount-3));
				v1.newLength( -( mode == CUBIC_PATH_RELATIVE ? path.getPointAt(path.pointCount-1).distanceToVector( path.getPointAt(path.pointCount-4)) * smoothFactor : smoothFactor ) );
				v1.plus(path.getPointAt(path.pointCount-1));
				path.getPointAt(path.pointCount-2).setValue(v1);
			}
			path.setClosed(loop);
			
			return path;	
		}
		
		override public function applyTransformationMatrix( matrix:Matrix, clone:Boolean = false ):GeometricShape
		{
			var path:LinearPath = ( clone ? LinearPath(this.clone(true)) : this );
			for each ( var p:Vector2 in path.points )
			{
				p.applyTransformationMatrix( matrix );
			}
			path.dirty = true;
			return path;
			
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
		
		override public function clone( deepClone:Boolean = true ):GeometricShape
		{
			return LinearPath.fromVector( points, deepClone );
		}
	}
}