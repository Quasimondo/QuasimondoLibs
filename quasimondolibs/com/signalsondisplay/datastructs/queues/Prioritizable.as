package com.signalsondisplay.datastructs.queues
{
	
	public class Prioritizable
	{
		
		protected var _priority:int;
		
		public function Prioritizable() {}
		
		public function get priority():int
		{
			return _priority;
		}
		
		public function set priority( priority:int ):void
		{
			_priority = priority;
		}
		
	}
	
}