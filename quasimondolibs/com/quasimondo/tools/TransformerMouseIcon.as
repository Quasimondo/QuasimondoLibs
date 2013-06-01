// TransformerMouseIcon Class v1.0
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
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	public class TransformerMouseIcon extends Sprite
	{
		static public const MODE_SCALE_HORZ:String 		= "scalehori";
		static public const MODE_SCALE_VERT:String 		= "scalevert";
		static public const MODE_SCALE_CORNER1:String 	= "scalecorner1";
		static public const MODE_SCALE_CORNER2:String 	= "scalecorner2";
		static public const MODE_SHEAR_HORZ:String 		= "shearhori";
		static public const MODE_SHEAR_VERT:String 		= "shearvert";
		static public const MODE_ROTATE:String 			= "rotate";
		static public const MODE_DRAG:String 			= "drag";
		static public const MODE_IDLE:String 			= "idle";
		
		[Embed(source="/assets/cursors/drag-cursor.gif")]
		private var Cursor_Drag:Class;
		
		[Embed(source="/assets/cursors/rotate-cursor.gif")]
		private var Cursor_Rotate:Class;
		
		[Embed(source="/assets/cursors/scale_corner1-cursor.gif")]
		private var Cursor_Scale_Corner1:Class;
		
		[Embed(source="/assets/cursors/scale_corner2-cursor.gif")]
		private var Cursor_Scale_Corner2:Class;
		
		[Embed(source="/assets/cursors/scale-side1-cursor.gif")]
		private var Cursor_Scale_Horizontal:Class;
		
		[Embed(source="/assets/cursors/scale-side2-cursor.gif")]
		private var Cursor_Scale_Vertical:Class;
		
		[Embed(source="/assets/cursors/shear-hori-cursor.gif")]
		private var Cursor_Shear_Horizontal:Class;
		
		[Embed(source="/assets/cursors/shear-vert-cursor.gif")]
		private var Cursor_Shear_Vertical:Class;
		
		
		private var iconMaps:Dictionary;
		
		public function TransformerMouseIcon()
		{
			mouseEnabled = false;
			iconMaps = new Dictionary();
			iconMaps[MODE_DRAG] 		 = new Cursor_Drag();
			iconMaps[MODE_ROTATE]  		 = new Cursor_Rotate();
			iconMaps[MODE_SCALE_CORNER1] = new Cursor_Scale_Corner1();
			iconMaps[MODE_SCALE_CORNER2] = new Cursor_Scale_Corner2();
			iconMaps[MODE_SCALE_HORZ] 	 = new Cursor_Scale_Horizontal();
			iconMaps[MODE_SCALE_VERT] 	 = new Cursor_Scale_Vertical();
			iconMaps[MODE_SHEAR_HORZ] 	 = new Cursor_Shear_Horizontal();
			iconMaps[MODE_SHEAR_VERT] 	 = new Cursor_Shear_Vertical();
		
			name = "mouseIcon";
		}
		
		public function hide():void
		{
			while ( this.numChildren > 0 )
			{
				this.removeChildAt(0);
			}
		}
		
		public function show( iconID:String ):void
		{
			while ( this.numChildren > 0 )
			{
				this.removeChildAt(0);
			}
			var icon:Bitmap;
			icon = iconMaps[iconID];
			
			if ( icon != null )
			{
				icon.smoothing = false;
				icon.pixelSnapping = "always";
				addChild( icon );
			}
		}
		
	}
}