package com.quasimondo.delaunay
{
	import com.quasimondo.geom.ConvexPolygon;
	import com.quasimondo.geom.LineSegment;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	public class VoronoiRegions {
		
		private var regions:Dictionary;
		
		public var viewport:Rectangle;
		public var size:int = 0;
		
		private static var depot:Array = [];
		
		public static function getRegion( n:DelaunayNode ):VoronoiRegion
		{
			var region:VoronoiRegion;
			if ( depot.length>0){
				region = VoronoiRegion(depot.pop());
				region.update( n );
			} else {
				region = new VoronoiRegion(n );
			}
			return region;
		}
		
		public static function deleteRegion( n:VoronoiRegion ):void
		{
			n.reset();
			depot.push(n);
		}
		
		public function VoronoiRegions()
		{
			regions = new Dictionary( true );
		}
		
		public function reset():void
		{
			regions = new Dictionary( true );
		}
		
		public function getRegions( ignoreOuterRegions:Boolean = true ):Vector.<VoronoiRegion>
		{
			var result:Vector.<VoronoiRegion> = new Vector.<VoronoiRegion>();
			for each ( var region:VoronoiRegion in regions )
	  		{ 
	  			if ( !ignoreOuterRegions || !(region.p.data is BoundingTriangleNodeProperties) ) result.push( region );
			}
			return result;
		}
		
		public function getConvexPolygons( clone:Boolean = true ):Vector.<ConvexPolygon>
		{
			var result:Vector.<ConvexPolygon> = new Vector.<ConvexPolygon>();
			for each ( var region:VoronoiRegion in regions )
			{ 
				result.push( clone ? region.polygon.clone() : region.polygon );
			}
			return result;
		}
		
		public function addEdge( e:DelaunayEdge ):void
		{
			var r1:VoronoiRegion;
			var r2:VoronoiRegion;
			
			r1 =  regions[ e.p1 ];
			if ( r1 == null )
			{
				r1 = regions[ e.p1 ] = getRegion( e.p1 );
				size++;
			} 
			
			r2 = regions[ e.p2 ];
			if ( r2 == null )
			{
				r2 = regions[ e.p2 ] = getRegion( e.p2 );
				size++;
			} 
			
			var line:LineSegment = e.getVoronoiLine();
			//line.clip( viewport.left, viewport.right,viewport.top,viewport.bottom );
			r1.addPoint( line.p1 );
			r2.addPoint( line.p1 );
			r1.addPoint( line.p2 );
			r2.addPoint( line.p2 );
			r1.addNeighbor( r2 );
			r2.addNeighbor( r1 );
		
		}

		public function removeAllElements():void
		{
			for each ( var region:VoronoiRegion in regions )
	  		{ 
	  			
				deleteRegion( region );
			}
			size = 0;
			reset();
		}
		
		public function clip():void
		{
			for each ( var region:VoronoiRegion in regions )
	  		{ 
	  			region.polygon.clip( viewport );
	  		}
			
			
			for ( var i:* in regions )
			{
				if ( VoronoiRegion(regions[i]).polygon.pointCount == 0 )
				{
					VoronoiRegions.deleteRegion( regions[i] );
					delete regions[regions[i].p];
				}
			}
		}
		
		public function draw( g:Graphics, colorMap:BitmapData = null ):void
	  	{
	  		var region:VoronoiRegion;
	  		var ctr:Vector2
	  		if (colorMap != null )
			{ 
		  		for each ( region in regions )
		  		{ 
		  			ctr = region.polygon.centroid;
		  			g.beginFill( colorMap.getPixel( ctr.x,ctr.y));
					region.draw( g );
					g.endFill();
				}
			} else {
				for each ( region in regions )
		  		{ 
		  			region.draw( g );
				}
			}
	  	}
		
		
		
	}		
}