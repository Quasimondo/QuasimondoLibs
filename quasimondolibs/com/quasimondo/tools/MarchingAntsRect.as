// Marcing Ants Rectangle Class v1.0
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
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.events.Event;
	import flash.display.Graphics;
	
	
	public class MarchingAntsRect extends Shape
	{
		private var patternLength:int;
		private var colors:Array;
		private var pattern:Array;
		private var patternMap:BitmapData;
		private var copyRect:Rectangle;
		private var copyPoint:Point = new Point(1,0);
		private var updateID:int;
		private var targetGraphics:Graphics;
		
		private var r:Rectangle = new Rectangle();
		private var m:Matrix = new Matrix();
		private var stepsPerFrame:int = 1;
		
		public function MarchingAntsRect( colors:Array = null, pattern:Array = null )
		{
			targetGraphics = graphics;
			setPattern( colors, pattern );
		}
		
		public function setGraphics( g:Graphics = null ):void
		{
			if (g == null)
			{
				targetGraphics = graphics;
			} else {
				targetGraphics = g;
			}
		}
		
		public function setPattern( $colors:Array = null, $pattern:Array = null ):void
		{
			if ( $colors == null ){
				colors = [ 0xff000000, 0xffffffff ];
			} else {
				colors = $colors.slice();
			}
			if ( $pattern == null || $pattern.length != colors.length){
				pattern = [];
				for (var i:int = 0;i<colors.length;i++)
				{
					pattern.push(2);
				}
			} else {
				pattern = $pattern.slice();
			}
			initBitmap();
			paint();
		}
		
		public function draw( rectangle:Rectangle, animate:Boolean = true, steps:Number = 1 ):void
		{
			paint( rectangle );
			
			stepsPerFrame = ((steps % patternLength) + patternLength ) % patternLength;
			
			if (animate)
				addEventListener( Event.ENTER_FRAME, update );
			else {
				removeEventListener( Event.ENTER_FRAME, update );
				update( null );
			}
			
		}
		
		public function stop():void
		{
			removeEventListener( Event.ENTER_FRAME, update );
		}
		
		public function start():void
		{
			addEventListener( Event.ENTER_FRAME, update );
		}
		
		private function initBitmap():void
		{
			patternLength=0;
			for (var i:int = 0; i < pattern.length; i++ )
			{
				patternLength += pattern[i];
			}
			
			if ( patternMap != null) patternMap.dispose();
			patternMap = new BitmapData( patternLength, 1, true, 0);
			
			var x:int = 0;
			for (i = 0 ; i < pattern.length; i++ )
			{
				for (var j:int = 0 ; j <  pattern[i]; j++ )
				{
					patternMap.setPixel32( x++ , 0, colors[i] );
				}
			}
			
			copyRect = new Rectangle( 0 , 0 , patternLength - 1 , 1 );
		}
		
		
		private function paint( $r:Rectangle = null ):void
		{
			if ( $r != null )
			{
				r.left = $r.width < 0 ? $r.x + $r.width : $r.x;
				r.top = $r.height < 0 ? $r.y + $r.height : $r.y;
				r.width = $r.width < 0 ? -$r.width : $r.width;
				r.height = $r.height < 0 ? -$r.height : $r.height;
			}
			
			r.left = Math.round(r.left);
			r.top = Math.round(r.top);
			r.width = Math.round(r.width);
			r.height = Math.round(r.height);
			
			
			targetGraphics.clear();
			targetGraphics.lineStyle();
			m.a = m.d = 1
			m.b = m.c = 0;
			m.tx = r.left % patternLength
			m.ty = 0;
			
			targetGraphics.beginBitmapFill( patternMap, m );
			targetGraphics.drawRect( r.left, r.top, r.width, 1 );
			targetGraphics.endFill();
			
			m.a = -1;
			m.tx = r.left + r.width - 1 -  ( patternLength - ( r.width + r.height - 1) % patternLength);
			
			targetGraphics.beginBitmapFill( patternMap, m );
			targetGraphics.drawRect( r.left, r.top + r.height -1, r.width - 1, 1 );
			targetGraphics.endFill();
			
			m.a = m.d = 0;
			m.b = m.c = 1;
			m.tx = 0;
			m.ty = 1 + r.top % patternLength + patternLength - r.width % patternLength;
			 
			targetGraphics.beginBitmapFill( patternMap, m );
			targetGraphics.drawRect( r.left + r.width - 1, r.top, 1, r.height );
			targetGraphics.endFill();
			
			m.b = -1;
			m.ty = 1 + r.top % patternLength;
			
			targetGraphics.beginBitmapFill( patternMap, m );
			targetGraphics.drawRect( r.left, r.top + 1, 1, r.height - 1 );
			targetGraphics.endFill();
			
		}
		
		private function update( e:Event ):void
		{
			var p:uint;
			var s:int = stepsPerFrame;
			do{
				p = patternMap.getPixel32( patternMap.width - 1, 0 );
				patternMap.copyPixels( patternMap, copyRect, copyPoint );
				patternMap.setPixel32( 0, 0, p );
			} while ( --s > 0 );
		}
		
	}
}