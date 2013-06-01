// TransformerHandle Class v1.0
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2010 Mario Klingemann

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
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import com.quasimondo.geom.Vector2;
			
	public class TransformerHandle extends Sprite
	{
		public var modes:Array;
		public var point:Vector2 = new Vector2();
		
		public var startAngle:Number;
		public var radius:Number;
		
		private var __mouseIsDown:Boolean = false;
		private var __selected:Boolean = false;
		
		private var transformer:Transformer;
	
		private var __lastX:Number;
		private var __lastY:Number;
		
		private const HANDLE_SIZE:int = 7;
		private const HITAREA_SIZE:int = 20;
		
		public function TransformerHandle()
		{
			updateGrabber();
		}
		
		private function initPoint():void
		{
			point.setValue( x, y );
			transformer = Transformer( parent );
		}
		
		public function set selected( value:Boolean ):void
		{
			__selected = value
			updateGrabber();
		}
		
		public function mouseDown():void
		{
			__lastX = parent.mouseX;
			__lastY = parent.mouseY;
			__mouseIsDown = true;
			updateGrabber();
		}
		
		public function mouseUp():void
		{
			__mouseIsDown = false;
			updateGrabber();
		}
		
		private function updateGrabber():void
		{
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill( 0, 0);
			graphics.drawRect( - HITAREA_SIZE * 0.5, - HITAREA_SIZE * 0.5, HITAREA_SIZE, HITAREA_SIZE );
			graphics.lineStyle( 0 );
			graphics.beginFill(  __selected ? ( __mouseIsDown ? 0x000000 : 0xff8000 ) : 0xffffff );
			graphics.drawRect( - HANDLE_SIZE *0.5, - HANDLE_SIZE*0.5, HANDLE_SIZE, HANDLE_SIZE );
			graphics.endFill();
		}
		
		public function getMode():String
		{
			var dx:Number = mouseX;
			var dy:Number = mouseY;
			
			return String( mouseX * mouseX + mouseY * mouseY < 200 ? modes[0] : modes[1] );
		}
		
		public function mouseMove():void
		{
			point.x += parent.mouseX - __lastX;
			point.y += parent.mouseY - __lastY;
			__lastX = parent.mouseX;
			__lastY = parent.mouseY;
			x = Math.round(  point.x  );
			y = Math.round(  point.y );
		};
		
		public function setPosition( x:Number, y:Number ):void
		{
			point.x =  x;
			point.y =  y;
			this.x = Math.round( x );
			this.y = Math.round( y );
		}
		
		public function setPoint( p:Vector2 ):void
		{
			point.x = p.x;
			point.y = p.y;
			x = Math.round(  p.x );
			y = Math.round(  p.y );
		}
		
		public function set posX( x:Number ):void
		{
			point.x =  x;
			this.x = Math.round( x );
		}
		
		public function set posY( y:Number ):void
		{
			point.y = y;
			this.y = Math.round( y );
		}
		
		public function get posX( ):Number
		{
			return point.x;
		}
		
		public function get posY( ):Number
		{
			return point.y;
		}
		
	}
}