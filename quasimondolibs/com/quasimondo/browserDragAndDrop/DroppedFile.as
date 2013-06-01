package com.quasimondo.browserDragAndDrop
{
	public class DroppedFile
	{
		
		public var type:String;
		public var content:*;
		
		public function DroppedFile(type:String, content:*)
		{
			this.type = type;
			this.content = content;
		}

	}
}