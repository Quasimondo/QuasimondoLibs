// NumericTableIterator Class v1.0
//
//  helper class for com.quasimondo.utils.Table
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
package com.quasimondo.utils
{
	public class NumericTableIterator implements ITableIterator
	{
		private var value:Number;
		private var steps:int;
		private var d:Number;
		
		public function NumericTableIterator( min:Number = 1, max:Number = 1, d:Number = 1 )
		{
			value = min;
			this.d = d;
			if ( d == 0 || ((min < max) != ( d > 0 )) )
			{
				steps = 1;	
			} else {
				steps = (max - min) / d;
			}
		}
			
		public function hasNext():Boolean
		{
			return steps >= 0;
		}
		
		public function next():*
		{
			if ( !hasNext() ) return null;
			
			var currentValue:Number = value;
			value += d;
			steps--;
			return currentValue;
		}
	}
}