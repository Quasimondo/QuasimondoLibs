package com.signalsondisplay.datastructs.queues
{
	
	import __AS3__.vec.Vector;
	
	import com.signalsondisplay.datastructs.iterators.IIterator;	
	
	public class PQueueIterator implements IIterator
	{
		
		private var _heap:Vector.<Prioritizable>;
		private var _key:int;
		
		public function PQueueIterator( heap:Vector.<Prioritizable> )
		{
			_heap = heap;
			_key = 0;
		}
		
		public function hasNext():Boolean
		{
			return _key < _heap.length;
		}
		
		public function next():*
		{
			return _heap[ _key++ ];
		}
		
		public function current():*
		{
			return _heap[ _key ];
		}
		
		public function reset():void
		{
			_key = 0;
		}
		
		public function key():uint
		{
			return _key;
		}

	}
	
}