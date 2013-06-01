package com.quasimondo.geom
{
	import com.quasimondo.geom.MixedPath;
	
	public class DrawingApiToGCode implements IGraphics
	{
		private const linefeed:String = "\n";
		
		private var _zDown:Number;
		private var _zUp:Number;
		private var _isUp:Boolean;
		private var _scale:Number;
		
		private var _gCode:String;
		private var _currentLineStyle:Number;
		
		public function DrawingApiToGCode( zDown:Number, zUp:Number, scale:Number )
		{
			_zDown = zDown;
			_zUp = zUp;
			_gCode = "";
			_scale = scale;
		}
		
		public function clear():void
		{
			_gCode = "";
		}
		
		public function moveUp():void
		{
			if ( !_isUp )
			{
				_gCode += "G0 Z "+_zUp + linefeed
				_isUp = true;
			}
		}
		
		public function moveDown():void
		{
			if ( _isUp )
			{
				_gCode += "G0 Z "+_zDown + linefeed
				_isUp = false;
			}
		}
		
		public function moveTo( x:Number, y:Number ):void
		{
			moveUp();
			_gCode += "G1 X " + (x * _scale)+ " Y " + (y * _scale ) + linefeed;
		}
		
		public function lineTo( x:Number, y:Number ):void
		{
			moveDown()
			_gCode += "G1 X " + (x * _scale ) + " Y " + (y * _scale ) + linefeed;
		}
		
		public function curveTo( cx:Number, cy:Number, x:Number, y:Number ):void
		{
			
		}
		
		public function drawCircle( x:Number, y:Number, r:Number ):void
		{
			
		}
		
		public function drawRect( x:Number, y:Number, width:Number, height:Number ):void
		{
			
		}
		
		public function lineStyle( strokeWidth:Number = 0, color:uint = 0, alpha:Number = 1 ):void
		{
			
		}
		
		public function getCode():String
		{
			return _gCode+"M2"+linefeed;
		}
	}
}