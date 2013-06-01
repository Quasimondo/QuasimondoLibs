package com.signalsondisplay.datastructs.queues
{
	
	/**
	 * Priority Queue Node class
	 * version: 0.1
	 */
	
	public class PriorityQueueNode extends Prioritizable
	{
		
		private var _name:String;
		
		public function PriorityQueueNode( priority:int = 0, name:String = "" )
		{
			_priority = priority;
			_name = name;
		}

		public function get name():String
		{
			return _name;
		}
		
	}
	
}