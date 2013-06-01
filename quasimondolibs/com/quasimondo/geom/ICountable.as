package com.quasimondo.geom
{
	public interface ICountable
	{
		function get pointCount():int;
		function getPointAt( index:int ):Vector2;
	}
}