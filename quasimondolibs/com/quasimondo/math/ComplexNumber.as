package com.quasimondo.math
{
	import com.quasimondo.utils.MathUtils;
	
	public class ComplexNumber
	{
		
		public var real:Number;
		public var imaginary:Number;
		
		public static function I():ComplexNumber
		{
			return new ComplexNumber(0,1);
		}
		
		public function ComplexNumber( r:Number = 0, i:Number = 0 )
		{
			/*
			if ( isNaN(r) || isNaN(i) )
			{
				throw( new Error("ComplexNumber isNaN"));
			}
			*/
			real = r;
			imaginary = i;
		}
		
		public function setFromValue ( a:ComplexNumber ):ComplexNumber
		{ 
			real = a.real;
			imaginary = a.imaginary;
			return this;
		}
		
		public function setValue (r:Number = 0, i:Number = 1):ComplexNumber
		{ 
			real = r;
			imaginary = i;
			return this;
		}
				
		public function add (a:ComplexNumber):ComplexNumber
		{                               
		  /* z=a+b */
		   real += a.real;
		   imaginary += a.imaginary;
		   return this;
		}
		
		public function get_add(a:ComplexNumber):ComplexNumber
		{                               
			/* z=a+b */
			return new ComplexNumber(real + a.real, imaginary + a.imaginary );
		}
		
		public function add_real( x:Number ):ComplexNumber
		{                               
			/* z=a+x */
		  	real += x;
			return this;
		}
		
		public function sub(a:ComplexNumber):ComplexNumber
		{                               
		  /* z=a+b */
		   real -= a.real;
		   imaginary -= a.imaginary;
		   return this;
		}
		
		public function get_sub(a:ComplexNumber):ComplexNumber
		{                               
			/* z=a+b */
			return new ComplexNumber( real - a.real, imaginary - a.imaginary );
		}
		
		public function mul(a:ComplexNumber):ComplexNumber
		{                               
			/* z=a*b */
		    var tmpReal:Number = real * a.real - imaginary * a.imaginary;
		    imaginary = real * a.imaginary + imaginary * a.real;
			real = tmpReal;
			return this;
		}
		
		public function get_mul(a:ComplexNumber):ComplexNumber
		{                               
			/* z=a*b */
			return new ComplexNumber(  real * a.real - imaginary * a.imaginary, real * a.imaginary + imaginary * a.real );
		}
		
		
		public function mul_real ( x:Number ):ComplexNumber
		{                               
			/* z=a/x */
		  	real *= x
		  	imaginary *= x;
			return this;
		}
		
		public function mul_imag ( y:Number):ComplexNumber
		{                               
			/* z=a*iy */
		   	var tmpReal:Number = -y * imaginary;
		   	imaginary = y * real;
		   	real = tmpReal;
			return this;
		}
		
		// Adapted from
		// "Numerical Recipes in Fortran 77: The Art of Scientific Computing"
		// (ISBN
		public function div( b:ComplexNumber):ComplexNumber
		{                               
			/* z=a/b */
			var zRe:Number, zIm:Number;
			var scalar:Number;
			
			if (Math.abs(b.real) >= Math.abs(b.imaginary)) 
			{
				if ( b.real != 0 )
				{
					scalar =  1.0 / ( b.real + b.imaginary*(b.imaginary/b.real) );
					
					zRe =  scalar * (real + imaginary*(b.imaginary/b.real));
					zIm =  scalar * (imaginary - real*(b.imaginary/b.real));
				} else {
					zRe = zIm = Infinity;
				}
			} else {
				if ( b.imaginary != 0 )
				{
					scalar =  1.0 / ( b.real*(b.real/b.imaginary) + b.imaginary );
					
					zRe =  scalar * (real*(b.real/b.imaginary) + imaginary);
					zIm =  scalar * (imaginary*(b.real/b.imaginary) - real);
				} else {
					zRe = zIm = Infinity;
				}
			}//endif
			
			real = zRe;
			imaginary = zIm;
			return this;
		}
		
		public function get_div( b:ComplexNumber):ComplexNumber
		{                               
			/* z=a/b */
			return clone().div( b );
		}
		
		public function div_real ( x:Number ):ComplexNumber
		{                               
			/* z=a/x */
		  	real /= x
		  	imaginary /= x;
			return this;
		}
		
		public function div_imag (y:Number):ComplexNumber
		{                               
			/* z=a/(iy) */
		  	
		  	var tmpReal:Number = imaginary / y; 
		  	imaginary = - real / y;
		  	real = tmpReal;
			return this;
		}
		
		public function negative():ComplexNumber
		{
			real = -real;	
			imaginary = -imaginary;
			return this;
		}
		
		public function log():ComplexNumber
		{
			/* set to Math.log z */
			var logr:Number = logabs();
		  	var theta:Number = arg();
		  	real = logr;
		  	imaginary = theta;
			return this;
		}
		
		public function exp():ComplexNumber
		{                              
			 /* z=exp(a) */
		  	var rho:Number = Math.exp (real);
		  	real = rho * Math.cos (imaginary);
		  	imaginary = rho * Math.sin (imaginary);
			return this;
		}
		
		
		public function sin():ComplexNumber
		{                               
			/* z = sin(a) */
		  if ( imaginary == 0.0) 
		  {
				real = Math.sin(real);  
		  } else 
		  {
		      var tmpReal:Number = Math.sin (real) * MathUtils.cosh (imaginary); 
		      imaginary = Math.cos (real) * MathUtils.sinh (imaginary);
		      real = tmpReal;
		  }
		  return this;
		}
		
		public function tan():ComplexNumber
		{                               
			/* z = tan(a) */
		  	
		  	var D:Number;
			
		  	if (Math.abs (imaginary) < 1)
		    {
		      	D = Math.pow ( Math.cos(real), 2.0) + Math.pow ( MathUtils.sinh(imaginary), 2.0);
				real = 0.5 * Math.sin(2 * real) / D; 
		      	imaginary = 0.5 * MathUtils.sinh(2 * imaginary) / D;
		    }
		  	else
		    {
			    var u:Number = Math.exp (-imaginary);
			    var C:Number = 2 * u / (1 - Math.pow (u, 2.0));
			    D = 1 + Math.pow(Math.cos(real), 2.0) * Math.pow(C, 2.0);
			
			    var S:Number = Math.pow(C, 2.0);
			    var T:Number = 1.0 / MathUtils.tanh(imaginary);
			
			    real = 0.5 * Math.sin (2 * real) * S / D; 
			    imaginary = T / D;
		    }
			return this;
		}
		
		public function pow_real ( b:Number ):ComplexNumber
		{                               
			/* z=a^b */
		  	
		  	if ( real != 0 || imaginary != 0)
		    {
		 		var rho:Number = Math.exp (logabs() * b);
		      	var beta:Number = arg() * b;
		      	real = rho * Math.cos (beta); 
		      	imaginary = rho * Math.sin (beta);
		    }
			return this;
		}
		
		public function logabs():Number
		{                               
		 	/* set to Math.log|z| */
		  	var xabs:Number = Math.abs(real);
		  	var yabs:Number = Math.abs(imaginary);
		  	var max:Number
		  	var u:Number;
		
		  	if (xabs >= yabs)
		   	{
		      	max = xabs;
		      	u = yabs / xabs;
		  	} else
		   	{
		      	max = yabs;
		      	u = xabs / yabs;
		   	}
		
		  	/* Handle underflow when u is close to 0 */
			return Math.log(max) + 0.5 * MathUtils.log1p(u * u);
		}
		
		public function arg ():Number
		{                              
			 /* set arg(z),  -pi < arg(z) <= +pi */
		  	if (real == 0.0 && imaginary == 0.0)
		  	{
		     	return 0;
		  	}
			return Math.atan2 ( imaginary, real );
		}
		
		public function abs():Number
		{                               
		  /* return |z| */
		  return MathUtils.hypot(real, imaginary);
		}
		
		public function sqrt ():ComplexNumber
		{                               
			var mag:Number = abs();
			var temp:Number;
			if (mag > 0.0) {
				if (real > 0.0) {
					temp =  Math.sqrt(0.5 * (mag + real));
					
					real =  temp;
					imaginary =  0.5 * imaginary / temp;
				} else {
				 temp =  Math.sqrt(0.5 * (mag - real));
					
					if (imaginary < 0.0) {
						temp =  -temp;
					}
					
					real =  0.5 * imaginary / temp;
					imaginary =  temp;
				}
			} else {
				real =  0.0;
				imaginary =  0.0;
			}
			return this;
		}
		
		public function get_sqrt( ):ComplexNumber
		{                               
			return clone().sqrt();
		}
		
		public function clone():ComplexNumber
		{ 
			return new ComplexNumber( real, imaginary );
		}
		
		public function toString():String
		{ 
			return "ComplexNumber("+real+","+ imaginary+" )";
		}
	}
}