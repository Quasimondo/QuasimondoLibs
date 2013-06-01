package com.quasimondo.geom
{
	public interface IIntersectable
	{
		function intersect( shape:IIntersectable ):Intersection;
		function get type():String
	}
}