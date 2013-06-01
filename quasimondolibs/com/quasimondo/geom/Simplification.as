/* 
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

	/** A Simplification takes an Array of Polygons and simplifies the curves. It acts on country level,
	 *  so simplification of an entire region would require several Simplifications, one for each country.
	 *  The Simplification class is a superclass, supposed to be inherited with a specific simplification algorithm. 
	 */
package com.quasimondo.geom
{
	

	public class Simplification
	{
		
		public function simplify( origPolygons:Vector.<Polygon>, epsilon:Number):Vector.<Polygon> 
		{ 
			var simplerPolygons:Vector.<Polygon>  = new Vector.<Polygon> (origPolygons.length, true);
			for (var i:int=0; i< origPolygons.length; i++) //Loop over all polygons of the country
			{
				simplerPolygons[i] = simplifyPolygon(origPolygons[i], epsilon );
			} // end loop over polygons
			return simplerPolygons;
		}

		//This function is supposed to be overridden
		public function simplifyPath( points:Vector.<Vector2>, epsilon:Number):Vector.<Vector2> 
		{
			return points;
		}
		
		public function simplifyPolygon( polygon:Polygon, epsilon:Number, clonePoints:Boolean = true):Polygon
		{
			return Polygon.fromVector( simplifyPath( polygon.getCopyOfPoints(), epsilon), clonePoints );
		}
		/*
		public function simplifyCompoundShape( polygon:CompoundShape, epsilon:Number, clonePoints:Boolean = true):CompoundShape
		{
			return Polygon.fromVector( simplifyPath( polygon.getCopyOfPoints(), epsilon), clonePoints );
		}
		*/
	}
}