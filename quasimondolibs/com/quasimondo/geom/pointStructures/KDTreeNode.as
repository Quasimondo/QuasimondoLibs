package com.quasimondo.geom.pointStructures
{
	import com.quasimondo.geom.Vector2;

	final public class KDTreeNode
	{
		public var left:KDTreeNode;
		public var right:KDTreeNode;
		public var depth:int;
		public var point:Vector2;
		public var dist:Number;
		public var parent:KDTreeNode;
		public var count:uint = 1;
				
		public function KDTreeNode()
		{}
	}
}