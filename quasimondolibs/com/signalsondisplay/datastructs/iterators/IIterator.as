package com.signalsondisplay.datastructs.iterators
{
	
	/**
	 * Iterator interface for use with the LinkedList
	 * version: 0.1
	 */
	
	public interface IIterator
	{
		function current():*;
		function next():*;
		function hasNext():Boolean;
		function reset():void;
		function key():uint;
	}
	
}