package com.quasimondo.PixelBenderForCanvas
{
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ShaderEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class PibecaJob extends EventDispatcher
	{
		public var id:String;
		public var inputBitmap:BitmapData;
		public var outputBitmap:BitmapData;
		public var x:int;
		public var y:int;
		
		protected var kernelURL:String;
		protected var parameters:Object;
		protected var filterLoader:URLLoader;
		
		public function PibecaJob( id:String, bitmap:BitmapData, x:int, y:int, kernelURL:String, parameters:Object )
		{
			this.id = id;
			this.inputBitmap = bitmap;
			this.x = x;
			this.y = y;
			this.kernelURL = kernelURL;
			this.parameters = parameters;
		}
		
		public function run():void
		{
			loadFilter();
		}
		
		private function loadFilter():void
		{
			var request:URLRequest = new URLRequest( kernelURL );
			filterLoader = new URLLoader();
			filterLoader.dataFormat = URLLoaderDataFormat.BINARY;
			filterLoader.addEventListener( Event.COMPLETE, onFilterLoadComplete );
			filterLoader.load( request );
		}
		
		private function onFilterLoadComplete( event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			var shader:Shader = new Shader( loader.data );
			shader.data.src.input = inputBitmap;
			shader.data.src.width = inputBitmap.width;
			shader.data.src.height = inputBitmap.height;
			
			for ( var i:String in parameters )
			{
				shader.data[i].value = parameters[i];
			}
			
			outputBitmap = inputBitmap.clone();
			var shaderJob:ShaderJob = new ShaderJob( shader, outputBitmap, inputBitmap.width, inputBitmap.height );
			shaderJob.addEventListener( ShaderEvent.COMPLETE, onShaderComplete );
			shaderJob.start();
		}
		
		private function onShaderComplete( event:ShaderEvent ):void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
	}
}