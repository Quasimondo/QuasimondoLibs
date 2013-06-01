package com.quasimondo.geom
{
	import flash.geom.Point;

	final public class LinkedPoint extends Point
	{
		private var __previous:LinkedPoint;
		private var __next:LinkedPoint;
		
		function LinkedPoint( pt:Point = null  )
		{
			if ( pt != null ) position = pt;
		}
		
		public function set position( pt:Point):void
		{
			x = pt.x;
			y = pt.y;
		}
		
		public function set next( lp:LinkedPoint ):void
		{
			__next = lp;
			if ( lp!=null) lp.previous = this;
		}
		
		public function get next():LinkedPoint
		{
			return __next;
		}
		
		public function set previous( lp:LinkedPoint ):void
		{
			__previous = lp;
		}
		
		public function get previous():LinkedPoint
		{
			return __previous;
		}
		
		public function insert( lp:LinkedPoint ):void
		{
			lp.next = __next;
			lp.previous = this;
			__next = lp;
		}
		
		public function remove():void
		{
			previous.next = __next;
			__next.previous = previous
		}
		
		public function toArray():Array
		{
			var points:Array = [];
			var current:LinkedPoint = this;
			while ( current != null )
			{
				points.push( current );
				current = current.next;
			}	
			return points;
		}
	}
}