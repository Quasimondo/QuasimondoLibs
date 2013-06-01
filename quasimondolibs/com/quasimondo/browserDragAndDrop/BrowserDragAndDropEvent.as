package com.quasimondo.browserDragAndDrop
{
	import flash.events.Event;

	public class BrowserDragAndDropEvent extends Event
	{
		
		public static const DRAG_ENTER:String = "dragEnter";
		public static const DRAG_LEAVE:String = "dragLeave";
		public static const DRAG_OVER:String = "dragOver";
		public static const DROP_DATA:String = "dropData";
		public static const DROP_FILE:String = "dropFile";
		
		public var data:*;
		public var x:Number;
		public var y:Number;
		
		public function BrowserDragAndDropEvent(type:String, data:*=null, x:Number = 0, y:Number = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
			this.x = x;
			this.y = y;
		}
		
		public override function clone():Event {
            return new BrowserDragAndDropEvent(type, data, x, y, bubbles, cancelable);
        }
		
	}
}