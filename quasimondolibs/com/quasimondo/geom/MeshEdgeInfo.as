package com.quasimondo.geom
{
	final public class MeshEdgeInfo
	{
		public var id:String;
		public var line:LineSegment;
		public var connectionCount:Vector.<int>;
		public var vertexIndices:Vector.<int>;
		
		public function MeshEdgeInfo( id:String, vertexIndex1:int, vertexIndex2:int, line:LineSegment = null, connectionCount1:int = -1, connectionCount2:int = -1 )
		{
			this.id = id;
			this.line = line;
			vertexIndices = Vector.<int>([vertexIndex1,vertexIndex2]);
			connectionCount = Vector.<int>([connectionCount1,connectionCount2]);
		}
	}
}