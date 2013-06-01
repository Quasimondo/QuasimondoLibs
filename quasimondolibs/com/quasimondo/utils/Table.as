// Table Utility v1.0
//
// Modelled after the Mathematica Table Method
// http://reference.wolfram.com/mathematica/ref/Table.html
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
	public function Table( expression:Function, iterators:Vector.<ITableIterator> ):Vector.<*>
	{
		var values:Vector.<Vector.<*>> = new Vector.<Vector.<*>>(); 
		var indices:Vector.<int> = new Vector.<int>(iterators.length,true);
		
		for ( var i:int = 0; i < iterators.length; i++ )
		{
			values[i] = new Vector.<*>();
			var iterator:ITableIterator = iterators[i];
			while ( iterator.hasNext() )
			{
				values[i].push( iterator.next() );
			}
		}
		
		var result:Vector.<*> = new Vector.<*>(values[0].length, true );
		var currentBin:Vector.<*>;
		while (indices[0] < values[0].length )
		{
			var arguments:Array = [];
			currentBin = result;
			
			for ( i = 0; i < indices.length; i++ )
			{
				if ( i < indices.length - 1  )
				{
					if ( currentBin[indices[i]] == null ) currentBin[indices[i]] = new Vector.<*>(values[i+1].length,true);
					currentBin = currentBin[indices[i]];
				}
				arguments.push(values[i][indices[i]]);
			}
			
			currentBin[indices[int(indices.length-1)]] = expression.apply( null, arguments );
			
			for ( i = indices.length; --i > -1; )
			{
				indices[i]++;
				if ( indices[i] == values[i].length && i != 0 )
				{
					indices[i] = 0;
				} 
				else 
				{
					break;
				}
			}
		}
		
		
		return result;
	}
	
}