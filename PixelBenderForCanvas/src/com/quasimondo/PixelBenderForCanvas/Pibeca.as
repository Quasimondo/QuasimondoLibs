/*

Pibeca - Pixel Bender For Canvas v0.1

Pibeca allows the use of The Adobe® Pixel Bender™ technology
together with Canvas by having the bitmaps processed by
Adobe® Flash™. This tool is not endorsed or supported by Adobe®.

Version: 	0.1
Author:		Mario Klingemann
Contact: 	mario@quasimondo.com
Website:	http://www.quasimondo.com/PixelBenderForCanvas

Copyright (c) 2010 Mario Klingemann

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/


package com.quasimondo.PixelBenderForCanvas
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class Pibeca extends Sprite
	{
		protected const LUT:Vector.<String> = new Vector.<String>(256,true);
		protected const replaceStrings:Vector.<int> = new Vector.<int>(3,true);
		protected const jobs:Dictionary = new Dictionary();
		protected const bitmaps:Dictionary = new Dictionary();
		protected const pendingPNG:Dictionary = new Dictionary();
		protected const loader2bitmapID:Dictionary = new Dictionary();
		protected const pendingJob:Dictionary = new Dictionary();
		
		public function Pibeca()
		{
			init();
		}
		
		private function init():void
		{
			stage.scaleMode = "noScale";
			stage.align = "TL";
			
			initLUT();
			
			ExternalInterface.addCallback("hasBitmap", hasBitmap );
			ExternalInterface.addCallback("setBitmap", setBitmap );
			ExternalInterface.addCallback("setPNG", setPNG );
			ExternalInterface.addCallback("disposeBitmap", disposeBitmap );
			ExternalInterface.addCallback("runFilter", runFilter );
			
		}
		
		private function initLUT():void
		{
			for ( var i:int = 2; i < 256; i++ )
			{
				LUT[i] = String.fromCharCode( i );
			}
			LUT[0]  = String.fromCharCode(1)  + String.fromCharCode(1);
			LUT[1]  = String.fromCharCode(1)  + String.fromCharCode(2);
			LUT[92] = String.fromCharCode(92) + String.fromCharCode(92);
			
			replaceStrings[1] = 0;
			replaceStrings[2] = 1;
			
		}
		
		private function setBitmap( bitmapID:String, width:int, height:int, imageData:String ):void
		{
			var ba:ByteArray = new ByteArray();
			var i:int = 0;
			var j:int = 0;
			var d:int;
			while ( i < imageData.length )
			{
				ba[j++] = ( ( d = imageData.charCodeAt(i++) ) != 1 ? d : replaceStrings[ imageData.charCodeAt(i++) ] )
			}
			var bitmap:BitmapData = new BitmapData( width, height, true, 0 );
			bitmap.setPixels( bitmap.rect, ba );
			ba.clear();
			if ( bitmaps[bitmapID] != null ) BitmapData(bitmaps[bitmapID]).dispose();
			bitmaps[bitmapID] = bitmap;
		}
		
		private function setPNG( bitmapID:String, pngData:String ):void
		{
			var loader:Loader = new Loader();
			pendingPNG[bitmapID] = true;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPNGLoaded );
			loader2bitmapID[loader.contentLoaderInfo] = bitmapID;
			if ( bitmaps[bitmapID] != null ) {
				BitmapData(bitmaps[bitmapID]).dispose();
				bitmaps[bitmapID] = null;
				delete bitmaps[bitmapID];
			}
			var bytes:ByteArray = Base64.decode( pngData );
			bytes.position = 0;
			loader.loadBytes( bytes );
		}
		
		private function onPNGLoaded( event:Event ):void
		{
			var bitmapID:String = loader2bitmapID[event.currentTarget];
			
			loader2bitmapID[event.currentTarget] = null;
			delete loader2bitmapID[event.currentTarget];
			
			pendingPNG[bitmapID] = null;
			delete pendingPNG[bitmapID];
			
			event.currentTarget.removeEventListener(Event.COMPLETE, onPNGLoaded );
			
			var content:Bitmap = Bitmap(LoaderInfo( event.currentTarget ).content);
			var bitmap:BitmapData = content.bitmapData;
			bitmaps[bitmapID] = new BitmapData(bitmap.width, bitmap.height,true,0);
			bitmaps[bitmapID].copyPixels( bitmap, bitmap.rect, bitmap.rect.topLeft );
			
			if ( pendingJob[bitmapID] != null )
			{
				PibecaJob(pendingJob[bitmapID]).inputBitmap = bitmaps[bitmapID];
				PibecaJob(pendingJob[bitmapID]).run();
				pendingJob[bitmapID] = null;
				delete pendingJob[bitmapID];
			}
		}
		
		private function disposeBitmap( bitmapID:String ):void
		{
			bitmaps[bitmapID] = null;
			delete bitmaps[bitmapID];
		}
		
		private function hasBitmap( bitmapID:String ):Boolean
		{
			return (bitmaps[bitmapID] != null);
		}
		
		
		private function runFilter( bitmapID:String, targetCanvasID:String, targetX:int, targetY:int, kernelURL:String, parameters:Object ):void
		{
			
			if ( bitmaps[bitmapID] == null && pendingPNG[bitmapID] == null ) return;
			
			var job:PibecaJob = new PibecaJob( targetCanvasID, bitmaps[bitmapID], targetX, targetY, kernelURL, parameters );
			jobs[job] = job;
			job.addEventListener( Event.COMPLETE, onJobComplete );
						
			if ( !pendingPNG[bitmapID] )
			{
				job.run();
			} else {
				pendingJob[bitmapID] = job;
			}
		}
		
		private function onJobComplete( event:Event ):void
		{
			var job:PibecaJob = PibecaJob( event.target );
			job.removeEventListener( Event.COMPLETE, onJobComplete );
			jobs[job.id] = null;
			delete jobs[job.id];
			
			var lut:Vector.<String> = LUT;
			var i:int, vi:int;
			
			var v:Vector.<uint> = job.outputBitmap.getVector( job.outputBitmap.rect );
			var s:String = "";
			i = -1;
			while ( ++i < v.length )
			{
				s += lut[int(((vi = v[i]) >> 16) & 0xff)] 
				   + lut[int((vi >> 8) & 0xff)] 
				   + lut[int(vi & 0xff)] 
				   + lut[int((vi >> 24) & 0xff)];
			}
			ExternalInterface.call( "onFilterComplete", job.id, job.x, job.y, job.outputBitmap.width, job.outputBitmap.height, s );
		}
	}
}