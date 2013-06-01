package com.signalsondisplay.datastructs.linkedlists
{
	
	/**
	 * Linked list node
	 * acts as a basic wrapper to the data
	 * stored in the list
	 * version: 0.3.2
	 */
	
	public class ListNode
	{
		
		public var data:*;
		public var name:String = "";
		public var next:ListNode = null;
		
		public function ListNode( data:*, name:String = "" ) 
		{
			this.data = data;
			next = null;
			if ( name ) this.name = name;
		}
		
		public function insertAfter( list:LinkedList, data:*, name:String = "" ):void
		{
			var node:ListNode = new ListNode( data, name );
			node.next = this.next;
			this.next = node;
			list.size++;
		}
		
		public function removeNext( list:LinkedList ):ListNode
		{
			var node:ListNode = this.next;
			this.next = this.next.next;
			list.size--;
			return node;
		}
		
		public function toString():String
		{
			return "[ListNode name:" + data + "]";
		}
		
	}
	
}