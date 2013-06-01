package com.quasimondo.bitmapdata
{
	public class Pixel
	{
		public var rgb:uint;
		
		public var r:uint;
		public var g:uint;
		public var b:uint;
		
		public var x:int;
		public var y:int;
		
		public var r_f:Number;
		public var g_f:Number;
		public var b_f:Number;
		
		public var luminance:int;
		public var brightness:int;
		public var saturation:int;
		
		public var hue:Number;
		
		public var saturation_f:Number;
		public var luminance_f:Number;
		public var brightness_f:Number;
		
		public var on:Boolean;
		
		private static const r_lum:Number = 0.212671;
		private static const g_lum:Number = 0.715160;
		private static const b_lum:Number = 0.072169;
		
		public function Pixel( $rgb:uint, $x:int = -1, $y:int = -1, calcHSB:Boolean = false )
		{
			rgb = $rgb;
			x = $x;
			y = $y;
			
			r = ( rgb >> 16 ) & 0xff;
			g = ( rgb >> 8) & 0xff;
			b =   rgb & 0xff;
			
			r_f = r / 255;
			g_f = g / 255;
			b_f = b / 255;
			
			luminance_f = r_f * r_lum + g_f * g_lum + b_f * b_lum;
			luminance = int( 0.5 + luminance_f * 255 );
			
			if ( calcHSB )
			{
				var min:Number = Math.min( r_f, g_f, b_f ); 
				var max:Number = Math.max( r_f, g_f, b_f ); 
				
				if (min==max)
				{ 
					hue = 0;
					saturation_f = saturation = 0;
				} else {
				
					var f:Number = ( r_f == min ) ? g_f-b_f : ( (g_f == min) ? b_f-r_f : r_f-g_f ); 
					var i:Number = ( r_f == min ) ? 3 : ( (g_f == min) ? 5 : 1 ); 
					
					hue  = Math.floor( ( i - f / ( max - min ) ) * 60 ) % 360; 
					saturation_f = ( max > 0 ? ( max - min ) / max : 0 ); 
					saturation = saturation_f * 100;
				}
				
				brightness_f = max; 
				brightness = max * 255; 
			}
		}
		
		public function setThreshold( thresh:int ):Boolean
		{
			on = luminance > thresh;
			return on;
		}
		
	}
	
	
}