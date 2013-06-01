package com.signalsondisplay.datastructs.linkedlists
{
	
	/**
	 * LinkedList iterator
	 * implements IIterator interface
	 * version: 0.5
	 */
	
	import com.signalsondisplay.datastructs.iterators.IIterator;
	
	public class ListIterator implements IIterator
	{
		
		private var _list:LinkedList;
		private var _head:ListNode;
		private var _current:ListNode;
		private var _key:uint;
		
		public function ListIterator( list:LinkedList )
		{
			_list = list;
			_head = _current = _list.head;
			_key = 0;
		}

		public function hasNext():Boolean
		{
			return _current != null;
		}
	
		/**
		 * returns the current node pointed to by the list iterator
		 * and moves to the next node
		 */
		public function next():*
		{
			//if ( hasNext() )
			//{
				var node:ListNode = _current;
				_current = _current.next;
				_key++;
				return node;
			//}
			return null;
		}
		
		/**
		 * return the current node pointed to by the iterator
		 */
		public function current():*
		{
			return _current;
		}
		
		public function reset():void
		{
			_current = _head = _list.head;
			_key = 0;
		}
		
		public function key():uint
		{
			return _key;
		}
		
	}
	
}