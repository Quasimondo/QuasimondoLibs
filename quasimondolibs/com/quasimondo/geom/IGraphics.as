package com.quasimondo.geom
{
	public interface IGraphics
	{
		function moveTo( x:Number, y:Number ):void;
		
		function lineTo( x:Number, y:Number ):void;
		
		function curveTo( cx:Number, cy:Number, x:Number, y:Number ):void;
		
		function drawCircle( x:Number, y:Number, r:Number ):void;
		
		function drawRect( x:Number, y:Number, width:Number, height:Number ):void;
		
		function lineStyle( strokeWidth:Number = 0, color:uint = 0, alpha:Number = 1 ):void;
		
		function clear():void;	
	}
}