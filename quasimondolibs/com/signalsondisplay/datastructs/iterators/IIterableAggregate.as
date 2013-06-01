package com.signalsondisplay.datastructs.iterators
{
	
	public interface IIterableAggregate
	{
		function createIterator():IIterator;
		function isEmpty():Boolean;	
	}
	
}