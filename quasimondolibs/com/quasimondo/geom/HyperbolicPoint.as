package com.quasimondo.geom
{
	public class HyperbolicPoint
	{
		
  		public var x:Number;
  		public var y:Number;

  
		public function HyperbolicPoint( x:Number = 0, y:Number = 0) 
		{
			this.x = x;
			this.y = y;
		}
		  
		  public function toString():String
		  {
		    return x+"+"+y+"i";
		  }

  
		  // find the inner product when the numbers are treated as vectors
		  public function innerProduct ( w:HyperbolicPoint ):Number
		   {
		    return x*w.x + y*w.y;
		  }
  
		  public static function innerProduct ( z:HyperbolicPoint, w:HyperbolicPoint ):Number
		  {
		    return z.x*w.x + z.y*w.y;
		  }

		  public function normSquared():Number
		  {
		    return x*x + y*y;
		  }

		  public function norm():Number 
		  {
		    return Math.sqrt(x*x + y*y); 
		  }
  
		  public function conjugate():HyperbolicPoint 
		  {
		    return new HyperbolicPoint(x, -y);
		  }

		  public function negation ():HyperbolicPoint 
		  {
		    return new HyperbolicPoint (- x, y); 
		  }
		  
		  public function minus ( value:* ):HyperbolicPoint 
		  {
		    if ( value is HyperbolicPoint )
		    {
		    	var w:HyperbolicPoint = HyperbolicPoint( value );
		    	return new HyperbolicPoint (x - w.x, y - w.y); 
		    } 
		  	return new HyperbolicPoint (x - Number( value ), y);
		  }
  
		  public static function subtract ( value1:*, value2:* ):HyperbolicPoint 
		  {
		  	if ( value1 is HyperbolicPoint )
		  	{
		  		if ( value2 is HyperbolicPoint )
		  		{
		  			 return new HyperbolicPoint (HyperbolicPoint(value1).x - HyperbolicPoint(value2).x, HyperbolicPoint(value1).y - HyperbolicPoint(value2).y);
		  		} else {
		  			return new HyperbolicPoint (HyperbolicPoint(value1).x - Number( value2 ), HyperbolicPoint(value1).y);
		  		}
		  	} 
		  	
		  	return new HyperbolicPoint (Number( value1) - HyperbolicPoint(value2).x, - HyperbolicPoint(value2).y);
		  	
		  }
		  
		  public function plus( value:* ):HyperbolicPoint 
		  {
		    if ( value is HyperbolicPoint )
		    {
		    	var w:HyperbolicPoint = HyperbolicPoint( value );
		    	return new HyperbolicPoint (x + w.x, y + w.y); 
		    } 
		  	return new HyperbolicPoint (x + Number( value ), y);
		  }
		  
		  
		  public static function add ( value1:*, value2:* ):HyperbolicPoint 
		  {
		  	if ( value1 is HyperbolicPoint )
		  	{
		  		if ( value2 is HyperbolicPoint )
		  		{
		  			 return new HyperbolicPoint (HyperbolicPoint(value1).x + HyperbolicPoint(value2).x, HyperbolicPoint(value1).y + HyperbolicPoint(value2).y);
		  		} else {
		  			return new HyperbolicPoint (HyperbolicPoint(value1).x + Number( value2 ), HyperbolicPoint(value1).y);
		  		}
		  	} 
		  	
		  	return new HyperbolicPoint (Number( value1) + HyperbolicPoint(value2).x, + HyperbolicPoint(value2).y);
		  	
		  }

		  
		  public function  times ( value:* ):HyperbolicPoint 
		  {
		  	if ( value is HyperbolicPoint ) return new HyperbolicPoint (x*HyperbolicPoint(value).x - y*HyperbolicPoint(value).y, y*HyperbolicPoint(value).x + x*HyperbolicPoint(value).y); 
		  	 return new HyperbolicPoint (Number(value)*x, Number(value)*y); 
		  }
  
  		  public static function multiply( value1:*, value2:* ):HyperbolicPoint 
		  {
		  	if ( value1 is HyperbolicPoint )
		  	{
		  		if ( value2 is HyperbolicPoint )
		  		{
		  			return new HyperbolicPoint (HyperbolicPoint(value1).x*HyperbolicPoint(value2).x - HyperbolicPoint(value1).y*HyperbolicPoint(value2).y, HyperbolicPoint(value1).y*HyperbolicPoint(value2).x + HyperbolicPoint(value1).x*HyperbolicPoint(value2).y);
		  		} else {
		  			return new HyperbolicPoint (Number( value2 )*HyperbolicPoint(value1).x, Number( value2 )*HyperbolicPoint(value1).y);
		  		}
		  	} 
		  	return new HyperbolicPoint (Number( value1 )*HyperbolicPoint(value2).x, Number( value1 )*HyperbolicPoint(value2).y);
		  }


		  public function reciprocal():HyperbolicPoint 
		  {
		    var den:Number = normSquared();
		    return new HyperbolicPoint (x/den, - y/den);
		  }
		   
		  public function over ( value:* ):HyperbolicPoint 
		  {
		  	if ( value is HyperbolicPoint )
		  	{
		    	var den:Number = HyperbolicPoint(value).normSquared();
		    	return new HyperbolicPoint ((x*HyperbolicPoint(value).x + y*HyperbolicPoint(value).y)/den, (y*HyperbolicPoint(value).x - x*HyperbolicPoint(value).y)/den);
		  	}
		  	return new HyperbolicPoint (x/Number(value), y/Number(value)); 
		  }
  			
  		  public static function divide( value1:*, value2:* ):HyperbolicPoint 
		  {
		  	var den:Number;
		  	if ( value1 is HyperbolicPoint )
		  	{
		  		if ( value2 is HyperbolicPoint )
		  		{
		  			den = HyperbolicPoint(value1).normSquared();
		  			return new HyperbolicPoint ( (HyperbolicPoint(value1).x*HyperbolicPoint(value2).x + HyperbolicPoint(value1).y*HyperbolicPoint(value2).y) / den, (HyperbolicPoint(value1).y*HyperbolicPoint(value2).x - HyperbolicPoint(value1).x*HyperbolicPoint(value2).y) / den);
		  		} else {
		  			return new HyperbolicPoint ( HyperbolicPoint(value1).x / Number( value2 ), HyperbolicPoint(value1).y / Number( value2 ));
		  		}
		  	} 
		  	den = HyperbolicPoint(value2).normSquared();
		  	return new HyperbolicPoint (Number( value1 )*HyperbolicPoint(value2).x / den, Number( value1 )*HyperbolicPoint(value2).y / den);
		  }
		  
		  /* Reflect the point A through this point B to get the returned point C.
		  * The rule for computing A thru B (as complex numbers) is:		|
		  *
		  *            B - t A	         where t = (1+BB')/2, and
		  * A |> B = -----------               B' is the complex
		  *           t -  A B'                conjugate of B
		  */
		  public function reflect ( A:HyperbolicPoint ):HyperbolicPoint
		  {
		    var t:Number = (1.0 + normSquared()) / 2.0;
		    // compute the numerator as  B - t * A
		    var numerator:HyperbolicPoint = minus(A.times(t));
		    // compute the denominator as  t - A * B'
		    var denominator:HyperbolicPoint = HyperbolicPoint.subtract(t, A.times(this.conjugate())) ;
		    return numerator.over(denominator) ;
		  }
	
		public function toVector2():Vector2
		{
			return new Vector2( x, y );
		}

	}
}