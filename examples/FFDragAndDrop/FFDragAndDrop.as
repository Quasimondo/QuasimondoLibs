/*

Drag-and.drop Demo for FireFox 3.6 and above

released under MIT License (X11)
http://www.opensource.org/licenses/mit-license.php

Author: Mario Klingemann
http://www.quasimondo.com

This proof of concept shows how to use the new drag-and-drop features
of Firefox 3.6 in Flash. It allows to drag files directly from the
desktop into Flash and access the binary content.

This Javascript part of the code is based in big parts on the example 
by Paul Rouget on this page:
http://hacks.mozilla.org/2009/12/file-drag-and-drop-in-firefox-3-6/

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

package
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	[SWF(frameRate='64',backgroundColor='0x000000')]
	public class FFDragAndDrop extends Sprite
	{
		private var console:TextField;
		private var background:Shape;
		private var holder:Sprite;
		
		public function FFDragAndDrop()
		{
			init();
		}
		
		private function init():void
		{
			stage.scaleMode = "noScale";
			stage.align = "TL";
			
			ExternalInterface.addCallback( "onDropData", onDropData );
			ExternalInterface.addCallback( "onDropFile", onDropFile );
			ExternalInterface.addCallback( "onDragEnter", onDragEnter );
			ExternalInterface.addCallback( "onDragLeave", onDragLeave );
			ExternalInterface.addCallback( "onDragOver", onDragOver );
			
			background = new Shape();
			background.graphics.beginFill(0xff8000);
			background.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			background.graphics.endFill();
			background.visible = false;
			addChild(background);
			
			holder = new Sprite();
			addChild( holder );
			
			console = new TextField();
			console.x = 5;
			console.y = 5;
			console.width = stage.stageWidth - 10;
			console.autoSize = "left";
			console.backgroundColor = 0x000000;
			console.background = true;
			addChild( console );
			
			var fmt:TextFormat = new TextFormat( "Verdana",10,0xffffff);
			console.defaultTextFormat = fmt;
			
			console.appendText("Drop Files Here\n");
			
			
		}
		
		private function onDropData( data:Object ):void
		{
			console.text = "Dropped Data:\n";
			for ( var i:String in data ) {
				console.appendText( i + ": "+data[i] +"\n");
			}
		}
		
		private function onDropFile( type:String, file:Object ):void
		{
			console.text = "File dropped | ";
			console.appendText( "mime type: "+ type);
			console.appendText( " | file length: " +file.length +"bytes");
			switch ( type )
			{
				case "application/x-shockwave-flash":
				case "image/jpeg":
				case "image/png":
				case "image/gif":
					
					var ba:ByteArray = new ByteArray();
					for ( var i:int = 0; i < file.length; i++ )
					{
						ba.writeByte( String(file).charCodeAt(i) );
					}
					
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onAssetComplete );
					loader.loadBytes( ba );
					
				break;
			}
			
		}
		
		private function onAssetComplete( event:Event ):void
		{
			var loader:Loader = LoaderInfo(event.target).loader;
			loader.x = mouseX - loader.width * 0.5;
			loader.y = mouseY - loader.height * 0.5;
			holder.addChild( loader );
			
		}
		
		private function onDragEnter( data:Object ):void
		{
			background.alpha = 1;
			background.visible = true;
			
			console.text = "onDragEnter:\n";
			for ( var i:String in data ) {
				console.appendText( i + ": "+data[i] +"\n");
			}
		}
		
		private function onDragLeave( data:Object ):void
		{
			background.visible = false;
			console.text = "onDragLeave:\n";
			for ( var i:String in data ) {
				console.appendText( i + ": "+data[i] +"\n");
			}
		}
		
		private function onDragOver( data:Object ):void
		{
			background.alpha = 0.5;
			console.text = "onDragOver:\n";
			for ( var i:String in data ) {
				console.appendText( i + ": "+data[i] +"\n");
			}
		}
	}
}