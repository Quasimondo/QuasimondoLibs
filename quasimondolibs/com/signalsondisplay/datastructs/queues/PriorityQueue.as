package com.signalsondisplay.datastructs.queues
{
	
	/**
	 * PriorityQueue class
	 * version: 0.1.2
	 * to-do:
	 * 	- improve performance!!!
	 * 	- implement Dictionary ?
	 */
	
	import __AS3__.vec.Vector;
	
	import com.signalsondisplay.datastructs.iterators.IIterableAggregate;
	import com.signalsondisplay.datastructs.iterators.IIterator;
	
	public class PriorityQueue implements IIterableAggregate
	{

		private var _heap:Vector.<Prioritizable>;
		private var _size:uint;
		
		public function PriorityQueue()
		{
			_heap = new Vector.<Prioritizable>();
			_size = 0;
		}
		
		public function extractMin():Prioritizable
		{
			if ( _size )
			{
				var obj:Prioritizable = _heap[ 0 ];
				var min:int = obj.priority;
				var index:int;
				for ( var i:uint = 0; i < _size; i++ )
				{
					if ( _heap[ i ].priority < min )
					{
						obj = _heap[ i ];
						min = obj.priority;
						index = i;
					}
				}
				_heap.splice( index, 1 );
				_size--; 
				return obj;
			}
			return null;
		}
		
		public function enqueue( obj:Prioritizable ):void
		{
			_heap.push( obj );
			_size++;	
		}
		
		public function isEmpty():Boolean
		{
			return _size == 0;
		}
		
		public function createIterator():IIterator
		{
			return new PQueueIterator( _heap );
		}
		
		public function get size():uint
		{
			return _size;
		}

	}
	
}