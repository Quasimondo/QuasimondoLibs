package com.signalsondisplay.datastructs.linkedlists
{
	
	/**
	 * LinkedList class
	 * version: 0.5
	 * to-do:
	 * 	implement iterators
	 * 	- + list sorting:
	 * 		- insertion sort
	 */
	
	import com.signalsondisplay.datastructs.iterators.IIterableAggregate;
	import com.signalsondisplay.datastructs.iterators.IIterator;
	
	public class LinkedList implements IIterableAggregate
	{
		
		public var size:uint;
		
		private var _head:ListNode;
		private var _tail:ListNode;
		private var _iterator:ListIterator;
		private var _isCircular:Boolean;
		
		public function LinkedList( isCircular:Boolean = false )
		{
			_head =_tail = null;
			_isCircular = isCircular;
			size = 0;
		}
		
		/**
		 * pushes the node to the front of the list
		 */
		public function push( data:*, name:String = "" ):ListNode
		{			
			var node:ListNode = new ListNode( data, name );
						
			if ( !_head )
				_head = _tail = node;
			else
			{
				node.next = _head;
				_head = node;
				if ( _isCircular )
					_tail.next = _head;
			}
			size++;
			return node;
		}
		
		/**
		 * adds the node to the end of the list
		 */
		public function append( data:*, name:String = "" ):ListNode
		{
			var node:ListNode = new ListNode( data, name );
			var ref:ListNode;
			
			ref = _head;
			if ( !_head )
				_head = _tail = node;
			else
			{
				_tail.next = node;
				_tail = node;
				if ( _isCircular )
					_tail.next = _head;	
			}
			size++;
			return node;
		}
		
		/**
		 * adds node after the current node in the iterator
		 */
		public function insertNode( iterator:IIterator, data:* ):ListNode
		{
			var node:ListNode = new ListNode( data );
			var current:ListNode = iterator.current() as ListNode;
			node.next = current.next;			
			current.next = node;
			size++;
			return node;
		}
		
		/**
		 * inserts a node at the given index
		 * If index is occupied by a node, that node is
		 * moved up to the next index.
		 */
		public function instertNodeAtIndex( index:uint, data:*, name:String = "" ):ListNode
		{
			var node:ListNode = new ListNode( data, name );
			var iterator:ListNode = _head;
			var counter:uint = 0;
			
			if ( !index )
			{
				node.next = _head;
				size++;
				return _head = node;	
			}
			else
			{
				while ( iterator )
				{
					if ( counter == index - 1 )
					{
						node.next = iterator.next;
						iterator.next = node;
						size++;
						return node;
					}
					counter++;
					iterator = iterator.next;
				}
			}
			return null;
		}
		
		/**
		 * removes and returns the head of the list
		 */
		public function shift():ListNode
		{
			_head = _head.next;
			size--;
			return _head;
		}
		
		/**
		 * removes and returns the last node of the list
		 */
		public function pop():ListNode
		{
			var iterator:ListNode = _head;

			while ( iterator )
			{
				if ( iterator.next == _tail )
				{
					_tail = iterator;
					_tail.next = _head;
					size--;
					return _tail;
				}
				iterator = iterator.next;
			}
			return null;
		}
		
		/**
		 * removes the node currently held in the iterator
		 */
		public function removeNode( iterator:IIterator ):ListNode
		{
			var node:ListNode = iterator.current() as ListNode;
			var itr:ListNode = _head;
			
			if ( node == _head )
				_head = _head.next;
			else
			{
				while ( itr )
				{
					if ( itr.next == node )
					{
						itr.next = node.next;
						node.next = null;
						size--;
						return node;
					}
				}
			}
			size--;
			return node;
		}
		
		/**
		 * removes node at given index
		 */
		public function removeNodeAtIndex( index:uint ):void
		{
			var counter:int = 0;
			var iterator:ListNode = _head;
			
			if ( index > size - 1) return;
			if ( index == 0 )
				_head = _head.next;
			else
			{
				for ( ; iterator; counter++ )
				{
					if ( counter == index - 1 )
					{
						iterator.next = iterator.next.next;
						break;
					}
					iterator = iterator.next;
				}
			}
			size--;
		}

		/**
		 * returns the node at given index
		 */
		public function getNodeAtIndex( index:uint ):ListNode
		{
			var iterator:ListNode = _head;
			var counter:uint = 0;
			
			while ( iterator )
			{
				if ( counter == index )
					return iterator;
				counter++;
				iterator = iterator.next;	
			}
			return null;
		}
		
		public function reverse():void
		{
			var current:ListNode;
			var prev:ListNode;
			
			prev = null;
			for ( ; _head; )
			{
				current = _head.next;
				_head.next = prev;
				prev = _head;
				_head = current;	
			}
			_head = prev;
		}
		
		public function createIterator():IIterator
		{
			return new ListIterator( this );
		}

		public function forEach( callback:Function ):void
		{
			var iterator:ListNode = _head;
			
			while ( iterator )
			{
				callback( iterator );
				iterator = iterator.next;
			}
		}
		
		public function isEmpty():Boolean
		{
			return size == 0;
		}
		
		/**
		 * getters / setters
		 */
		public function get head():ListNode
		{
			return _head;
		}
		
		public function set head( head:ListNode ):void
		{
			_head = head;
		}
		
		public function get tail():ListNode
		{
			return _tail;
		}
		
	}
	
}