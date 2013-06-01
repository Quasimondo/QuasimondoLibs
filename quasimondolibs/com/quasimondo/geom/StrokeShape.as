package com.quasimondo.geom
{
	import com.quasimondo.utils.MathUtils;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class StrokeShape extends LinearPath
	{
		private var __upperProfile:Array;
		private var __lowerProfile:Array;
		private var __width:Number = 0.5;
		
		private var __symmetric:Boolean = true;
		private var __resolution:Number = 4;
		
		private var upperBound:LinearPath;
		private var lowerBound:LinearPath;
		
		private var strokeDirty:Boolean = true;
		
		public var stroke:Boolean;
		public var strokeColor:int;
		public var strokeAlpha:Number;
		public var fill:Boolean;
		public var fillAlpha:Number
		
		public static function fromLine( l:LineSegment ):StrokeShape
		{
			var p:StrokeShape = new StrokeShape();
			p.addPoint(l.p1);
			p.addPoint(l.p2);
			return p;
		}
		
		public static function fromBezier2( bezier2:Bezier2, steps:int ):StrokeShape
		{
			var p:StrokeShape = new StrokeShape();
			var ti:Number;
			var t:Number
			steps--;
			for ( var i:int = 0; i <= steps; i++ )
			{
				t = i / steps;
				p.addPoint( bezier2.getPoint( t ) );
			}
			return p;
		}
		
		public static function fromBezier3( bezier3:Bezier3, steps:int, equidistant:Boolean = false ):StrokeShape
		{
			var p:StrokeShape = new StrokeShape();
			var i:int;
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
		
		public function StrokeShape()
		{
			super();
		}
		
		public function set upperProfile( profile:Array ):void
		{
			__upperProfile = profile;
			strokeDirty = true;
		}
		
		public function set lowerProfile( profile:Array ):void
		{
			__lowerProfile = profile;
			strokeDirty = true;
		}
		
		public function get upperProfile(  ):Array
		{
			return __upperProfile;
		}
		
		public function get lowerProfile(  ):Array
		{
			return __lowerProfile;
		}
		
		public function set width( value:Number ):void
		{
			if ( __width != value * 0.5 )
			{
				__width = value * 0.5;
				strokeDirty = true;
			}
		}
		
		public function set symmetric( value:Boolean ):void
		{
			if ( __symmetric != value )
			{
				__symmetric = value;
				strokeDirty = true;
			}
		}
		
		public function set resolution( value:Number ):void
		{
			if ( __resolution != value && value > 0 )
			{
				__resolution = value;
				strokeDirty = true;
			}
		}
		
		private function update():void
		{
			if ( points.length < 2 ) return;
			
			upperBound = new LinearPath();
			lowerBound = new LinearPath();
			
			var tstep:Number = getTStep( __resolution );
			var v1:Vector2;
			var v2:Vector2;
			var upperScale:Number;	
			var lowerScale:Number;	
			
			for ( var t:Number = 0;t<=1;t+=tstep )
			{
				if ( __upperProfile != null )
					upperScale = __width * MathUtils.linearInterpolation( __upperProfile, t );
				else 
					upperScale = __width;
				
				
				if ( __symmetric )
					lowerScale = upperScale;
				else if ( __lowerProfile != null )
					lowerScale = __width * MathUtils.linearInterpolation( __lowerProfile, t );
				else 
					lowerScale = __width;	
				
				
				v1 = getPointAt( t ); 
				v2 = getNormalAt( t );
				
				upperBound.addPoint( v2.getMultiply( upperScale ).plus(v1) );
				lowerBound.addPoint( v2.getMultiply( -lowerScale ).plus(v1) );
			}
			
			if ( t > 1 )
			{
				t = 1;
				if ( __upperProfile != null )
					upperScale = __width * MathUtils.linearInterpolation( __upperProfile, t );
				else 
					upperScale = __width;
				
				
				if ( __symmetric )
					lowerScale = upperScale;
				else if ( __lowerProfile != null )
					lowerScale = __width * MathUtils.linearInterpolation( __lowerProfile, t );
				else 
					lowerScale = __width;	
				
				
				v1 = getPointAt( t ); 
				v2 = getNormalAt( t );
				
				upperBound.addPoint( v2.getMultiply( upperScale ).plus(v1) );
				lowerBound.addPoint( v2.getMultiply( -lowerScale ).plus(v1) );
			}
			
			strokeDirty = false;
		}
		
		public function setDrawingProperties( stroke:Boolean, strokeColor:int, strokeAlpha:Number,  fill:Boolean, fillColor:int, fillAlpha:Number ):void
		{
			this.stroke = stroke;
			this.strokeColor = strokeColor;
			this.strokeAlpha = strokeAlpha;
			this.fill = fill;
			this.fillColor = fillColor;
			this.fillAlpha = fillAlpha;
		}
		
		override public function draw( g:Graphics ):void
		{
			if ( points.length < 2 ) return;
			
			if ( strokeDirty || dirty ) update();
			
			var upts:Vector.<Vector2> = upperBound.points;
			var lpts:Vector.<Vector2> = lowerBound.points;
			
			
			var pu:Vector2 = Vector2(upts[ 0 ]);
			var pl:Vector2 = Vector2(lpts[ 0 ]);
			var pu2:Vector2;
			var pl2:Vector2;
			
			if ( stroke )
			{
				g.lineStyle( 0, strokeColor, strokeAlpha);
			} else {
				g.lineStyle();
			}
			
			for ( var i:int = 1;  i < upts.length; i++ )
			{
				pu2 = Vector2(upts[ i ]);
				pl2 = Vector2(lpts[ i ]);
				g.moveTo( pu.x,pu.y);
				if ( fill ) g.beginFill( fillColor, fillAlpha );
				g.lineTo( pu2.x,pu2.y);
				g.lineTo( pl2.x,pl2.y);
				g.lineTo( pl.x,pl.y);
				g.lineTo( pu.x,pu.y);
				if ( fill ) g.endFill();
				pu = pu2;
				pl = pl2;
			}
			/*
			 g.lineStyle(0,0xff8000)
			 for ( var i:int = 0;i<points.length; i++)
			 {
				 Vector2(points[i]).draw( g );
			 }
			 */
			// g.lineStyle( 2,0xff8000);
			// super.draw(g);
		}
		
		public function mapMixedPath( path:MixedPath ):LinearPath
		{
			var bounds:Rectangle = path.getBoundingRect( false );
			var stepSize:Number = 1 / path.length;
			
			var outputPath:LinearPath = new LinearPath();
			var p:Vector2;
			var u:Number;
			var v:Number;
			var upperScale:Number;
			var lowerScale:Number;
			var normal:Vector2;
			for (var t:Number = 0;t<=1;t+=stepSize)
			{
				p = path.getPoint( t );
				u = ( p.x - bounds.x ) / bounds.width;
				v = 1 - (( p.y - bounds.y ) / bounds.height);
				
				if ( __upperProfile != null )
					upperScale = __width * MathUtils.linearInterpolation( __upperProfile, u );
				else 
					upperScale = __width;
				
				
				if ( __symmetric )
					lowerScale = upperScale;
				else if ( __lowerProfile != null )
					lowerScale = __width * MathUtils.linearInterpolation( __lowerProfile, u );
				else 
					lowerScale = __width;	
				
				
				normal= getNormalAt( u );
				
				outputPath.addPoint( normal.getMultiply( -lowerScale ).plus(getPointAt( u )).plus( normal.getMultiply( (upperScale + lowerScale) * v ) ) );
				
			}
				
				return outputPath;
				
			}
			
		}
	
}