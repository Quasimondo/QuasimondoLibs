// Marcing Ants Selection Class v1.0
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2006-2010 Mario Klingemann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package com.quasimondo.tools
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class MarchingAntsSelection extends Bitmap
	{
		static public const MIN_ZOOM:Number = 0.00001;
		static public const MAX_ZOOM:Number = 1000;
		
		// this controls when the rendering switches to
		// first copying out the visible area into
		// a smaller bitmap before drawing it scaled
		static public const MAX_INTERNAL_SIZE:Number = 4000;
		
		
		private var selectionMap:BitmapData
		private var __offset:Point;
		private var __zoom:Number;
		private var edgeMap:BitmapData;
		private var tempMap:BitmapData;
		private var antMap:BitmapData;
		private var selectionBackground:uint;
		private var snapMap:BitmapData = new BitmapData(1,1,false,0xffffffff);
		
		private const mat:Matrix = new Matrix();
		private const origin:Point = new Point();
		private const clipRect:Rectangle = new Rectangle();
		private const blur:BlurFilter = new BlurFilter(3,3,1);
		private const edges:Array = [];
		private const snapRect:Rectangle = new Rectangle();
		private const stripeMap:BitmapData = new BitmapData(2880,2880,false,0xffffffff);
		//private const paintMatrix:Matrix = new Matrix();
		private const antAnimation:Timer = new Timer( 1000 / 12 );
	    private const paintPoint:Point = new Point();
		
		public function MarchingAntsSelection( selectionMap:BitmapData )
		{
			this.selectionMap = selectionMap;
			selectionBackground = selectionMap.getPixel32( 0, 0 );
			
			__offset = new Point();
			__zoom = 1;
			
			for ( var i:int = 0;i<256;){edges[i++] = 0x01000000};
			edges[170] = edges[113] = edges[141] = 0x00000000;
			
			var antPattern:BitmapData = new BitmapData(6,6,false,0xffffffff);
			antPattern.setPixel32(0,0,0xff000000);
			antPattern.setPixel32(1,1,0xff000000);
			antPattern.setPixel32(2,2,0xff000000);
			antPattern.setPixel32(3,3,0xff000000);
			antPattern.setPixel32(4,4,0xff000000);
			antPattern.setPixel32(5,5,0xff000000);
			
			antPattern.setPixel32(1,0,0xff000000);
			antPattern.setPixel32(2,1,0xff000000);
			antPattern.setPixel32(3,2,0xff000000);
			antPattern.setPixel32(4,3,0xff000000);
			antPattern.setPixel32(5,4,0xff000000);
			antPattern.setPixel32(0,5,0xff000000);
			
			antPattern.setPixel32(2,0,0xff000000);
			antPattern.setPixel32(3,1,0xff000000);
			antPattern.setPixel32(4,2,0xff000000);
			antPattern.setPixel32(5,3,0xff000000);
			antPattern.setPixel32(0,4,0xff000000);
			antPattern.setPixel32(1,5,0xff000000);
			
			
			var paintShape:Shape = new Shape();
			var g:Graphics = paintShape.graphics;
			g.clear();
			g.beginBitmapFill( antPattern );
			g.drawRect(0,0, 2880, 2880 );
			g.endFill();
				
			stripeMap.draw(paintShape);
			
			
			antAnimation.addEventListener(TimerEvent.TIMER,animateAnts);
			
			
		}
		
		public function setViewport( viewportRect:Rectangle ):void
		{
			if ( edgeMap == null || edgeMap.width != viewportRect.width || edgeMap.height != viewportRect.height )
			{
				edgeMap = new BitmapData( viewportRect.width, viewportRect.height, true, 0 );
				tempMap = new BitmapData( viewportRect.width, viewportRect.height, false, 0 );
				antMap = new BitmapData( viewportRect.width, viewportRect.height, true, 0 );
				edgeMap.lock();
				tempMap.lock();
				
				clipRect.width = viewportRect.width;
				clipRect.height = viewportRect.height;
				
				antAnimation.start();
				bitmapData = antMap;
				
				paint();
			}
			
		}
		
		
		
		public function get zoom():Number
		{
			return __zoom;
		}
		
		public function set zoom( value:Number ):void
		{
			if ( value < MIN_ZOOM ) value = MIN_ZOOM;
			if ( value > MAX_ZOOM ) value = MAX_ZOOM;
			
			if( __zoom != value )
			{
				__zoom = value
				paint();
			};
		}
		
		public function get animate():Boolean
		{
			return antAnimation.running;
		}
		
		public function set animate( value:Boolean ):void
		{
			if ( value ) antAnimation.start() else antAnimation.stop();
		}
		
		public function get offset():Point
		{
			return __offset;
		}
		
		public function set offset( value:Point ):void
		{
			
			var vx:Number = Math.min(  value.x, maxOffsetX );
			var vy:Number = Math.min(  value.y, maxOffsetY );
			
			var dx:Number = __offset.x - vx;
			var dy:Number = __offset.y - vy;
			
			if(dx != 0 || dy != 0 )
			{
				__offset.x  = vx;
				__offset.y  = vy;
				updateMatrix();
				paint();
			};
		
			
		}
		
		public function scroll( dx:int, dy:int ):void
		{
			var diff:Point = new Point( dx / zoom, dy / zoom );
			if ( diff.length > 0 ) offset = offset.add( diff );
		}
		
		public function zoomAt( fixedInViewport:Point, value:Number ):void
		{
			if ( value < MIN_ZOOM ) value = MIN_ZOOM;
			if ( value > MAX_ZOOM ) value = MAX_ZOOM;
			
			if( __zoom != value )
			{
				var beforePoint:Point = viewPortToView( fixedInViewport );
				__zoom = value;
				var diff:Point = beforePoint.subtract(viewPortToView( fixedInViewport ));
				
				if ( diff.length > 0 ) offset = offset.add( diff );
				else paint();
			};
		}
		
		public function get zoomedWidth():Number
		{
			return selectionMap.width * __zoom;
		}
		
		public function get zoomedHeight():Number
		{
			return selectionMap.height * __zoom;
		}
		
		public function get viewWidth():Number
		{
			return edgeMap.width / __zoom;
		}
		
		public function get viewHeight():Number
		{
			return edgeMap.height / __zoom;
		}
		
		
		public function get maxOffsetX():Number
		{
			return Math.max( 0, selectionMap.width - width / __zoom );
		}
		
		public function get maxOffsetY():Number
		{
			return Math.max( 0, selectionMap.height - height / __zoom);
		}
		
		public function viewPortToView( point:Point ):Point
		{
			var result:Point = point.clone();
			result.x = point.x / __zoom + __offset.x;
			result.y = point.y /__zoom + __offset.y;
			return result;
		}
		
		public function viewToViewPort( point:Point ):Point
		{
			var result:Point = point.clone();
			
			result.x = (point.x - __offset.x) * __zoom;
			result.y = (point.y - __offset.y) * __zoom;
			
			return result;
		}
		
		public function paint():void
		{
			if ( edgeMap == null ) return;
			
			updateMatrix();
			
			if (zoomedWidth < antMap.width || zoomedHeight < antMap.height ||  mat.tx > 0 || mat.ty > 0)
			{
				tempMap.fillRect( tempMap.rect, selectionBackground );
				antMap.fillRect( antMap.rect, 0 );
			}
			
			if ( zoomedWidth > MAX_INTERNAL_SIZE || zoomedHeight > MAX_INTERNAL_SIZE )
			{
				snapRect.x = Math.round(__offset.x);
				snapRect.y = Math.round(__offset.y)
				snapRect.width = Math.ceil( viewWidth );
				snapRect.height = Math.ceil( viewHeight);
				
				if ( snapRect.width != snapMap.width || snapRect.height != snapMap.height )
				{
					snapMap = new BitmapData( snapRect.width, snapRect.height, false, selectionBackground);
				}
				
				snapMap.copyPixels( selectionMap, snapRect, origin );
				mat.tx = 0;
				mat.ty = 0;
				tempMap.draw( snapMap, mat );
			} else  {
				tempMap.draw( selectionMap, mat );
			}
			
			edgeMap.fillRect( edgeMap.rect,0xff0000ff)
			edgeMap.threshold( tempMap, clipRect, origin, "<", 128, 0xff000000,0xff,false);
			edgeMap.applyFilter( edgeMap, clipRect, origin, blur );
			edgeMap.paletteMap( edgeMap, clipRect,origin,null,null,edges,null);
			
			animateAnts();
		}
		
		private function updateMatrix():void
		{
			mat.a = mat.d = __zoom;
			mat.tx =  Math.round( -__zoom * Math.round(__offset.x) ) ;
			mat.ty =  Math.round( -__zoom * Math.round(__offset.y) );
		}
		
		private function animateAnts( event:TimerEvent = null):void
		{
			antMap.lock();
			paintPoint.x = paintPoint.x > -5 ? paintPoint.x - 1 : 0;
			
			antMap.copyPixels( stripeMap, clipRect, paintPoint, edgeMap, paintPoint, false );
			/*
			paintMatrix.tx = (paintMatrix.tx + 1) % 6;
			antMap.draw(paintShape,paintMatrix);
			antMap.threshold(edgeMap,clipRect,origin,"!=",255,0,255,false);
			*/
			antMap.unlock();
		}
		
	}
}