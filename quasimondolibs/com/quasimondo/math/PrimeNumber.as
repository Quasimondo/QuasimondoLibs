package com.quasimondo.math
{
	public class PrimeNumber
	{
		public var p:PrimeNumber;
		public var n:Number;
		
		public function PrimeNumber( n:Number )
		{
			this.n = n;
		}
		
		public function setNext( n:Number ):PrimeNumber
		{
			return p = new PrimeNumber( n );
		}

	}
}