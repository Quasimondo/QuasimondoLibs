package com.quasimondo.geom
{
	public class MixedPathPoint extends Vector2
	{
		public var isControlPoint:Boolean = false;
		public var ID:String;
		
		public function MixedPathPoint( point:Vector2, ID:String, isControlPoint:Boolean = false )
		{
			super(point);
			this.ID = ID;
			this.isControlPoint = isControlPoint;
		}
		
		override public function toString():String
		{
			return x + "|" + y + ( isControlPoint ? "|c":"" );
		}
	}
}