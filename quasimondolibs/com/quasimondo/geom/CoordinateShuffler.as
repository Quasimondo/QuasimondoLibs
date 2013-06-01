/**
* CoordinateShuffler by Mario Klingemann. Dec 14, 2008
* Visit www.quasimondo.com for documentation, updates and more free code.
*
*
* Copyright (c) 2008 Mario Klingemann
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
**/

package com.quasimondo.geom
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Point;
	
	public class CoordinateShuffler
	{
		protected var _width:uint;
		protected var _height:uint;
		protected var _seed:uint;
		
		protected var _hLookup:Vector.<int>;
		protected var _vLookup:Vector.<int>;
		
		protected var _seed0:uint;
		protected var _seed1:uint;
		protected var _seed2:uint;
		
		protected var _shuffleDepth:uint;
		protected var _lookupTableSize:uint;
		protected var _maximumIndex:uint;
		protected var _currentIndex:uint;
		
		public function CoordinateShuffler( width:uint, height:uint, seed:uint = 0xBADA55, shuffleDepth:uint = 3, lookupTableSize:uint = 256 )
		{
			_width = width;
			_height = height;
			_maximumIndex = width * height;
			_currentIndex = 0;
			_shuffleDepth = shuffleDepth;
			_lookupTableSize = lookupTableSize;
			this.seed = seed;
		}
		
		/**
		* Returns a unique coordinate within the given width and height
		* Valid values for index go from 0 to width * height, 
		* bigger values will be wrapped around  
		**/
		public function getCoordinate( index:uint ):Point
		{
			index %= maximumIndex;
			var x:uint = index % _width;
			var y:uint = index / _width;
			var i:int;
			for ( i = 0; i < _shuffleDepth; i++ )
			{
				y = ( y + _hLookup[ uint((i * _width  + x) % _lookupTableSize)] ) % _height;
				x = ( x + _vLookup[ uint((i * _height + y) % _lookupTableSize)] ) % _width;
			}
			_currentIndex = ++index;
			return new Point( x,y );
		}
		
		
		/**
		* Returns a unique coordinate within the given width and height
		* and increments the internal index
		**/
		public function getNextCoordinate( ):Point
		{
			_currentIndex %= maximumIndex;
			return getCoordinate( _currentIndex++ );
		}
		
		/**
		* Returns a list of unique coordinate within the given width and height
		* The maximum amount of returned coordinates is width * height which constitutes all pixels, 
		**/
		public function getCoordinates( count:uint, index:uint = 0 ):Vector.<Point>
		{
			var list:Vector.<Point> = new Vector.<Point>();
			var x:uint, y:uint, xx:uint, yy:uint, i:int;
			
			_currentIndex = index;
			var j:int = 0;
			if ( count < 1 ) return list;
			_currentIndex %= maximumIndex;
			var ys:int = _currentIndex / _width;
			var xs:int = _currentIndex % width;
			
			for ( yy = ys; yy < _height; yy++ )
			{
				for ( xx = xs; xx < _width; xx++ )
				{
					x = xx;
					y = yy;
					for ( i = 0; i < _shuffleDepth; i++ )
					{
						y = ( y + _hLookup[ uint((i * _width  + x) % _lookupTableSize)] ) % _height;
						x = ( x + _vLookup[ uint((i * _height + y) % _lookupTableSize)] ) % _width;
					}
					list[j++] = new Point( x,y );
					_currentIndex = ( _currentIndex + 1 ) % maximumIndex;
					if ( count-- == 0 ) return list;
				}
				xs = 0;
			}
			return list;
		}
		
		/**
		* Controls how often the coordinates get shuffled around
		* A higher should create a more random looking pattern
		* minimum value is 1 
		**/
		public function set shuffleDepth( value:uint ):void
		{
			_shuffleDepth = Math.max( 1, value );
			seed = _seed;
		}
		
		public function get shuffleDepth():uint
		{
			return _shuffleDepth;
		}
		
		
		/**
		* Sets the size of the internal coordinate shuffle tables
		* Smaller values create a more geometric looking pattern
		* Bigger values need a bit longer for the initial setup of the table 
		* minimum value is 1 
		**/
		public function set lookupTableSize ( value:uint ):void
		{
			_lookupTableSize = Math.max( 1, value );
			seed = _seed;
		}
		
		public function get lookupTableSize():uint
		{
			return _lookupTableSize;
		}
		
		public function get maximumIndex():uint
		{
			return _maximumIndex;
		}	
	
		public function set width ( value:uint ):void
		{
			_width = width;
			_maximumIndex = width * height;
			seed = _seed;
		}
		
		public function get width():uint
		{
			return _width;
		}
		
		public function set height( value:uint ):void
		{
			_height = height;
			_maximumIndex = width * height;
			seed = _seed;
		}
		
		public function get height():uint
		{
			return _height;
		}
		
		/**
		* Sets the random seed 
		* different seeds will return the coordinates in different order 
		**/
		public function set seed( value:uint ):void
		{
			_seed = value;
			
			_seed0 = (69069*_seed) & 0xffffffff;
			if (_seed0 < 2) {
	            _seed0 += 2;
	        }
	
	        _seed1 = (69069* _seed0) & 0xffffffff;;
	        if (_seed1 < 8) {
	            _seed1 += 8;
	        }
	
	        _seed2 = ( 69069 * _seed1) & 0xffffffff;;
	        if (_seed2 < 16) {
	            _seed2 += 16;
	        }
	        
	        update();
		}
		
		public function resetIndex():void
		{
			_currentIndex = 0;
		}
		
		private function update():void
		{
			var i:uint;
			_hLookup = new Vector.<int>(_lookupTableSize,true);
			for ( i = _lookupTableSize; --i > -1; )
			{
				_hLookup[i] = getNextInt() % _height;
			}
			_vLookup = new Vector.<int>(_lookupTableSize,true);
			for ( i = _lookupTableSize; --i > -1; )
			{
				_vLookup[i] = getNextInt() % _width;
			}
		}
		
		private function getNextInt(): uint
		{
			_seed0 = ((( _seed0 & 4294967294) << 12 )& 0xffffffff)^((((_seed0<<13)&0xffffffff)^_seed0) >>> 19 );
       		_seed1 = ((( _seed1 & 4294967288) << 4) & 0xffffffff)^((((_seed1<<2)&0xffffffff)^_seed1)>>>25)
        	_seed2 =  ((( _seed2 & 4294967280) << 17) & 0xffffffff)^((((_seed2<<3)&0xffffffff)^_seed2)>>>11)
        	return _seed0 ^ _seed1 ^ _seed2;
		}

	}
}