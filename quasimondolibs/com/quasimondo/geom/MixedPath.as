package com.quasimondo.geom
{
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import spark.primitives.Line;

	public class MixedPath extends GeometricShape implements IIntersectable, ICountable
	{
		static public const LINEARIZE_APPROXIMATE:int = 0;
		static public const LINEARIZE_COMPLETE:int = 1;
		static public const LINEARIZE_UNDERSHOOT:int = 2;
		static public const LINEARIZE_OVERSHOOT:int = 3;
		static public const LINEARIZE_CENTER:int = 4;
	
		private var _closed:Boolean;
		private var points:Vector.<MixedPathPoint>;
		private var segments:Vector.<GeometricShape>;
		
		private var isValid:Boolean;
		private var dirty:Boolean;
		
		private var totalLength:Number;
		
		private var t_toSegments:Vector.<Number>;
		private var length_toSegments:Vector.<Number>;
		
		public static function fromLinearPath( lp:LinearPath, clonePoints:Boolean ):MixedPath
		{
			var mp:MixedPath = new MixedPath();
			for ( var i:int = 0; i < lp.pointCount; i++ )
			{
				mp.addPoint(  clonePoints ? lp.points[i].getClone() :  lp.points[i] );	
			}
			mp.updateSegments();
			return mp;
		}
		
		public static function getRoundedRect( center:Vector2, width:Number, height:Number, cornerRadius:Number ):MixedPath
		{
			cornerRadius = Math.min( cornerRadius, Math.min( width, height ) * 0.5 );
			if ( cornerRadius < 0 ) cornerRadius = 0;
			var mp:MixedPath = new MixedPath();
			
			var w2:Number = width * 0.5;
			var h2:Number = height * 0.5;
			var dx:Number = w2 - cornerRadius;
			var dy:Number = h2 - cornerRadius;
			
			var drx:Number = Math.cos(-0.785398163) * cornerRadius;
			var dry:Number = Math.sin(-0.785398163) * cornerRadius;
			
			var k:Number = 0.5522847498 * cornerRadius * 0.5;
			var dcx:Number = Math.cos(-2.35619449) * k;
			var dcy:Number = Math.sin(-2.35619449) * k;
			
			
			
			
			mp.addPoint( new Vector2( center.x + dx, center.y - h2 ) );
			mp.addControlPoint( new Vector2( center.x + dx + k, center.y - h2 ) );
			mp.addControlPoint( new Vector2( center.x + dx + drx + dcx, center.y - dy + dry + dcy ) );
			mp.addPoint( new Vector2( center.x + dx + drx, center.y - dy + dry ) );
			mp.addControlPoint( new Vector2( center.x + dx + drx - dcx, center.y - dy + dry - dcy ) );
			mp.addControlPoint( new Vector2( center.x + w2, center.y - dy - k ) );
			mp.addPoint( new Vector2( center.x + w2, center.y - dy ) );
			if ( cornerRadius < h2 ) mp.addPoint( new Vector2( center.x + w2, center.y + dy ) );
			mp.addControlPoint( new Vector2( center.x + w2, center.y + dy + k ) );
			mp.addControlPoint( new Vector2( center.x + dx + drx - dcx, center.y + dy - dry + dcy ) );
			mp.addPoint( new Vector2( center.x + dx + drx, center.y + dy - dry ) );
			mp.addControlPoint( new Vector2( center.x + dx + drx + dcx, center.y + dy - dry - dcy ) );
			mp.addControlPoint( new Vector2( center.x + dx + k, center.y + h2 ) );
			mp.addPoint( new Vector2( center.x + dx, center.y + h2 ) );
			if ( cornerRadius < w2 ) mp.addPoint( new Vector2( center.x - dx, center.y + h2 ) );
			mp.addControlPoint( new Vector2( center.x - dx - k, center.y + h2 ) );
			mp.addControlPoint( new Vector2( center.x - dx - drx - dcx, center.y + dy - dry - dcy ) );
			mp.addPoint( new Vector2( center.x - dx - drx, center.y + dy - dry ) );
			mp.addControlPoint( new Vector2( center.x - dx - drx + dcx, center.y + dy - dry + dcy ) );
			mp.addControlPoint( new Vector2( center.x - w2, center.y + dy + k ) );
			mp.addPoint( new Vector2( center.x - w2, center.y + dy ) );
			if ( cornerRadius < h2 ) mp.addPoint( new Vector2( center.x - w2, center.y - dy ) );
			mp.addControlPoint( new Vector2( center.x - w2, center.y - dy - k ) );
			mp.addControlPoint( new Vector2( center.x - dx - drx + dcx, center.y - dy + dry  - dcy ) );
			mp.addPoint( new Vector2( center.x - dx - drx, center.y - dy + dry ) );
			mp.addControlPoint( new Vector2( center.x - dx - drx - dcx, center.y - dy + dry  + dcy ) );
			mp.addControlPoint( new Vector2( center.x - dx - k, center.y - h2 ) );
			if ( cornerRadius < w2 ) mp.addPoint( new Vector2( center.x - dx, center.y - h2 ) );
			
			mp.setClosed(true);
			return mp;
			
			
		}
		
		public function MixedPath()
		{
			points = new Vector.<MixedPathPoint>();
			_closed = false;
			isValid = false;
			dirty = true;
		}
	
	
		override public function draw( g:Graphics ):void
		{
			if ( dirty ) updateSegments();
			
			if (isValid)
			{
				GeometricShape(segments[0]).moveToStart( g );
				for (var i:int = 0; i < segments.length; i++ )
				{
					GeometricShape(segments[i]).drawTo( g );
				}
				
			}
		}
		
		override public function export( g:IGraphics ):void
		{
			if ( dirty ) updateSegments();
			
			if (isValid)
			{
				GeometricShape(segments[0]).exportMoveToStart( g );
				for (var i:int = 0; i < segments.length; i++ )
				{
					GeometricShape(segments[i]).exportDrawTo( g );
				}
				
			}
		}
	
		override public function drawExtras( g:Graphics, factor:Number = 1  ):void
		{
			if ( dirty ) updateSegments();
			
			if (isValid)
			{
				for (var i:int = 0; i<segments.length; i++)
				{
					GeometricShape(segments[i]).drawExtras( g, factor );
				}
				
			}
			
			for ( i = 0; i<points.length; i++)
			{
				if ( points[i].isControlPoint )
				{
					points[i].drawCircle(g,3);
				} else {
					points[i].drawRect(g,3);
				}
			}
		}
	
	
		public function addPoint( p:Vector2, ID:String = null, update:Boolean = false ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.push( new MixedPathPoint( p, ID, false ) );
			if ( update )
				return updateSegments();
			else
				return isValid;
		}
	
		public function addControlPoint( p:Vector2, ID:String = null, update:Boolean = false ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.push( new MixedPathPoint( p, ID, true ) );
			if ( update )
				return updateSegments();
			else
				return isValid;
		}
	
		public function insertPointAt( p:Vector2, index:Number, ID:String = null, update:Boolean = false ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.splice( index, 0, new MixedPathPoint( p, ID, false ) );
			
			if ( update )
				return updateSegments();
			else 
				return isValid;
		}
		
		public function insertControlPointAt( p:Vector2, index:Number, ID:String = null, update:Boolean = false  ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.splice( index, 0, new MixedPathPoint( p, ID, true ) );
			if ( update )
				return updateSegments();
			else
				return isValid;
		}
		
		public function line2Bezier3( p1:MixedPathPoint, p2:MixedPathPoint ):Array
		{
			var ID1:String = String( points.length );
			var ID2:String = String( points.length + 1 );
			var index:int;
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( points[i] == p1){
					if (  points[i].isControlPoint ||  points[i+1].isControlPoint || points[i+1] != p2  )
					{
						return null;					
					}
					index = i;
					break;
				} else if ( points[i] == p2){
					if (  points[i].isControlPoint || points[i+1].isControlPoint || points[i+1]!= p1  ){
						return null;					
					}
					index = i;
					break;
				}
			}
			
			
			points.splice( index+1, 0, new MixedPathPoint( points[index].getLerp(points[index+1],0.333), ID1, true),
									   new MixedPathPoint( points[index].getLerp(points[index+1],0.666), ID2, true) );
			updateSegments();
			return [ points[index+1], points[index+2] ];
		}
	
		public function deletePoint( p:MixedPathPoint ):Boolean
		{
			for (var i:int = points.length;--i>-1;)
			{
				//trace(  [points[i].p,points[i].p == p]);
				if ( points[i] == p )
				{
					points.splice(i,1);
					return updateSegments();
				}
			}
			
			return isValid;
		}
		
		public function deletePointAt( index:int ):Boolean
		{
			points.splice( index, 1 );
			return updateSegments();
		}
		
		public function getMixedPathPointAt( index:int ):MixedPathPoint
		{
			return points[int(((index % points.length) + points.length)% points.length) ];
		}
		
		public function getPointAt( index:int ):Vector2
		{
			return points[int(((index % points.length) + points.length)% points.length) ];
		}
		
		public function updatePointAt(  index:int, p:MixedPathPoint ):Boolean
		{
			points[int(((index % points.length) + points.length)% points.length) ] = p;
			return updateSegments();
		}
		
		public function get centroid():Vector2
		{
			var lp:LinearPath = toLinearPath( 3 );
			return lp.centroid;
		}
		
		public function updatePoint( ID:String, p:MixedPathPoint ):Boolean
		{
			var point:MixedPathPoint = getPointByID( ID );
			if ( point == null ) return false;
			point = p;
			return updateSegments();
		}
		
		public function getPointByID( ID:String ):MixedPathPoint
		{
			for (var i:int = points.length;--i>-1;){
				if (points[i].ID==ID) return points[i];
			}
			return null;
		}
		
		override public function getPoint( t:Number ):Vector2
		{
			if ( dirty ) updateSegments();
			
			if ( !isValid || (!_closed && (t<0 || t>1))) return null;
			if ( !_closed )
			{
				if ( t > 1 ) t == 1;
				if ( t < 0 ) t == 0;
				
			} else {
				t = ((t%1)+1)%1;
			}
			
			var last_t:Number = 0;
			var t_sub:Number;
			for (var i:int=0;i<segments.length;i++)
			{
				if (t <= t_toSegments[i] )
				{
					if (t_toSegments[i] - last_t != 0)
						t_sub = ( t - last_t ) / (t_toSegments[i] - last_t);
					else 
						t_sub = 0;
					return GeometricShape(segments[i]).getPoint(t_sub);
				}
				last_t = t_toSegments[i];
			}
			
			return null;
		}
	
		public function getPointAt_offset( offset:Number ):Vector2
		{
			if ( dirty ) updateSegments();
			
			if ( !isValid || (!_closed && (offset<0 || offset>totalLength))) return null;
			
			offset = ((offset%totalLength)+totalLength)%totalLength;
			
			var last_offset:Number = 0;
			
			for (var i:int=0;i<segments.length;i++)
			{
				if (offset<=length_toSegments[i]){
					return segments[i].getPointAtOffset( offset - last_offset );
				}
				last_offset = length_toSegments[i];
			}
			
			return null;
		}
		
		override public function hasPoint( p:Vector2 ):Boolean
		{
			for ( var i:int = points.length; --i>-1;)
			{
				if ( p.squaredDistanceToVector( points[i] ) < SNAP_DISTANCE * SNAP_DISTANCE) {
					return true;
				}
			}
			return false;
		}
		
		
		override public function get length():Number
		{
			var len:Number = 0;
			for (var i:int = segments.length; --i>-1;)
			{
				len += segments[i].length;
			}
			return len;
		}
		
		public function setClosed( loop:Boolean ):Boolean
		{
			this._closed = loop;
			return updateSegments();
		}
		
		public function get closed():Boolean
		{
			return _closed;
		}
		
		public function isValidPath( ):Boolean 
		{
			if ( points.length < 2 ) return false;
			var cCounter:int=0;
			for (var i:int = points.length + ( _closed ? 1 :0 ); --i>-1;)
			{
				if ( points[ i%points.length ].isControlPoint )
				{
					cCounter++;
				} else {
					cCounter=0;
				}
				if (cCounter == 3) return false;
			}
			return true;
		}
	
		public function getClosestPathPoint( v:Vector2 ):MixedPathPoint
		{
			if ( points.length==0 ) return null;
			
			var d:Number = points[0].squaredDistanceToVector( v );
			var closest:MixedPathPoint = points[0];
			var d2:Number
			for (var i:int = points.length;--i>0;)
			{
				d2 = points[i].squaredDistanceToVector( v );
				if (d2<d)
				{
					d=d2;
					closest = points[i];
				}
			}
			return closest;
		}
	
		public function getNeighbours( p:MixedPathPoint ):Array
		{
			var n:Array = [];
			for ( var i:int = 0; i < points.length;i++ )
			{
				if ( points[i] == p)
				{
					if ( i-1 > 0)
					{
						if ( !points[i-1].isControlPoint )
						{
							n.push( points[i-1] );
						}
					}
					if ( i+1 < points.length )
					{
						if ( !points[i+1].isControlPoint )
						{
							n.push( points[i+1] ); 
						}
					}
					return n;
				}
			}
			return null;
		}
		
		override public function getClosestPoint( p:Vector2 ):Vector2
		{
			if ( dirty ) updateSegments();
			
			var closest:Vector2 = segments[0].getClosestPoint( p );
			var minDist:Number = closest.squaredDistanceToVector( p );
			var dist:Number;
			var pt:Vector2;
			for ( var i:int = 1; i < segments.length; i++ )
			{
				pt = segments[i].getClosestPoint( p );
				dist = pt.squaredDistanceToVector( p );
				if ( dist < minDist ) {
					minDist = dist ;
					closest = pt;
				}
			}
			return closest;
		}
		
		override public function getClosestT( p:Vector2 ):Number
		{
			if ( dirty ) updateSegments();
			
			var closest:Vector2 = segments[0].getClosestPoint( p );
			var minDist:Number = closest.squaredDistanceToVector( p );
			var closestSegmentIndex:int = 0;
			var dist:Number;
			var pt:Vector2;
			for ( var i:int = 1; i < segments.length; i++ )
			{
				pt = segments[i].getClosestPoint( p );
				dist = pt.squaredDistanceToVector( p );
				if ( dist < minDist ) {
					minDist = dist ;
					closest = pt;
					closestSegmentIndex = i;
				}
			}
			
			var ts:Number = segments[closestSegmentIndex].getClosestT( p );
			var t0:Number = closestSegmentIndex > 0 ? t_toSegments[closestSegmentIndex - 1] : 0;
			ts = t0 + ts * ( t_toSegments[closestSegmentIndex ] - t0 ); 
			return ts;
		}
	
		public function updateSegments():Boolean
		{
			dirty = false;
			
			segments = new Vector.<GeometricShape>();
			
			isValid = isValidPath();
			
			if (!isValid) return false;
			
			
			var traverse:int =  points.length + ( _closed ? 0 :-1 );
			
			var currentIndex:int = 0;
			while (  points[ currentIndex ].isControlPoint )
			{
				currentIndex++;
			}
			var currentPoint:MixedPathPoint = points[ currentIndex ];
			
			var pointStack:Vector.<MixedPathPoint> = new Vector.<MixedPathPoint>();
			pointStack.push( currentPoint );
			
			while (traverse>0)
			{
				currentIndex++;
				currentPoint = points[ int(currentIndex % points.length) ] ;
				pointStack.push( currentPoint );
				if (!currentPoint.isControlPoint)
				{
					var l:Number = pointStack.length;
					switch ( l )
					{
						case 2:
							if ( !pointStack[0].snaps( pointStack[1]) ||  points.length == 2 )
							{
								segments.push(new LineSegment( pointStack[0],pointStack[1]));
							}
							pointStack.shift();
							break;
						case 3:
							segments.push(new Bezier2(pointStack[0],pointStack[1],pointStack[2]));
							pointStack.shift();
							pointStack.shift();
							break;
						case 4:
							segments.push(new Bezier3(pointStack[0],pointStack[1],pointStack[2],pointStack[3]));
							pointStack.shift();
							pointStack.shift();
							pointStack.shift();
							break;
					}
				}
				traverse--;
			}
			updateLookupTables();
			return true;
		}
		
		public function getAngleAtCorner( index:int ):Number
		{
			if ( dirty ) 
				if ( !updateSegments() ) return 0;
			
			var s1:GeometricShape, s2:GeometricShape;
			//var a1:Number, a2:Number;
			if ( _closed )
			{
				s1 = segments[(index+segments.length-1) % segments.length];
				s2 = segments[index];
			} else {
				if ( index == 0 || index == segments.length)
				{
					return 0;
				} else {
					s1 = segments[index-1];
					s2 = segments[index];
				}
			}
			var pl:Vector2, pm:Vector2, pr:Vector2;
			
			if ( s1 is LineSegment )
			{
				pl = LineSegment( s1 ).p1;
				pm = LineSegment( s1 ).p2;
				//a1 = LineSegment( s1 ).angle;
			} else if ( s1 is Bezier2 )
			{
				pl = Bezier2( s1 ).c;
				pm = Bezier2( s1 ).p2;
				//a1 = Bezier2( s1 ).c.angleTo( Bezier2( s1 ).p2 );
			} else if ( s1 is Bezier3 )
			{
				pl = Bezier3( s1 ).c2;
				pm = Bezier3( s1 ).p2;
				//a1 = Bezier3( s1 ).c2.angleTo( Bezier3( s1 ).p2 );
			}
			
			if ( s2 is LineSegment )
			{
				pr = LineSegment( s2 ).p2;
				//a2 = LineSegment( s2 ).angle;
			} else if ( s2 is Bezier2 )
			{
				pr = Bezier2( s2 ).c;
				//a2 = Bezier2( s2 ).p1.angleTo( Bezier2( s2 ).c );
			} else if ( s2 is Bezier3 )
			{
				pr = Bezier3( s2 ).c1;
				//a2 = Bezier3( s2 ).p1.angleTo( Bezier3( s2 ).c1 );
			}
			return pm.cornerAngle(pr,pl);
			//return a1 - a2;
		}
		
		public function get cornerCount():int
		{
			if ( dirty ) 
				if ( !updateSegments() ) return 0;
			return segments.length + ( _closed ? 0 : 1 );
		}
		
		public function getCorner( index:int ):Vector2
		{
			if ( dirty ) 
				if ( !updateSegments() ) return null;
			
			var segment:GeometricShape;
			
			if ( closed ) index = (( index % cornerCount ) + cornerCount ) % cornerCount;
			else if ( index < 0 ) index = 0;
			else if ( index >= cornerCount )
			{
				segment = segments[segments.length-1]
				if ( segment is LineSegment ) return LineSegment( segment ).p2;
				if ( segment is Bezier2 ) return Bezier2( segment ).p2;
				if ( segment is Bezier3 ) return Bezier3( segment ).p2;
			}
			
			segment = segments[index];
			if ( segment is LineSegment ) return LineSegment( segment ).p1;
			if ( segment is Bezier2 ) return Bezier2( segment ).p1;
			if ( segment is Bezier3 ) return Bezier3( segment ).p1;
			
			return null;
		}
		
		
		
		public function get segmentCount():int
		{
			if ( dirty ) 
				if ( !updateSegments() ) return 0;
				
			return segments.length;
		}
		
		public function get pointCount():int
		{
			return points.length;
		}
		
		public function getSegment( index:int ):IIntersectable
		{
			if ( dirty ) updateSegments();
			
			index %= segments.length;
			if ( index < 0 ) index += segments.length;
			return segments[index] as IIntersectable;
		}
		
		public function toLinearPath( segmentLength:Number, mode:int = LINEARIZE_APPROXIMATE ):LinearPath
		{
			if ( dirty ) updateSegments();
			
			var lp:LinearPath = new LinearPath();
			var s:GeometricShape;
			
			var ti:Number;
			var t:Number;
			var steps:Number;
			var j:Number;
			
			var totalLength:Number = length;
			if ( totalLength == 0 ) return lp;
			
			var totalSteps:int = totalLength / segmentLength;
			var t_step:Number;
			var t_base:Number = 0;
			if ( mode != LINEARIZE_APPROXIMATE )
			{
				var coveredLength:Number = totalSteps * segmentLength;
				t_step = (coveredLength / totalLength) / totalSteps;
				if ( mode == LINEARIZE_CENTER ) t_base = 0.5 * (1 - ( coveredLength / totalLength ));
			} else {
				t_step = totalSteps > 0 ? 1 / totalSteps : totalLength;
				
			}
			
			if ( mode == LINEARIZE_CENTER && t_base != 0 ) lp.addPoint( getPoint(0) );
			//if ( mode == LINEARIZE_CENTER ) 
			for ( var i:int = 0; i <= totalSteps; i++ )
			{
				lp.addPoint( getPoint( t_base + i * t_step ) );
			}
			if ( mode ==  LINEARIZE_OVERSHOOT ) {
				var p1:Vector2 = lp.points[lp.points.length-1];
				var p2:Vector2 = getPoint( 1 );
				lp.addPoint( p2.minus( p1 ).newLength( segmentLength ).plus(p1) );
			} else if ( (mode == LINEARIZE_CENTER && t_base != 0) || ( mode == LINEARIZE_COMPLETE && (i-1) * t_step != 1) ) lp.addPoint( getPoint(1) );
			
			/*
			for ( var i:int = 0; i < segments.length; i++ )
			{
				s = GeometricShape( segments[i] );
				if ( s is LineSegment )
				{
				 	lp.addPoint(LineSegment(s).p1);
				} else {
				 	steps = s.length / segmentLength;
					steps--;
					for ( j = 0; j < steps; j+=1 )
					{
						t = j / steps;
						lp.addPoint( s.getPoint( t ) );
					}
				}
			}
			*/
			if ( _closed )
			{
				lp.addPoint( segments[0].getPoint( 0 ) );
			}
			
			return lp;
		}
		
		public function toPolygon( segmentLength:Number ):Polygon
		{
			if ( dirty ) updateSegments();
			
			var poly:Polygon = new Polygon();
			var s:GeometricShape;
			
			var ti:Number;
			var t:Number;
			var steps:Number;
			var j:Number;
			
			for ( var i:int = 0; i < segments.length; i++ )
			{
				s = GeometricShape( segments[i] );
				if ( s is LineSegment )
				{
				 	poly.addPoint(LineSegment(s).p1);
				} else {
				 	steps = s.length / segmentLength;
					steps--;
					for ( j = 0; j < steps; j+=1 )
					{
						t = j / steps;
						poly.addPoint( s.getPoint( t ) );
					}
				}
			}
			
			return poly;
		}
		
		
		override public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
			if ( dirty ) updateSegments();
			
			var i:int, j:Number, steps:Number;
			var p:Vector2;
			if ( loose )
			{
				var s:GeometricShape = GeometricShape( segments[0] );
				var r:Rectangle = s.getBoundingRect();
				for ( i = 1; i < segments.length; i++ )
				{
					r = r.union( segments[i].getBoundingRect() );
				}
			} else {
				var minP:Vector2 = segments[0].getPoint( 0 ).getClone();
				var maxP:Vector2 = segments[0].getPoint( 0 ).getClone();
				var segmentLength:Number = 1;
				for ( i = 0; i < segments.length; i++ )
				{
					s = GeometricShape( segments[i] );
					if ( s is LineSegment )
					{
						p = s.getPoint( 0 );
						minP.min( p );
						maxP.max( p );
						p = s.getPoint( 1 );
						minP.min( p );
						maxP.max( p );
					} else {
					 	steps = s.length / segmentLength;
						steps--;
						for ( j = 0; j < steps; j+=1 )
						{
							p = s.getPoint( j / steps );
							minP.min( p );
							maxP.max( p );
						}
					}
				}
				maxP.minus( minP );
				return new Rectangle( minP.x, minP.y , maxP.x, maxP.y  );
			}
			return r;
		}
		
		override public function translate(offset:Vector2):GeometricShape
		{
			for each ( var point:Vector2 in points )
			{
				point.plus( offset );
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
		
		override public function scale( factorX:Number, factorY:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = centroid;
			for each ( var p:Vector2 in points )
			{
				p.minus( center ).multiplyXY( factorX, factorY ).plus( center );
			}
			dirty = true;
			return this;
		}
		
		override public function getNormalAtPoint(p:Vector2):Vector2
		{
			var path:LinearPath = toLinearPath( 1 ) ;
			return path.getNormalAtPoint( p );
		}
	
		private function updateLookupTables():void
		{
			t_toSegments = new Vector.<Number>(segments.length, true );
			length_toSegments = new Vector.<Number>(segments.length, true );
			totalLength = 0; 
			for ( var i:int = 0; i < segments.length; i++ )
			{
				totalLength += segments[i].length;
				length_toSegments[i] = totalLength;
			}
			for ( i = segments.length; --i>-1; )
			{
				t_toSegments[i] = length_toSegments[i] / totalLength;
			}
		}
		
		public function appendPath( p:MixedPath ):void
		{
			points = points.concat( p.points );
			dirty = true;
		}
		
		
		override public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			var r:Rectangle = getBoundingRect( true );
			var l:LineSegment = new LineSegment( p, new Vector2( r.x - 1, r.y - 1 ) );
			var intersection:Intersection = l.intersect( this );
			return (intersection.points.length % 2 != 0);
		}
	
		static public function fromString( s:String ):MixedPath
		{
			var path:MixedPath = new MixedPath();
			var p:Array = s.split(";");
			path.setClosed( p[0] == "closed" );
			p = p[1].split(",");
			var pt:Array 
			var v:Vector2;
			for (var i:int = 0;i<p.length;i++)
			{
				pt =  p[i].split("|");
				v = new Vector2(Number(pt[0]),Number(pt[1]));
				if (pt.length == 3)
				{
					path.addControlPoint(v,null,false);
				}
				else {
					path.addPoint(v,null,false);
				}
			}
			path.updateSegments();
			return path;
		}
		
		override public function clone( deepClone:Boolean = true ):GeometricShape
		{
			var path:MixedPath = new MixedPath();
			for ( var i:int = 0; i<points.length; i++)
			{
				if ( deepClone )
					path.points.push( new MixedPathPoint( new Vector2(points[i].x,points[i].y), points[i].ID, points[i].isControlPoint ) );
				else
					path.points.push(points[i]);
			}
			path._closed = _closed;
			path.updateSegments();
			return path;
		}
		
		public function shiftStartCorner( delta:int ):void
		{
			if ( !_closed ) return;
			
			if (isValid)
			{
				var p:MixedPathPoint;
				if ( delta > 0 )
				{
					while ( delta > 0 )
					{
						p = points.shift();
						points.push ( p );
						if ( !p.isControlPoint ) delta--;
					}
				} else {
					while ( delta < 0 )
					{
						p = points.pop();
						points.unshift( p );
						if ( !p.isControlPoint ) delta++;
					}
				}
				updateSegments();
			}
		}
		
		public function getSplitAtT( t:Number, clonePoints:Boolean = true ):Vector.<MixedPath>
		{
			var result:Vector.<MixedPath> = new Vector.<MixedPath>();
			if ( t<=0 || t>=1) return result;
			
			if ( dirty ) updateSegments();
			if (!isValid) return result;
			
			var leftPath:MixedPath = new MixedPath();
			var rightPath:MixedPath = new MixedPath();
			var last_t:Number = 0;
			var t_sub:Number;
			for (var i:int=0;i<segments.length;i++)
			{
				if (t <= t_toSegments[i] )
				{
					if (t_toSegments[i] - last_t != 0)
						t_sub = ( t - last_t ) / (t_toSegments[i] - last_t);
					else 
						t_sub = 0;
					
					if ( t_sub == 0 )
					{
						if ( segments[i] is LineSegment )
						{
							leftPath.addPoint( clonePoints ? LineSegment( segments[i] ).p1.getClone() : LineSegment( segments[i] ).p1 );
							
							rightPath.addPoint( clonePoints ? LineSegment( segments[i] ).p1.getClone() : LineSegment( segments[i] ).p1 );
							rightPath.addPoint( clonePoints ? LineSegment( segments[i] ).p2.getClone() : LineSegment( segments[i] ).p2 );
						} else if ( segments[i] is Bezier2 )
						{
							leftPath.addPoint( clonePoints ? Bezier2( segments[i] ).p1.getClone() :  Bezier2( segments[i] ).p1 );
							
							rightPath.addPoint( clonePoints ? Bezier2( segments[i] ).p1.getClone() :  Bezier2( segments[i] ).p1 );
							rightPath.addControlPoint( clonePoints ? Bezier2( segments[i] ).c.getClone() :  Bezier2( segments[i] ).c );
							rightPath.addPoint( clonePoints ? Bezier2( segments[i] ).p2.getClone() :  Bezier2( segments[i] ).p2 );
						} else if ( segments[i] is Bezier3 )
						{
							leftPath.addPoint( clonePoints ? Bezier3( segments[i] ).p1.getClone() :  Bezier3( segments[i] ).p1 );
							
							rightPath.addPoint( clonePoints ? Bezier3( segments[i] ).p1.getClone() :  Bezier3( segments[i] ).p1 );
							rightPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c1.getClone() :  Bezier3( segments[i] ).c1 );
							rightPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c2.getClone() :  Bezier3( segments[i] ).c2 );
							rightPath.addPoint( clonePoints ? Bezier3( segments[i] ).p2.getClone() :  Bezier3( segments[i] ).p2 );
						}
					} else if ( t_sub == 1 )
					{
						if ( segments[i] is LineSegment )
						{
							leftPath.addPoint( clonePoints ? LineSegment( segments[i] ).p1.getClone() : LineSegment( segments[i] ).p1 );
							leftPath.addPoint( clonePoints ? LineSegment( segments[i] ).p2.getClone() : LineSegment( segments[i] ).p2 );
							
							rightPath.addPoint( clonePoints ? LineSegment( segments[i] ).p2.getClone() : LineSegment( segments[i] ).p2 );
						} else if ( segments[i] is Bezier2 )
						{
							leftPath.addPoint( clonePoints ? Bezier2( segments[i] ).p1.getClone() :  Bezier2( segments[i] ).p1 );
							leftPath.addControlPoint( clonePoints ? Bezier2( segments[i] ).c.getClone() :  Bezier2( segments[i] ).c );
							leftPath.addPoint( clonePoints ? Bezier2( segments[i] ).p2.getClone() :  Bezier2( segments[i] ).p2 );
							
							rightPath.addPoint( clonePoints ? Bezier2( segments[i] ).p2.getClone() :  Bezier2( segments[i] ).p2 );
						} else if ( segments[i] is Bezier3 )
						{
							leftPath.addPoint( clonePoints ? Bezier3( segments[i] ).p1.getClone() :  Bezier3( segments[i] ).p1 );
							leftPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c1.getClone() :  Bezier3( segments[i] ).c1 );
							leftPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c2.getClone() :  Bezier3( segments[i] ).c2 );
							leftPath.addPoint( clonePoints ? Bezier3( segments[i] ).p2.getClone() :  Bezier3( segments[i] ).p2 );
							
							rightPath.addPoint( clonePoints ? Bezier3( segments[i] ).p2.getClone() :  Bezier3( segments[i] ).p2 );
						}
					} else {
						if ( segments[i] is LineSegment )
						{
							var lineParts:Vector.<LineSegment> = LineSegment( segments[i] ).getSplitAtT( t_sub, clonePoints );
							leftPath.addPoint( lineParts[0].p1 );
							leftPath.addPoint( lineParts[0].p2 );
							
							rightPath.addPoint( lineParts[1].p1 );
							rightPath.addPoint( lineParts[1].p2 );
						} else if ( segments[i] is Bezier2 )
						{
							var bez2Parts:Vector.<Bezier2> = Bezier2( segments[i] ).getSplitAtT( t_sub, clonePoints );
							leftPath.addPoint( bez2Parts[0].p1 );
							leftPath.addControlPoint( bez2Parts[0].c );
							leftPath.addPoint( bez2Parts[0].p2 );
							
							rightPath.addPoint( bez2Parts[1].p1 );
							rightPath.addControlPoint( bez2Parts[1].c );
							rightPath.addPoint( bez2Parts[1].p2 );
						} else if ( segments[i] is Bezier3 )
						{
							var bez3Parts:Vector.<Bezier3> = Bezier3( segments[i] ).getSplitAtT( t_sub, clonePoints );
							leftPath.addPoint( bez3Parts[0].p1 );
							leftPath.addControlPoint( bez3Parts[0].c1 );
							leftPath.addControlPoint( bez3Parts[0].c2 );
							leftPath.addPoint( bez3Parts[0].p2 );
							
							rightPath.addPoint( bez3Parts[1].p1 );
							rightPath.addControlPoint( bez3Parts[1].c1 );
							rightPath.addControlPoint( bez3Parts[1].c2 );
							rightPath.addControlPoint( bez3Parts[1].p2 );
						}
					}
						
					while ( ++i < segments.length )
					{
						if ( segments[i] is LineSegment )
						{
							rightPath.addPoint( clonePoints ? LineSegment( segments[i] ).p2.getClone() : LineSegment( segments[i] ).p2 );
						} else if ( segments[i] is Bezier2 )
						{
							rightPath.addControlPoint( clonePoints ? Bezier2( segments[i] ).c.getClone() :  Bezier2( segments[i] ).c );
							rightPath.addPoint( clonePoints ? Bezier2( segments[i] ).p2.getClone() :  Bezier2( segments[i] ).p2 );
						} else if ( segments[i] is Bezier3 )
						{
							rightPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c1.getClone() :  Bezier3( segments[i] ).c1 );
							rightPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c2.getClone() :  Bezier3( segments[i] ).c2 );
							rightPath.addPoint( clonePoints ? Bezier3( segments[i] ).p2.getClone() :  Bezier3( segments[i] ).p2 );
						}
					}
					
					leftPath.setClosed( false );
					rightPath.setClosed( false );
					result.push ( leftPath, rightPath );
					return result;
					
				} else {
					if ( segments[i] is LineSegment )
					{
						leftPath.addPoint( clonePoints ? LineSegment( segments[i] ).p1.getClone() : LineSegment( segments[i] ).p1 );
					} else if ( segments[i] is Bezier2 )
					{
						leftPath.addPoint( clonePoints ? Bezier2( segments[i] ).p1.getClone() :  Bezier2( segments[i] ).p1 );
						leftPath.addControlPoint( clonePoints ? Bezier2( segments[i] ).c.getClone() :  Bezier2( segments[i] ).c );
					} else if ( segments[i] is Bezier3 )
					{
						leftPath.addPoint( clonePoints ? Bezier3( segments[i] ).p1.getClone() :  Bezier3( segments[i] ).p1 );
						leftPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c1.getClone() :  Bezier3( segments[i] ).c1 );
						leftPath.addControlPoint( clonePoints ? Bezier3( segments[i] ).c2.getClone() :  Bezier3( segments[i] ).c2 );
					}
				}
				last_t = t_toSegments[i];
			}
			
			
			return result;
		}
		
		public function getSplitsAtTs( t:Vector.<Number>, clonePoints:Boolean = true ):Vector.<MixedPath>
		{
			t.sort( function( a:Number, b:Number ):int{ return ( a < b ? -1 : ( a > b ? 1 : 0))});
			
			var current:MixedPath = this;
			var last_t:Number = 0;
			var result:Vector.<MixedPath> = new Vector.<MixedPath>();
			for ( var i:int = 0; i < t.length; i++ )
			{
				var parts:Vector.<MixedPath> = current.getSplitAtT( (t[i] - last_t) / ( 1 - last_t ), clonePoints );
				if ( parts.length > 0 )
				{
					result.push( parts[0] );
					current = ( parts.length == 2 ? parts[1] : parts[0] );
				}
				last_t = t[i];
			}
			
			if ( parts.length == 2  ) result.push( parts[1] );
			if ( closed && result.length > 1 )
			{
				var p1:MixedPath = result.shift();
				result[ result.length - 1 ].appendPath( p1 );
			}
			return result;
		}
		
		public function getArea( precision:Number = 3 ):Number
		{
			return toPolygon(precision).area;
		}
		
		public function toString():String
		{
			var result:Array = [];
			for ( var i:int = 0;i<points.length;i++)
			{
				result[i] = MixedPathPoint(points[i]).toString();
			}
			return (_closed ? "closed":"open") + ";" + result.join(",");
		}
		
		
	
		override public function get type():String
		{
			return "MixedPath";
		}

	}
}