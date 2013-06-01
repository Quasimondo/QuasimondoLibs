package com.quasimondo.geom
{
	public interface IPolygonHelpers
	{
		function detangle():void;
		function addPointAtClosestSide( p:Vector2 ):void;
		function fractalize( factor:Number = 0.5, range:Number = 0.5, minSegmentLength:Number = 2, iterations:int = 1 ):void;
		//function simplify():void
	}
}