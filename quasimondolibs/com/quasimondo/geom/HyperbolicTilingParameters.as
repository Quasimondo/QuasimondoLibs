package com.quasimondo.geom
{
	public class HyperbolicTilingParameters
	{
			
		public var n:int = 5; // the number of sides on a polygon
		public var k:int = 4; // vertex valence, the number of polygons that meet at each vertex
		public var angle:Number = 0;
		public var quasiregular:Boolean;
		public var layers:int = 2; // the number of layers of polygons to display
		public var skipNumber:int = 1;
		
		public var bgColor:int = 0x000000;
		public var diskColor:int = 0xffffff;
		public var strokeColor:int = 0x000000;
		
		public var fill:Boolean = true;
		public var outline:Boolean = false;
		public var grayScale:Boolean = true;
		public var alternating:Boolean = false; // alternating colors
		
		public function HyperbolicTilingParameters()
		{
		}


	

		  public function checkPars():void 
		  {
		    // n should be between 3 and 20
		    n = Math.min(Math.max(n,3),20);
		    
		    // k should be large enough, but no larger than 20
		    if (n==3)       k = Math.max(k,7);
		    else if (n==4)  k = Math.max(k,5);
		    else if (n<7)   k = Math.max(k,4);
		    else            k = Math.max(k,3);
		    k = Math.min(k,20);
		    
		    // skipNumber should be between 1 and n/2
		    if (skipNumber*2 >= n)
		      skipNumber = 1;
		    
		    // layers shouldn't be too big
		    if (n==3 || k==3)
		      layers = Math.min(layers,5);
		    else
		      layers = Math.min(layers,4);
		  }  // checkPars

		  public function toString():String 
		  {
		    return "[n="+n+ ",k="+k+ ",layers="+layers
		           +",quasiregular="+quasiregular
		           +",alternating="+alternating+"]";
		  }
	}
}