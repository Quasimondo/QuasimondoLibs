package com.quasimondo.geom
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class FractalPath
	{
		
		private var __mode:int;
		
		private var __start:LinkedPoint;
		private var __end:LinkedPoint;
		
		private var __seed:int 			   = -1;
		private var __depth:int            = 0;
		private var __minDistance:int      = 2.0;
		private var __yfactor:Number       = 1.0;
		private var __xfactor:Number       = 0.0;
		private var __ymultiplier:Number   = 1.0;
		private var __xmultiplier:Number   = 1.0;
		private var __phase:Number         = 0.0;
		
		private var __yfactors:Array;
		private var __xfactors:Array;
		private var __points:Array;
		
		private var __invalidate:Boolean = true;
		
		private var __ps:Point;
		
		private var __offset:Number;
		private var __uniqueID:Number;
		private var __rnd:Array;
		
		private var __pointDepot:Array;
		
		private const PHASE_FACTOR1:Number = 0.15;
		private const PHASE_FACTOR2:Number = 0.65;
		private const RND_OFFSET:int = 77;
		
		static public function getPathDepthLimited( $points:Array, $seed:int = 0, $depth:int = 1, $yfactor:Number = 1.0, $xfactor:Number = 0.0, $ymultiplier:Number = 1.0, $xmultiplier:Number = 1.0 , $phase:Number = 0.0 ):FractalPath
		{
			if ( $points.length<2 ) return null;
			var fp:FractalPath = new FractalPath();
			
			fp.points = $points;
			fp.depth = $depth;
			fp.seed = $seed;
			fp.xfactor = $xfactor;
			fp.yfactor = $yfactor;
			fp.xmultiplier = $xmultiplier;
			fp.ymultiplier = $ymultiplier;
			fp.phase = $phase;
			fp.__mode = 0;
			return fp;
		}
		
		static public function getPathLookupLimited( $points:Array, $yfactors:Array, $xfactors:Array, $seed:int = 0,$phase:Number = 0.0 ):FractalPath
		{
			if ( $points.length<2 ) return null;
			if ( $yfactors.length != $xfactors.length ) return null;
			
			var fp:FractalPath = new FractalPath();
			fp.points = $points;
			fp.depth = $yfactors.length;
			fp.seed = $seed;
			fp.setLookupFactors($yfactors, $xfactors)
			fp.phase = $phase;
			fp.__mode = 1;
			return fp;
		}
		
		static public function getPathDistanceLimited( $points:Array, $seed:int = 0, $minDistance:Number = 2.0, $yfactor:Number = 1.0, $xfactor:Number = 0.0,  $ymultiplier:Number = 1.0, $xmultiplier:Number = 1.0 ,$phase:Number = 0.0 ):FractalPath
		{
			if ( $points.length<2 ) return null;
			
			var fp:FractalPath = new FractalPath();
			fp.points = $points;
			fp.minDistance = $minDistance;
			fp.seed = $seed;
			fp.xfactor = $xfactor;
			fp.yfactor = $yfactor;
			fp.xmultiplier = $xmultiplier;
			fp.ymultiplier = $ymultiplier;
			fp.phase = $phase;
			fp.__mode = 2;
			return fp;
		}
		
		
		
		public function FractalPath():void
		{
			__rnd = [];
			__pointDepot = [];
			
		}
		
		public function set points( $points:Array ):void
		{
			__points =  $points.slice();
			__invalidate = true;
		}
		
		public function toArray():Array
		{
			if (__invalidate) __calculate();
			return __start.toArray();
		}
		
		public function addPoint( $point:Point ):void
		{
			__points.push($point);
			__invalidate = true;
		}
		
		
		public function set seed( $seed:int ):void
		{
			if ( $seed != __seed )
			{
				__seed = $seed;
				var data:BitmapData = new BitmapData(2049,1,false,0);
				data.noise( __seed );
				
				for (var i:int = 1;i<2049;i++)
				{
					__rnd[i-1] = Number(data.getPixel(i,0 )) / 0x1000000;
				}
				data.dispose();
				__invalidate = true;
			}
		}
		
		public function get seed():int
		{
			return __seed;
		}
		
		
		public function set depth( $depth:int ):void
		{
			if ( $depth != __depth )
			{
				__depth = $depth;
				__invalidate = true;
			}
		}
		
		public function get depth():int
		{
			return __depth;
		}
		
		public function set xfactor( $xfactor:Number ):void
		{
			if ( $xfactor != __xfactor )
			{
				__xfactor = $xfactor;
				__invalidate = true;
			}
		}
		
		public function get xfactor():Number
		{
			return __xfactor;
		}
		
		public function set yfactor( $yfactor:Number ):void
		{
			if ( $yfactor != __yfactor )
			{
				__yfactor = $yfactor;
				__invalidate = true;
			}
		}
		
		public function get yfactor():Number
		{
			return __yfactor;
		}
		
		public function set ymultiplier( $ymultiplier:Number ):void
		{
			if ( $ymultiplier != __ymultiplier )
			{
				__ymultiplier = $ymultiplier;
				__invalidate = true;
			}
		}
		
		
		public function get ymultiplier():Number
		{
			return __ymultiplier;
		}
		
		public function set xmultiplier( $xmultiplier:Number ):void
		{
			if ( $xmultiplier != __xmultiplier )
			{
				__xmultiplier = $xmultiplier;
				__invalidate = true;
			}
		}
		
		
		public function get xmultiplier():Number
		{
			return __xmultiplier;
		}
		
		public function setLookupFactors( $yfactors:Array,$xfactors:Array ):void
		{
			if ( $xfactors.length == $yfactors.length )
			{
				__yfactors = $yfactors.slice();
				__xfactors = $xfactors.slice();
				__invalidate = true;
			}
			
		}
		
		public function get xfactors():Array
		{
			return __xfactors.slice();
		}
		
		public function get yfactors():Array
		{
			return __yfactors.slice();
		}
		
		public function set minDistance( $minDistance:Number ):void
		{
			__minDistance = $minDistance;
			
		}
		
		public function get minDistance( ):Number
		{
			return __minDistance;
		}
		
		public function set phase( $phase:Number):void
		{
			if (__phase != $phase )
			{
				__phase = $phase;
				__invalidate = true;
			}
		}
		
		public function get phase():Number
		{
			return __phase;
		}
		
		public function get path():Array
		{
			if ( __invalidate ) __calculate();
			
			var pts:Array = [];
			var p:LinkedPoint = LinkedPoint(__points[0]);
			while (p!=null)
			{
				pts.push(p);
				p = p.next;
			} 
			return pts;
			
		}
		
		public function get start():LinkedPoint
		{
			if ( __invalidate ) __calculate();
			return __start;
		}
		
		public function get end():LinkedPoint
		{
			if ( __invalidate ) __calculate();
			return __end;
		}
		
		private function __reset():void
		{
			if (__start != null){
				var p:LinkedPoint = __start;
				while (p!=null)
				{
					__pointDepot.push(p);
					p = p.next;
				} 
				
			}
			
			p = __pointDepot.pop();
			if ( p == null ) p = new LinkedPoint();
			__start = p;
			__start.previous = null;
			p.position = __points[0];
			var q:LinkedPoint;
			for ( var i:int = 1; i<__points.length;i++)
			{
				q = __pointDepot.pop();
				if ( q == null ) q = new LinkedPoint();
				q.position = __points[i];
				p.next = q;
				p=q;
			}
			p.next = null;
			__end = p;
		}
		

		
		private function __calculate():void
		{
			__uniqueID = 0;
			__reset();
			
			var p:LinkedPoint = __end.previous;
			do
			{
				switch ( __mode )
				{
					case 0:
						__subdivideDepth(p, __depth, __yfactor, __xfactor);
						break;
					case 1:
						__subdivideLookup(p, 0 );				
						break;
					case 2:
						__subdivide(p,0, __yfactor, __xfactor);
						break;
				}	
				p = p.previous;
			} while ( p!=null);
			
			__invalidate = false;
		}
		
		private function __subdivide( p1:LinkedPoint, $level:int, $yfactor:Number, $xfactor:Number):void
		{
			if ( $level<30 && Point.distance( p1,p1.next ) > __minDistance )
			{
				__uniqueID++;
				
				var mp:LinkedPoint = __pointDepot.pop();
				if ( mp==null ) mp = new LinkedPoint();
				mp.position = Point.interpolate( p1,p1.next,$xfactor == 0 ? 0.5 : 0.5 + (__rnd[ (__uniqueID + RND_OFFSET )& 0x7ff]-0.5)*$xfactor*Math.cos( __phase + (__uniqueID + RND_OFFSET) * PHASE_FACTOR1 ) );
			
				__ps = p1.subtract(mp);
				__offset = (__rnd[ __uniqueID & 0x7ff]-0.5)*$yfactor * Math.cos( __phase + __uniqueID * PHASE_FACTOR2 );
		
				mp.x -= __offset * __ps.y;
				mp.y += __offset * __ps.x;
				p1.insert(mp);
				__subdivide(p1,$level+1,$yfactor * __ymultiplier,$xfactor * __xmultiplier);
				__subdivide(mp,$level+1,$yfactor * __ymultiplier,$xfactor * __xmultiplier);
			}
		}
		
		private function __subdivideDepth( p1:LinkedPoint, steps:int, $yfactor:Number, $xfactor:Number ):void
		{
			__uniqueID++;
			
			var mp:LinkedPoint = __pointDepot.pop();
			if ( mp==null ) mp = new LinkedPoint();
			mp.position = Point.interpolate( p1,p1.next,$xfactor == 0 ? 0.5 : 0.5 + (__rnd[ (__uniqueID + RND_OFFSET )& 0x7ff]-0.5)*$xfactor*Math.cos( __phase + (__uniqueID + RND_OFFSET) * PHASE_FACTOR1 ) );
			
			__ps = p1.subtract(mp);
			__offset = (__rnd[ __uniqueID & 0x7ff]-0.5)*$yfactor * Math.cos( __phase + __uniqueID * PHASE_FACTOR2 );
			
			mp.x -= __offset * __ps.y;
			mp.y += __offset * __ps.x;
			p1.insert(mp);
			if ( steps>0)
			{
				__subdivideDepth(p1,steps-1,$yfactor * __ymultiplier,$xfactor * __xmultiplier);
				__subdivideDepth(mp,steps-1,$yfactor * __ymultiplier,$xfactor * __xmultiplier);
			}
			
		}
		
		
		private function __subdivideLookup( p1:LinkedPoint, step:int ):void
		{
			__uniqueID++;
			
			var $xfactor:Number = Number(__xfactors[step]);
			var $yfactor:Number = Number(__yfactors[step]);
			
			var mp:LinkedPoint = __pointDepot.pop();
			if ( mp==null ) mp = new LinkedPoint();
			mp.position = Point.interpolate( p1,p1.next,$xfactor == 0 ? 0.5 : 0.5 + (__rnd[ (__uniqueID + RND_OFFSET )& 0x7ff]-0.5)*$xfactor*Math.cos( __phase + (__uniqueID + RND_OFFSET) * PHASE_FACTOR1 ) );
			
			__ps = p1.subtract(mp);
			__offset = (__rnd[ __uniqueID & 0x7ff]-0.5)*$yfactor * Math.cos( __phase + __uniqueID * PHASE_FACTOR2 );
			
			mp.x -= __offset * __ps.y;
			mp.y += __offset * __ps.x;
			p1.insert(mp);
			step++;
			if ( step < __xfactors.length)
			{
				__subdivideLookup(p1,step);
				__subdivideLookup(mp,step);
			}
			
		}
		
		public function draw( canvas:Graphics ):void
		{
			if (__invalidate) __calculate();
			
			var p:LinkedPoint = __start;
			canvas.moveTo( p.x, p.y );
			p = p.next;
			do{
				canvas.lineTo( p.x, p.y );
				p = p.next;
				
			} while (p!=null);
		}
	}
}