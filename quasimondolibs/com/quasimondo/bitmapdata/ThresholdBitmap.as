// ThresholdBitmap Class v1.0
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2009 Mario Klingemann

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

package com.quasimondo.bitmapdata
{
	import __AS3__.vec.Vector;
	
	import com.quasimondo.filters.AdaptiveThresholdFilter;
	
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class ThresholdBitmap extends BitmapData
	{
		public static const FIXED:String        = "FIXED"; // fastest
		public static const ENTROPY:String      = "ENTROPY";
		public static const MOMENT:String       = "MOMENT"; // fastest histogram based
		public static const DISCRIMINANT:String = "DISCRIMINANT";
		public static const OTSU:String         = "OTSU";
		public static const ADAPTIVE:String     = "ADAPTIVE"; // slowest
		
		public var applyDespeckle:Boolean = false;
		public var convertToGray:Boolean = true;
		public var applyEdges:Boolean = false;
		public var invert:Boolean = false;
		
		
		private var _bitmap:BitmapData;
		private var _mode:String;
		private var _rgb:Boolean = false;
		private var _threshold:int = 127;
	
		private var _th:Array   = [];
		
		private var _histogram:Vector.<Vector.<Number>>;
		private var _probabilities:Vector.<Number> = new Vector.<Number>(256,true);
		
		private const smoothFilter:BlurFilter = new BlurFilter( 0, 0, 1);	
		
		private var adaptiveThresholdFilter:AdaptiveThresholdFilter;				   
		
		private var _rgb2blue:ColorMatrixFilter = new ColorMatrixFilter( [0,0,0,0,0, 0,0,0,0,0, 0.5,0.5,0,0, 0,0,0,1,0 ]);
		
		private var _cnv:ConvolutionFilter = new ConvolutionFilter( 3, 3, [ 1/255, 1/255, 1/255, 1/255, 0.2, 1/255, 1/255, 1/255, 1/255] )
		private var _dsp:Array;
		
		private var _cnv2:ConvolutionFilter = new ConvolutionFilter( 3, 3, [ -1, -2, -4, -8, 255, -16, -32, -64, -128] )
		private var _edg:Array;
		
		private var _ct:ColorTransform = new ColorTransform( 0,0,1,1,0,0,-254);
		 
		private var _inv:ConvolutionFilter = new ConvolutionFilter( 1, 1, [ -1], 0, 255 );
		
		
		private const origin:Point = new Point();
		
		public function ThresholdBitmap( map:BitmapData, mode:String = "FIXED", threshold:int = 127, rgb:Boolean = false )
		{
			super( map.width, map.height, false, 0 );
			
			_bitmap = map;
			_mode = mode;
			_threshold = threshold;
			adaptiveThresholdFilter = new AdaptiveThresholdFilter( this );
			render();
		}
		
		public function set mode( value:String ):void
		{
			_mode = value;
		}
		
		public function get mode():String
		{
			return _mode;
		}
		
		public function set thresholdValue( value:int ):void
		{
			_threshold = value;
			if ( _threshold < 0   ) _threshold = 0;
			if ( _threshold > 255 ) _threshold = 255;
			adaptiveThresholdFilter.threshold = value;
		}
		
		public function get thresholdValue( ):int
		{
			return _threshold;
		}
		
		public function get adaptiveRadius( ):Number
		{
			return adaptiveThresholdFilter.radius;
		}
		
		public function set adaptiveRadius( value:Number):void
		{
			adaptiveThresholdFilter.radius = value;
		}
		
		public function get adaptiveTolerance( ):int
		{
			return adaptiveThresholdFilter.tolerance;
		}
		
		public function set adaptiveTolerance( value:int):void
		{
			adaptiveThresholdFilter.tolerance = value;
		}
		
	 	public function set smooth(value:Number):void
	 	{
            smoothFilter.blurX = smoothFilter.blurY = value;
        }
        
        public function get smooth():Number
        {
            return smoothFilter.blurX;
        }
        
		public function render():void
		{
			copyPixels( _bitmap, _bitmap.rect, origin);
			if ( smooth > 1 ) applyFilter( this, rect, origin, smoothFilter );
			if ( invert) applyFilter( this, rect, origin, _inv );
			if ( convertToGray && _mode != ADAPTIVE ) applyFilter( this, rect, origin, _rgb2blue );
			
			
			var i:int, j:int;
			
			switch ( _mode )
			{
				case ADAPTIVE:
					adaptiveThresholdFilter.updateBlurMap()
					applyFilter( this.clone(), rect, origin, adaptiveThresholdFilter);
				break;
				
				case ENTROPY:
				case MOMENT:
				case DISCRIMINANT:
				case OTSU:
					_histogram = _bitmap.histogram( _bitmap.rect );
					var total:Number = 0;
					for ( i = 0; i < 256; i++ )
					{
						total += _histogram[2][i];	
					}
					
					for ( i = 0; i < 256; i++ )
					{
						_probabilities[i] = _histogram[2][i] / total;	
					}
					
					break;
			}
			
			switch ( _mode )
			{
				case MOMENT:
				// moment-preservation threshold
			
					var m1:Number;
					var m2:Number;
					var m3:Number;
					
					m1 = m2 = m3 = 0;
					 
					for ( i = 0; i < 256; i++) 
					{
						m1 += i * _probabilities[i];
						m2 += i * i * _probabilities[i];
						m3 += i * i * i * _probabilities[i];
					}
					
					var cd:Number = m2 - m1 * m1;
					var c0:Number = (-m2 * m2 + m1 * m3) / cd;
					var c1:Number = (-m3 + m2 * m1) / cd;
					var z0:Number = 0.5 * (-c1 - Math.sqrt (c1 * c1 - 4 * c0));
					var z1:Number = 0.5 * (-c1 + Math.sqrt (c1 * c1 - 4 * c0));
		
					var pd:Number = z1 - z0;
					var p0:Number = (z1 - m1) / pd;
					
					var pDistr:Number = 0.0;
					for (_threshold = 0; _threshold < 256; _threshold++) 
					{
						pDistr += _probabilities[_threshold];
						if (pDistr > p0)
						  break;
					}
					
				break;
				
				case ENTROPY:
				
					// maximum entropy threshold
					var Ps:Number, Hs:Number, psi:Number;
					
					var Hn:Number = 0;
					
					for ( i = 0; i < 256; i++)
					{
						if ( _probabilities[i] != 0)
						{
							Hn -= _probabilities[i] * Math.log( _probabilities[i] );
						}
					}
					
					var psiMax:Number = 0;
					
					for ( i = 1; i < 256; i++ ) 
					{
						Ps = 0;
						Hs = 0; 
						for ( j = 0; j < i; j++ ) 
						{
							Ps += _probabilities[j];
							if ( _probabilities[j] > 0.0)
							{
								Hs -= _probabilities[j] * Math.log ( _probabilities[j] );
							}
						}
						
						if (Ps > 0.0 && Ps < 1.0)
						{
							psi = Math.log ( Ps - Ps * Ps ) + Hs / Ps + ( Hn - Hs ) / ( 1 - Ps );
						}
						
						if ( psi > psiMax)
						{
							psiMax = psi;
							_threshold = i;
						}
					}
					break;
			
				case DISCRIMINANT:
					// discriminant (Kittler/Illingworth) threshold
					
					var nHistM1:int = 256 - 1;
					var discr:Number = 0;
					var discrM1:Number = 0;
					var discrMax:Number = 0;
					var discrMin:Number = 0;
					
					var m0Low:Number;
					var m0High:Number;
					var m1Low:Number;
					var m1High:Number;
					var varLow:Number;
					var varHigh:Number;
					
					for ( i = 1;  i < nHistM1; i++) 
					{
						m0Low = m0High = m1Low = m1High = varLow = varHigh = 0;
						for ( j = 0; j <= i; j++) 
						{
							m0Low += _probabilities[j];
							m1Low += j * _probabilities[j];
						}
						m1Low = (m0Low != 0) ? m1Low / m0Low : i;
						for (j = i + 1; j < 256; j++) 
						{
							m0High += _probabilities[j];
							m1High += j * _probabilities[j];
						}
						m1High = (m0High != 0.0) ? m1High / m0High : i;
						for (j = 0; j <= i; j++)
						{
							varLow += (j - m1Low) * (j - m1Low) * _probabilities[j];
						}
						var stdDevLow:Number = Math.sqrt (varLow);
						for (j = i + 1; j < 256; j++)
						{
							varHigh += (j - m1High) * (j - m1High) * _probabilities[j];
						}
						var stdDevHigh:Number = Math.sqrt (varHigh);
						if (stdDevLow == 0)
						{
							stdDevLow = m0Low;
						}
						if (stdDevHigh == 0)
						{
							stdDevHigh = m0High;
						}
						var term1:Number = (m0Low != 0) ? m0Low * Math.log (stdDevLow / m0Low) : 0;
						var term2:Number = (m0High != 0) ? m0High * Math.log (stdDevHigh / m0High) : 0;
						discr = term1 + term2;
						if (discr < discrM1)
						{
							discrMin = discr;
						}
						if (discrMin != 0 && discr >= discrM1)
						{
							break;
						}
						discrM1 = discr;
					}

					_threshold = i;
					break;
					
				case OTSU:
					//  Otsu's discriminant method threshold
					
				 nHistM1 = 256 - 1;
					var varWMin:Number = 100000000;
					
					for (i = 1; i < nHistM1; i++)
					{
						m0Low = m0High = m1Low = m1High = varLow = varHigh = 0.0;
						for (j = 0; j <= i; j++) 
						{
							m0Low += _probabilities[j];
							m1Low += j * _probabilities[j];
						}
						m1Low = (m0Low != 0.0) ? m1Low / m0Low : i;
						for (j = i + 1; j < 256; j++) 
						{
							m0High += _probabilities[j];
							m1High += j * _probabilities[j];
						}
						m1High = (m0High != 0.0) ? m1High / m0High : i;
						for (j = 0; j <= i; j++)
						{
							varLow += (j - m1Low) * (j - m1Low) * _probabilities[j];
						}
						for (j = i + 1; j < 256; j++)
						{
							varHigh += (j - m1High) * (j - m1High) * _probabilities[j];
						}
		
						var varWithin:Number = m0Low * varLow + m0High * varHigh;
						if (varWithin < varWMin) 
						{
							varWMin = varWithin;
							_threshold = i;
						}
					}
					break;
			}
		
			if ( _mode != ADAPTIVE )
			{
				for ( i = 0; i < 256; i++ )
				{
					_th[i] = ( i < (_threshold & 0xff)  ? 0 : 0xffffff );
				}
			
				paletteMap( this, rect, origin, null, null, _th );
			}
			if ( applyDespeckle ) despeckle();
			if ( applyEdges ) showEdges();
		}
	
		private function despeckle():void
		{
			if ( _dsp == null )
			{
				_dsp = [];
				for ( var i:int = 0; i < 52; i++ )
				{
					_dsp[i] = 0;	
				}
				for ( i = 52; i < 256; i++ )
				{
					_dsp[i] = 0xffffff;	
				}
				_dsp[8] = 0xffffff;
			}
			applyFilter( this, rect, origin, _cnv );
			paletteMap( this, rect, origin, [], [], _dsp );
			
		}
		
		private function showEdges():void
		{
			if ( _edg == null )
			{
				_edg = [];
				for ( var i:int = 0; i < 256; i++ )
				{
					_edg[i] = 0xffffff;	
				}
				_edg[255] = _edg[0] = _edg[255-1] = _edg[255-2] = _edg[255-4] = _edg[255-8] = _edg[255-16] = _edg[255-32] = 
				_edg[255-64] = _edg[255-128] = 0;
				
			}
			colorTransform( rect, _ct );
			applyFilter( this, rect, origin, _cnv2 );
			paletteMap( this, rect, origin, [], [], _edg );
		}
		
	}
	
}