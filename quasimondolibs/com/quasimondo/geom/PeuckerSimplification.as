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

package  com.quasimondo.geom
{
	

	/** This class applies the Ramer-Douglas-Peucker simplification algorithm to the polygons of a country. 
	 */
	public class PeuckerSimplification extends Simplification
	{

		public override function simplifyPath(points:Vector.<Vector2>, epsilon:Number):Vector.<Vector2>
		{
			if (points.length < 3) { //Safeguard against infinite recursion
				return points;
			}
			
			var cutIndex:int = 0;
			var d:Number;
			var recResults1:Vector.<Vector2>;
			var recResults2:Vector.<Vector2>;
			
			//Find the point with maximum distance
			
			var p1:Vector2 = points[0]; //startIndex coordinate
			var p2:Vector2 = points[points.length-1]; //endIndex coordinate
			
			var dmax:Number = points[1].distanceToLine( p1, p2);
			
			for (var i:int=2; i<points.length-2; i++) { 
				
				d = points[i].distanceToLine( p1, p2);
				if (d > dmax) {
					cutIndex = i
					dmax = d
				}
			}
			
			//var maxDist:Number = p1.distanceToVector( p2 ) * ( (100 - epsilon) / 100 );
			var maxDist:Number = Math.pow(10,(100-epsilon)/10-8); //Normalize epsilon, so that it ranges from 0(no simplification) to 100 (max simplification)
			
 			if (dmax > maxDist) 
			{
				//Recursive call
				recResults1 = simplifyPath(points.slice(0,cutIndex),epsilon); //copy the simplified 1st part of polygon into a new array recResults1
				recResults2 = simplifyPath(points.slice(cutIndex,points.length-1),epsilon); //copy the simplified 2nd part of polygon into a new array recResults2 				

				// Build the result list
				return recResults1.concat(recResults2);
			} else {
				return points;
			}
		}
	}
}