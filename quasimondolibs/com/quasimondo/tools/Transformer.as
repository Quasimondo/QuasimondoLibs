// Transformer Class v1.0
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
	import com.quasimondo.events.CustomEvent;
	import com.quasimondo.geom.*;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;

	public class Transformer extends Sprite
	{
		
		
		[Event(name="change", type="flash.event.Event.CHANGE")]
		
   		private var tl:TransformerHandle;
   		private var t:TransformerHandle;
   		private var tr:TransformerHandle;
   		
   		private var l:TransformerHandle;
   		private var center:TransformerHandle;
   		private var r:TransformerHandle;
   		
   		private var bl:TransformerHandle;
   		private var b:TransformerHandle;
   		private var br:TransformerHandle;
		
		private var clip:DisplayObject;
		private var handles:Array;
		
        private var color:int = 0x808080;
		private var __options:int;
		
		private var selectedHandle:TransformerHandle;
		
		private var __currentMode:String;
		private var mouseAngle:Number;
		
		private var isDragging:Boolean;
		
		private var dragLine:LineSegment;
		
		private var p1:Point;
		private var p2:Point;
		private var p3:Point;
		
		private var tx:Number;
		private var ty:Number;
		
		private var tri1:Triangle;
		private var tri2:Triangle;
		
		private var activeRect:Rectangle = null;
		
		public static var i : Transformer = new Transformer( );
		
		private static const mouseIcon:TransformerMouseIcon = new TransformerMouseIcon();
		
		static public const SCALE:int 	= 1;
		static public const STRETCH:int = 2;
		static public const ROTATE:int 	= 4;
		static public const SHEAR:int 	= 8;
		static public const MOVE:int 	= 16;
		static public const ALL:int 	= 31;
		
		static public const MODE_SCALE_HORZ:String 		= "scalehori";
		static public const MODE_SCALE_VERT:String 		= "scalevert";
		static public const MODE_SCALE_CORNER1:String 	= "scalecorner1";
		static public const MODE_SCALE_CORNER2:String 	= "scalecorner2";
		static public const MODE_SHEAR_HORZ:String 		= "shearhori";
		static public const MODE_SHEAR_VERT:String 		= "shearvert";
		static public const MODE_ROTATE:String 			= "rotate";
		static public const MODE_DRAG:String 			= "drag";
		static public const MODE_IDLE:String 			= "idle";
		
		public function Transformer()
		{
			tl = new TransformerHandle();
			addChild( tl );
			t = new TransformerHandle();
			addChild( t );
			tr = new TransformerHandle();
			addChild( tr );
			l = new TransformerHandle();
			addChild( l );
			center = new TransformerHandle();
			addChild( center );
			r = new TransformerHandle();
			addChild( r );
			bl = new TransformerHandle();
			addChild( bl );
			b = new TransformerHandle();
			addChild( b );
			br = new TransformerHandle();
			addChild( br );
			
			handles = [tl,t,tr,l,r,bl,b,br,center];
			
		}
		
		public function hasActiveHandles():Boolean
		{
			return visible && selectedHandle != null;
		}
		
        public function getDeltaMatrix( parent:DisplayObjectContainer, child:DisplayObject ):Matrix 
        {
        	var parentMatrix:Matrix = parent.transform.concatenatedMatrix;
            parentMatrix.invert();
            var deltaMatrix:Matrix = child.parent.transform.concatenatedMatrix;
            deltaMatrix.concat( parentMatrix );
            return deltaMatrix;
        }

		public function show( clip:DisplayObject, showOptions:int, activeRect:Rectangle = null, forcedParent:DisplayObjectContainer = null, isDragging:Boolean = false  ):void
		{
			this.activeRect = activeRect;
			
			if ( visible && selectedClip == clip ) 
			{
				options = showOptions;
				return;
			}
			
			
			this.clip = clip;
		
			if (clip == null)
			{
				hide();
				return;
			}
			
			if ( forcedParent != null  )
			{
				if ( parent != forcedParent) forcedParent.addChild( this );
			} else if ( parent == null || parent != clip.parent )
			{
				clip.parent.addChild( this );
			} 
			visible = true;
			
			options = showOptions;
			
			x = 0; 
			y = 0; 
			
			if ( stage != null ) {
				onStage( );
				if ( isDragging ) {
					this.isDragging = true;
					mouseDown(null);
				}
			}
			
		}
		
		
		public function hide():void
		{
			visible = false;
			
			hideMouseIcon();
			
			if (stage != null )
			{
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			}
			
			clip = null;
			
			if ( parent != null )
			{
				parent.removeChild( this );
			}
			
		}
		
		
		public function get selectedClip():DisplayObject
		{
			return clip;
		}
		
		//public function set focusM
		
		public function set options( showOptions:int ):void
		{
			__options = showOptions;
			
			l.visible = r.visible = t.visible = b.visible = true;
			
			if ( showOptions & Transformer.STRETCH)
			{
				if ( showOptions & Transformer.SHEAR) 
				{
					l.modes = [Transformer.MODE_SCALE_HORZ, Transformer.MODE_SHEAR_VERT];
					r.modes = [Transformer.MODE_SCALE_HORZ, Transformer.MODE_SHEAR_VERT];
					t.modes = [Transformer.MODE_SCALE_VERT, Transformer.MODE_SHEAR_HORZ];
					b.modes = [Transformer.MODE_SCALE_VERT, Transformer.MODE_SHEAR_HORZ];
				} else {
					l.modes = [Transformer.MODE_SCALE_HORZ, Transformer.MODE_SCALE_HORZ];
					r.modes = [Transformer.MODE_SCALE_HORZ, Transformer.MODE_SCALE_HORZ];
					t.modes = [Transformer.MODE_SCALE_VERT, Transformer.MODE_SCALE_VERT];
					b.modes = [Transformer.MODE_SCALE_VERT, Transformer.MODE_SCALE_VERT];
				}
			} else if ( showOptions & Transformer.SHEAR) 
			{
				l.modes = [Transformer.MODE_SHEAR_VERT, Transformer.MODE_SHEAR_VERT];
				r.modes = [Transformer.MODE_SHEAR_VERT, Transformer.MODE_SHEAR_VERT];
				t.modes = [Transformer.MODE_SHEAR_HORZ, Transformer.MODE_SHEAR_HORZ];
				b.modes = [Transformer.MODE_SHEAR_HORZ, Transformer.MODE_SHEAR_HORZ];
			} else {
				l.visible = r.visible = t.visible = b.visible = false;
			}
			
			tl.visible = tr.visible = bl.visible = br.visible = true;
			if ( showOptions & Transformer.SCALE)
			{
				if ( showOptions & Transformer.ROTATE) 
				{
					tl.modes = [Transformer.MODE_SCALE_CORNER1, Transformer.MODE_ROTATE];
					tr.modes = [Transformer.MODE_SCALE_CORNER2, Transformer.MODE_ROTATE];
					bl.modes = [Transformer.MODE_SCALE_CORNER2, Transformer.MODE_ROTATE];
					br.modes = [Transformer.MODE_SCALE_CORNER1, Transformer.MODE_ROTATE];
				} else {
					tl.modes = [Transformer.MODE_SCALE_CORNER1, Transformer.MODE_SCALE_CORNER1];
					tr.modes = [Transformer.MODE_SCALE_CORNER2, Transformer.MODE_SCALE_CORNER2];
					bl.modes = [Transformer.MODE_SCALE_CORNER2, Transformer.MODE_SCALE_CORNER2];
					br.modes = [Transformer.MODE_SCALE_CORNER1, Transformer.MODE_SCALE_CORNER1];
				}
			} else if (showOptions & Transformer.ROTATE)
			{
				tl.modes = [Transformer.MODE_ROTATE, Transformer.MODE_ROTATE];
				tr.modes = [Transformer.MODE_ROTATE, Transformer.MODE_ROTATE];
				bl.modes = [Transformer.MODE_ROTATE, Transformer.MODE_ROTATE];
				br.modes = [Transformer.MODE_ROTATE, Transformer.MODE_ROTATE];
			} else {
				tl.visible = tr.visible = bl.visible = br.visible = false;
			}
			
			if ( showOptions & Transformer.MOVE)
			{
				center.visible = true;
				center.modes = [Transformer.MODE_DRAG, Transformer.MODE_DRAG];
			} else {
				center.visible = false;
			}
		}
		
		public function get options( ):int
		{
			return __options;
		}
		
		public function get mode( ):String
		{
			return __currentMode;
		}
		
		public function get active( ):Boolean
		{
			return clip != null;
		}
		
		private function onStage( ):void
		{
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			
			selectedHandle = null;
			__currentMode = Transformer.MODE_IDLE;
			isDragging = false;
			updateDisplayMatrix();
			updateClip();
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
			mouseMove();
		}
		
		private function updateDisplayMatrix():void
		{
			transform.matrix = getDeltaMatrix( parent, clip );
			var m:Matrix = clip.transform.matrix;

            normalizeUIElements();

			var bounds:Rectangle = clip.getBounds( clip );

			p1 = new Point (bounds.left,bounds.top);
			
			var p:Point = m.transformPoint( p1 );
			tl.setPosition(p.x,p.y);
			
			p2 = new Point (bounds.right,bounds.bottom);
			p = m.transformPoint( p2 );
			br.setPosition( p.x,p.y);
			
			p3 = new Point (bounds.left,bounds.bottom);
			
			p = m.transformPoint( p3 );
			bl.setPosition( p.x,p.y);
			
			p = new Point (bounds.right,bounds.top);
			p = m.transformPoint( p );
			tr.setPosition( p.x,p.y);
			updateLR();
			updateTB();
			updateCenter();
			
			tri1 = new Triangle( tl.point, tr.point, bl.point );
			tri2 = new Triangle( bl.point, tr.point, br.point );
		}
		
		private function mouseMove( event:MouseEvent = null):void
		{
			
			var d:Number, dx:Number, dy:Number, bestHandle:TransformerHandle, bestDist:Number, handle:TransformerHandle;
			if (stage==null) return;
			
			if ( !isDragging )
			{
				if ( activeRect != null && !activeRect.contains(mouseX,mouseY) )
				{
					showMouseIcon( "empty" , false );
					return;
				}
				
				
				bestDist = Number.MAX_VALUE;
				for each ( handle in handles )
				{
					dx = mouseX - handle.posX;
					dy = mouseY - handle.posY;
					
					d =  dx*dx + dy*dy;
					if ( d < bestDist )
					{
						bestDist = d;
						bestHandle = handle
					}
				}
				if ( bestDist > 400 ) {
					if ( tri1.isInsideXY(mouseX,mouseY) || tri2.isInsideXY(mouseX,mouseY))
					{
						bestHandle = center;
					} else {
						bestHandle = null;
					}
				}
				
				if ( bestHandle != selectedHandle )
				{
					if ( selectedHandle!=null ) selectedHandle.selected = false;
					if( bestHandle !=null) {
						bestHandle.selected = true;
						stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
						selectedHandle = bestHandle;
						showMouseIcon( bestHandle.getMode(), true );
					} else {
						if( stage != null ) stage.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
						hideMouseIcon();
						selectedHandle = null;
					}
					
					
				}
			} else {
				selectedHandle.mouseMove();	
				handleMoved(selectedHandle);
			}
			if( selectedHandle!=null) updateMouseIcon();
		}
		
		private function mouseDown( event:MouseEvent ):void
		{
			if ( activeRect != null && !activeRect.contains(mouseX,mouseY) || stage==null )
			{
				return;
			}
			
			if (selectedHandle == center )
			{
				var clips:Array = stage.getObjectsUnderPoint( new Point(stage.mouseX,stage.mouseY)); 
				//var topMostClip:DisplayObject = DisplayObject(clips[clips.length-2].parent.parent.parent);
/*				if ( topMostClip is SceneObject && topMostClip != clip )
				{
					stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUp );
					stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
					show(topMostClip,options,activeRect);
					return;
				}*/ 
			}
			
			if ( selectedHandle != null ) selectedHandle.mouseDown();
			startHandleDrag( selectedHandle );
			isDragging = true;
			if (stage!=null)
			{
				stage.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
				stage.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
			}
		}
		
		private function mouseUp( event:MouseEvent ):void
		{
			selectedHandle.mouseUp();
			isDragging = false;
			if (stage!=null)
			{
				stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUp );
				stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
			}
			mouseMove();
			
		}
		
		
		private function normalizeUIElements():void
		{
			var m1:Matrix, m2:Matrix;
			var handle:TransformerHandle;
			
			for each (handle in handles) 
			{
                m1 = handle.transform.concatenatedMatrix;
				m1.invert();
				m2 = handle.transform.matrix;
                m2.concat(m1);
				handle.transform.matrix = m2;
			}
			/*
			m1 = mouseIcon.transform.concatenatedMatrix;
			m1.invert();
			m2 = mouseIcon.transform.matrix;
            m2.concat(m1);
			mouseIcon.transform.matrix = m2;
			*/
		}
		
		private function handleMoved( handle:TransformerHandle ):void
		{
			var v1:Vector2, v2:Vector2, v3:Vector2, v4:Vector2, f:Number;
			
			switch (__currentMode) 
			{
				case Transformer.MODE_SCALE_HORZ :
				case Transformer.MODE_SCALE_VERT :
				case Transformer.MODE_SCALE_CORNER1 :
				case Transformer.MODE_SCALE_CORNER2 :
				case Transformer.MODE_SHEAR_HORZ :
				case Transformer.MODE_SHEAR_VERT :
					var p:Vector2 = dragLine.getClosestPointOnLine(  selectedHandle.point );
					handle.setPosition(p.x,p.y);
				break;
					
				case Transformer.MODE_ROTATE :
					mouseAngle = Math.atan2(mouseY-center.posY, mouseX-center.posX)- handle.startAngle;
				
				break;
					
				case Transformer.MODE_DRAG:
					mouseAngle = 0;
				break;
			}
			
			
			switch (__currentMode) {
				case Transformer.MODE_SCALE_HORZ:
					switch ( handle ) {
						case l :
							tl.setPoint( l.point.getMinus(r.point.getMinus( tr.point )) );
							bl.setPoint( l.point.getMinus(r.point.getMinus( br.point )) );
							break;
						case r :
							tr.setPoint( r.point.getMinus(l.point.getMinus( tl.point )) );
							br.setPoint( r.point.getMinus(l.point.getMinus( bl.point )) );
							break;
					}	
					
					updateTB();
					center.setPosition( 0.5 * (t.posX + b.posX), 0.5 * (t.posY+b.posY) );
				break;
			
				case Transformer.MODE_SCALE_VERT:
					switch ( handle) {
					case t :
						tl.setPoint( t.point.getMinus(b.point.getMinus( bl.point )) );
						tr.setPoint( t.point.getMinus(b.point.getMinus( br.point )) );
						break;
					case b :
							bl.setPoint( b.point.getMinus(t.point.getMinus( tl.point )) );
							br.setPoint( b.point.getMinus(t.point.getMinus( tr.point )) );
						break;
					}	
					updateLR();
					center.setPosition( 0.5 * (t.posX+b.posX), 0.5 * (t.posY+b.posY) );
				break;
			
			case Transformer.MODE_SCALE_CORNER1:
			case Transformer.MODE_SCALE_CORNER2:
				switch (handle) {
				case tl :
				
					v1 = center.point.getMinus(br.point);
				 	v2 = center.point.getMinus(bl.point);
					v3 = center.point.getMinus(tr.point);
					
					center.setPosition( 0.5 * (tl.posX+br.posX), 0.5 * (tl.posY+br.posY) );
					
					v4 = center.point.getMinus(br.point);
					f = v4.length / v1.length ;
					
					v2.multiply(f);
					v3.multiply(f);
					
					bl.setPoint(center.point.getMinus(v2));
					tr.setPoint(center.point.getMinus(v3));
					
					updateLR();
					updateTB();
					break;
					
				case tr :
					v1 = center.point.getMinus(bl.point);
					v2 = center.point.getMinus(br.point);
					v3 = center.point.getMinus(tl.point);
				
					center.posX = 0.5 * (tr.posX + bl.posX );
					center.posY = 0.5 * (tr.posY + bl.posY );
				
					v4 = center.point.getMinus(bl.point);
					f = v4.length / v1.length ;
					v2.multiply(f);
					v3.multiply(f);
					
					br.setPoint(center.point.getMinus(v2));
					tl.setPoint(center.point.getMinus(v3));
					
					updateLR();
					updateTB();
					break;
					
				case bl :
					v1 = center.point.getMinus(tr.point);
					v2 = center.point.getMinus(tl.point);
					v3 = center.point.getMinus(br.point);
				
					center.posX = 0.5 * (bl.posX + tr.posX );
					center.posY = 0.5 * (bl.posY + tr.posY );
					
					v4 = center.point.getMinus(tr.point);
					f = v4.length / v1.length ;
					v2.multiply(f);
					v3.multiply(f);
					
					tl.setPoint(center.point.getMinus(v2));
					br.setPoint(center.point.getMinus(v3));
					
					updateLR();
					updateTB();
					
					break;
					
				case br :
					v1 = center.point.getMinus(tl.point);
					v2 = center.point.getMinus(tr.point);
					v3 = center.point.getMinus(bl.point);
				
					center.posX = 0.5 * (tl.posX + br.posX );
					center.posY = 0.5 * (tl.posY + br.posY );
					
					v4 = center.point.getMinus(tl.point);
					f = v4.length / v1.length ;
					v2.multiply(f);
					v3.multiply(f);
					
					tr.setPoint(center.point.getMinus(v2));
					bl.setPoint(center.point.getMinus(v3));
					
					updateLR();
					updateTB();
					break;
				}
				break;
			
			case Transformer.MODE_SHEAR_HORZ:
				switch (handle) 
				{
				case t :
					tl.setPoint( t.point.getMinus(b.point.getMinus( bl.point )) );
					tr.setPoint( t.point.getMinus(b.point.getMinus( br.point )) );
				
					updateLR();
					
					center.posX = 0.5 * (bl.posX + tr.posX );
					center.posY = 0.5 * (bl.posY + tr.posY );
					break;
				case b :
					bl.setPoint( b.point.getMinus(t.point.getMinus( tl.point )) );
					br.setPoint( b.point.getMinus(t.point.getMinus( tr.point )) );
				
					updateLR();
					
					center.posX = 0.5 * (bl.posX + tr.posX );
					center.posY = 0.5 * (bl.posY + tr.posY );
					break;
				}
				break;
				
			case Transformer.MODE_SHEAR_VERT:
				switch (handle) {
				
				case l :
					tl.posX = l.posX - ( r.posX - tr.posX );
 					tl.posY = l.posY - ( r.posY - tr.posY );
 					
 					bl.posX = l.posX - ( r.posX - br.posX );
 					bl.posY = l.posY - ( r.posY - br.posY );
					
					updateTB();
					
					center.posX = 0.5 * (bl.posX + tr.posX );
					center.posY = 0.5 * (bl.posY + tr.posY );
					break;
					
				case r :
					tr.setPoint( r.point.getMinus(l.point.getMinus( tl.point )) );
					br.setPoint( r.point.getMinus(l.point.getMinus( bl.point )) );
				
					updateTB();
					updateCenter();
					center.posX = 0.5 * (bl.posX + tr.posX );
					center.posY = 0.5 * (bl.posY + tr.posY );
					break;
				}
				break;
				
			case Transformer.MODE_ROTATE:
			case Transformer.MODE_DRAG:
				tl.posX = center.posX + tl.radius*Math.cos(mouseAngle+tl.startAngle);
				tl.posY = center.posY + tl.radius*Math.sin(mouseAngle+tl.startAngle);
				br.posX = center.posX + br.radius*Math.cos(mouseAngle+br.startAngle);
				br.posY = center.posY + br.radius*Math.sin(mouseAngle+br.startAngle);
				tr.posX = center.posX + tr.radius*Math.cos(mouseAngle+tr.startAngle);
				tr.posY = center.posY + tr.radius*Math.sin(mouseAngle+tr.startAngle);
				bl.posX = center.posX + bl.radius*Math.cos(mouseAngle+bl.startAngle);
				bl.posY = center.posY + bl.radius*Math.sin(mouseAngle+bl.startAngle);
				
				updateLR();
				updateTB();
				break;
			}
			
			updateClip();
		};
		
		
		private function updateLR():void
		{
			l.posX = 0.5 * (tl.posX+bl.posX);
			l.posY = 0.5 * (tl.posY+bl.posY);
			r.posX = 0.5 * (tr.posX+br.posX);
			r.posY = 0.5 * (tr.posY+br.posY);
		}
		
		private function updateTB():void
		{
			t.posX = 0.5 * (tl.posX+tr.posX);
			t.posY = 0.5 * (tl.posY+tr.posY);
			b.posX = 0.5 * (br.posX+bl.posX);
			b.posY = 0.5 * (br.posY+bl.posY);
		}
		
		private function updateCenter():void
		{
			center.posX = 0.5 * (bl.posX + tr.posX );
			center.posY = 0.5 * (bl.posY + tr.posY );
		}
		
		private function startHandleDrag( handle:TransformerHandle ):void
		{
			switch (__currentMode )
			{
				case Transformer.MODE_ROTATE:
				case Transformer.MODE_DRAG:
				
					//center.posX =  0.5 * (tl.posX + br.posX);
					//center.posY =  0.5 * (tl.posY + br.posY);
					
					var dx:Number = tl.posX - center.posX;
					var dy:Number = tl.posY - center.posY;
					tl.startAngle = Math.atan2(dy, dx);
					tl.radius = Math.sqrt(dx*dx+dy*dy);
					
					dx = tr.posX-center.posX;
					dy = tr.posY-center.posY;
					tr.startAngle = Math.atan2(dy, dx);
					tr.radius = Math.sqrt(dx*dx+dy*dy);
					
					dx = bl.posX-center.posX;
					dy = bl.posY-center.posY;
					bl.startAngle = Math.atan2(dy, dx);
					bl.radius = Math.sqrt(dx*dx+dy*dy);
					
					dx = br.posX-center.posX;
					dy = br.posY-center.posY;
					br.startAngle = Math.atan2(dy, dx);
					br.radius = Math.sqrt(dx*dx+dy*dy);
					
				break;
				
				case Transformer.MODE_SCALE_HORZ:
					dragLine = new LineSegment( l.point.getClone( ), r.point.getClone( ) );
					
				break;
				
				case Transformer.MODE_SCALE_VERT:
					dragLine = new LineSegment( t.point.getClone( ), b.point.getClone( ) );
					
				break;
				
				case Transformer.MODE_SCALE_CORNER1:
				case Transformer.MODE_SCALE_CORNER2:
				
					dragLine = new LineSegment( handle.point.getClone( ), center.point.getClone( ) );
					
				break;
				
				case Transformer.MODE_SHEAR_HORZ:
					if ( handle == b)
					{
						dragLine = new LineSegment( bl.point.getClone( ), br.point.getClone( ) );
					} else {
						dragLine = new LineSegment( tl.point.getClone( ), tr.point.getClone( ) );
					}
				break;
				
				case Transformer.MODE_SHEAR_VERT:
					if ( handle == l)
					{
						dragLine = new LineSegment( bl.point.getClone( ), tl.point.getClone( ) );
					} else {
						dragLine = new LineSegment( br.point.getClone( ), tr.point.getClone( ) );
					}
					
				break;
				default:
					trace( "ERROR: transformer.__currentMode not set - fix timing or initialization order!");
				break;
			}
		
		};
		
		private function updateClip():void 
		{
            clip.transform.matrix = getMatrix();
			dispatchEvent( new CustomEvent( CustomEvent.CHANGE ) );
			
            var g:Graphics = this.graphics;
            g.clear();
            g.lineStyle(0, color );
			g.moveTo( tl.posX, tl.posY );
			g.lineTo( tr.posX, tr.posY );
			g.lineTo( br.posX, br.posY );
			g.lineTo( bl.posX, bl.posY );
			g.lineTo( tl.posX, tl.posY );
		
		};
		
		private function showMouseIcon( name:String, move:Boolean ):void 
		{
			Mouse.hide();
		
			if ( parent != null && !parent.contains(mouseIcon)) parent.addChild(mouseIcon); 
			if (__currentMode!=name)
			{
				__currentMode = name;
				mouseIcon.show(name);
			}

			if ( move != false) {
				updateMouseIcon();
			}
			
		};
		
		private function updateMouseIcon():void
		{
			if (!isDragging)
			{
				showMouseIcon(selectedHandle.getMode(),false);
			}
			mouseIcon.x = mouseX - 8;
			mouseIcon.y = mouseY - 8;
		};
		
		private function hideMouseIcon():void
		{
			Mouse.show();
			if (parent != null && parent.contains(mouseIcon)) parent.removeChild(mouseIcon); 
			
			__currentMode = Transformer.MODE_IDLE;
			
						
		};
		
		private function keyDown( event:KeyboardEvent ):void
		{
			
			var i:int;
			var handle:TransformerHandle;
			switch ( event.keyCode )
			{
				case Keyboard.UP:
					for each ( handle in handles )
					{
						handle.posY -= (event.shiftKey ? 10 : 1);
					}
					updateClip();
				break;
				
				case Keyboard.DOWN:
					for each ( handle in handles )
					{
						handle.posY += (event.shiftKey ? 10 : 1);;
					}
					updateClip();
				break;
				
				case Keyboard.LEFT:
					for each ( handle in handles )
					{
						handle.posX -= (event.shiftKey ? 10 : 1);;
					}
					updateClip();
				break;
				
				case Keyboard.RIGHT:
					for each ( handle in handles )
					{
						handle.posX += (event.shiftKey ? 10 : 1);;
					}
					updateClip();
				break;
				
				case Keyboard.ESCAPE:
					hide();
				break;
				
				case Keyboard.DELETE:
				case Keyboard.BACKSPACE:
					dispatchEvent( new CustomEvent( CustomEvent.DELETE ) );
				break;
			}
			
		
		}
		
		private function getMatrix():Matrix
		{
			
			var q1:Vector2 = tl.point;
			var q2:Vector2 = br.point;
			var q3:Vector2 = bl.point;

			var t1:Number = ( p1.x * (p3.y - p2.y) - p2.x * p3.y + p3.x * p2.y + (p2.x - p3.x) * p1.y );
			var t2:Number = ( p3.x * p2.y - p2.x * p3.y);
			var t3:Number = q2.y - q3.y;
			var t4:Number = q3.x - q2.x;

			var a:Number  = - ( p1.y * t4 - p2.y * q3.x + p3.y * q2.x + (p2.y - p3.y) * q1.x ) / t1;
			var b:Number  =   ( p2.y * q3.y + p1.y * t3 - p3.y * q2.y + (p3.y - p2.y) * q1.y ) / t1;
			var c:Number  =   ( p1.x * t4 - p2.x * q3.x + p3.x * q2.x + (p2.x - p3.x) * q1.x ) / t1;
			var d:Number  = - ( p2.x * q3.y + p1.x * t3 - p3.x * q2.y + (p3.x - p2.x) * q1.y ) / t1;
			var tx:Number =   ( p1.x * (p3.y * q2.x - p2.y * q3.x) + p1.y * (p2.x * q3.x - p3.x * q2.x) + t2 * q1.x ) / t1;
			var ty:Number =   ( p1.x * (p3.y * q2.y - p2.y * q3.y) + p1.y * (p2.x * q3.y - p3.x * q2.y) + t2 * q1.y ) / t1;
			return new Matrix( a,b,c,d,tx,ty );
		}
	
	}
}