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

package com.quasimondo.geom
{
	
	
	/** This class applies the Visvalingam-Whyatt simplification algorithm to the polygons of a country. 
	 */
	public class WhyattSimplification extends Simplification
	{
		private var _smallestObj:PolyPoint;
		private var _biggestObj:PolyPoint;
		private var _firstObj:PolyPoint;
		private var _lastObj:PolyPoint;
		
		override public function simplifyPolygon( polygon:Polygon, epsilon:Number, clonePoints:Boolean = true):Polygon
		{
			var originalArea:Number = polygon.area;
			var points:Vector.<Vector2> = polygon.getCopyOfPoints();
			
			var result:Vector.<Vector2> = simplifyPath( points, epsilon )
			var bestDiff:Number = Math.abs(originalArea - getArea( result ));
			var bestResult:Vector.<Vector2> = result;
			
			for ( var i:int = i; i < points.length; i++ )
			{
				points.unshift( points.pop() );
				result= simplifyPath( points, epsilon )
				var diff:Number = Math.abs( originalArea - getArea( result ) );
				if ( diff < bestDiff )
				{
					bestDiff = diff;
					bestResult = result;
				}
			}
			
			return Polygon.fromVector( bestResult, clonePoints );
			
		}
		
		public override function simplifyPath( polygon:Vector.<Vector2>, epsilon:Number):Vector.<Vector2>
		{
			var prevObj:PolyPoint;
			var currObj:PolyPoint;
			var nextObj:PolyPoint;
			var minSize:Number;
									
			//Create linked lists of Objects, which specify the effective area size for each polygon corner.
			//The Objects are linked four ways:
			//  Links (1)next and (2)previous follow the order of the points in the polygon, a.k.a. the polygon list
			//  Links (3)bigger and (4)smaller sort the points by effective area size, a.k.a. the area size list
			prevObj = new PolyPoint( 0, polygon[0] );
			currObj = new PolyPoint( 1, polygon[1], prevObj );
			prevObj.next = currObj;
			_firstObj = prevObj;
			_smallestObj = _biggestObj = currObj;
			for (var i:int = 1; i < polygon.length-1; i++) { 
 				nextObj = new PolyPoint( i+1, polygon[i+1], currObj );
				currObj.next = nextObj;
				currObj.size = triangleArea(currObj);
				
				if (i > 1) {
					insertIntoSizeList(currObj, _smallestObj) //Make sure currObj gets sorted according to area size
				}
				
				prevObj = currObj;
 				currObj = nextObj;
			}
			_lastObj=currObj;
			// The polygon list now contains all Objects
			// The area size list now contains all Objects except the first and last points of the polygon

			//Repeat removing the smallest point and recalculating the area of its neighbours
			currObj = _smallestObj;
			while (notBiggestInList(currObj)) //Step through the area size list
			{
				prevObj = currObj.prev;
				nextObj = currObj.next;

				//currObj is done. Remove it from the polygon list
				prevObj.next = nextObj;
				nextObj.prev = prevObj;
				
				//Recalculate the sizes of both neighbours and update the area size list accordingly
				recalcSize(prevObj, polygon.length-1,currObj); //prevObj will end up somewhere after currObj in the area size list
				recalcSize(nextObj, polygon.length-1,currObj); //nextObj will end up somewhere after currObj in the area size list
				
				currObj = currObj.bigger;
			}

			minSize = adjustParameter(epsilon,_biggestObj.size);
			
			//Now select the points with size bigger than minSize
			return selection(minSize,polygon.length);
		}

		public static function adjustParameter(epsilon:Number,polygonSize:Number):Number 
		{
			//Adjust epsilon depending on how big weights there are in the polygon, i.e. depending on _biggestObj.size
			return Math.pow((epsilon/100),40) * Math.pow(polygonSize,0.2)*5;			
		}

		private function recalcSize(obj:PolyPoint, lastIndex:int, refObj:PolyPoint):void 
		{
			if (obj.index > 0 && obj.index < lastIndex) //First or last point have no size
			{
				obj.size = triangleArea(obj);
				if (obj.size < refObj.size) {
					obj.size = refObj.size; //Ensure obj is worth at least as much as refObj
				}
				//obj's size has changed. Remove and reinsert it into the area size list
				if (notSmallestInList(obj)) {
					obj.smaller.bigger = obj.bigger;
				}
				if (notBiggestInList(obj)) {
					obj.bigger.smaller = obj.smaller;
				}
				insertIntoSizeList(obj, refObj);
			}
		}

		//Enter currObj at its appropriate place in the area size linked list
		private function insertIntoSizeList(currObj:PolyPoint, refObj:PolyPoint):void {
			var reachedEnd:Boolean = false;
			while ((refObj.size <= currObj.size) && !reachedEnd) //Step upward in the list until reaching the correct place
			{
				if (notBiggestInList(refObj)) {
					refObj = refObj.bigger;
				} else {
					reachedEnd = true;
				}
			}
			
			if (reachedEnd) {
				//Append currObj after refObj, at the end of the list
				currObj.smaller = refObj;
				currObj.bigger = null;
				currObj.smaller.bigger = currObj;
				_biggestObj = currObj; //currObj was bigger than the biggest
			} else {
				//Insert currObj just before refObj
				if (notSmallestInList(refObj)) {
					currObj.smaller = refObj.smaller;
					currObj.bigger = refObj;
					currObj.smaller.bigger = currObj;
					currObj.bigger.smaller = currObj;
				} else {
					currObj.smaller = null;
					currObj.bigger = refObj;
					currObj.bigger.smaller = currObj;
					_smallestObj = currObj; //currObj was smaller than the smallest
				}
			}
		}

		//Select the polygon corners with area size bigger than minSize
		private function selection(minSize:Number,origLength:int):Vector.<Vector2> 
		{
			var obj:PolyPoint = _biggestObj;
			var output:Vector.<Vector2> = new Vector.<Vector2> (origLength, true );
			output[0]= _firstObj.point;			//The first point has no size, so it's not in the area size list
			output[origLength-1] = _lastObj.point;	//The last point has no size, so it's not in the area size list
			
			while ( !isNaN(obj.size) && obj.size >= minSize) 
			{
				output[obj.index] = obj.point;
				if (notSmallestInList(obj)) {
					obj=obj.smaller;
				} else {
					break;
				}
			}
			return output.filter(callback);
		}

        private function callback( item:Vector2, index:int, v:Vector.<Vector2> ):Boolean 
		{
        	var hasItem:Boolean = (item != null);
            return hasItem;
        }
		
		//Calculate the area of the triangle formed by three points
		private function triangleArea(currObj:PolyPoint):Number 
		{
			return currObj.point.getArea( currObj.prev.point, currObj.next.point );
		}

		private function notSmallestInList(obj:PolyPoint):Boolean {
			return ( obj.smaller!=null)
		}
		
		private function notBiggestInList(obj:PolyPoint):Boolean {
			return (obj.bigger!=null)
		}
		
		private function getArea( points:Vector.<Vector2>):Number
		{
			
			var sx:Number = 0;
			var sy:Number = 0;
			var a:Number = 0;
			
			var p1:Vector2;
			var p2:Vector2;
			
			for ( var i:int = 0; i< points.length; i++ )
			{
				p1 = points[i];
				p2 = points[int((i+1) % points.length)];
				a +=  p1.x * p2.y - p2.x * p1.y;
				
			} 
			
			return a * 0.5;
		}
		
	}
}


final internal class PolyPoint
{
	public var index:int;
	public var point:com.quasimondo.geom.Vector2;
	public var prev:PolyPoint;
	public var size:Number;
	public var next:PolyPoint;
	public var smaller:PolyPoint;
	public var bigger:PolyPoint;
	
	function PolyPoint( index:int, point:com.quasimondo.geom.Vector2, prev:PolyPoint = null )
	{
		this.index = index;
		this.point = point;
		this.prev = prev;
	}
	
}