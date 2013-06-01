package com.quasimondo.math
{
	import com.quasimondo.utils.MathUtils;
	
	public class ComplexNumberMath
	{
		public function ComplexNumberMath()
		{
		}
		
		public static function cplx_rect ( x:Number, y:Number):ComplexNumber
		{                               
		  /* return z = x + i y */
		  return new ComplexNumber( x, y );
		}
	
		public static function cplx_polar ( r:Number, theta:Number ):ComplexNumber
		{                              
			 /* return z = r exp(i theta) */
  			return new ComplexNumber( r * Math.cos (theta), r * Math.sin (theta));
  		}
  		
  		public static function cplx_arg ( z:ComplexNumber ):Number
		{                              
			 /* return arg(z),  -pi < arg(z) <= +pi */
		  	if (z.real == 0.0 && z.imaginary == 0.0)
		  	{
		     	return 0;
		  	}
		
		  	return Math.atan2 (z.imaginary, z.real);
		}
		
		public static function cplx_abs ( z:ComplexNumber ):Number
		{                               
		  /* return |z| */
		  return  MathUtils.hypot ( z.real, z.imaginary);
		}
		
		public static function cplx_abs2 ( z:ComplexNumber ):Number
		{                               
		  /* return |z|^2 */
		  var x:Number = z.real;
		  var y:Number = z.imaginary;
		
		  return (x * x + y * y);
		}
  		
  		public static function  cplx_logabs ( z:ComplexNumber ):Number
		{                               
		 /* return Math.log|z| */
		  var xabs:Number = Math.abs (z.real);
		  var yabs:Number = Math.abs (z.imaginary);
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
	
		  return Math.log (max) + 0.5 *  MathUtils.log1p(u * u);
		}
		
		
		
		/***********************************************************************
		 * Complex arithmetic operators
		 ***********************************************************************/

		public static function cplx_add (a:ComplexNumber, b:ComplexNumber):ComplexNumber
		{                               
		  /* z=a+b */
		   return new ComplexNumber( a.real + b.real, a.imaginary + b.imaginary );
		 }

 		public static function cplx_add_real (a:ComplexNumber, x:Number):ComplexNumber
		{                               
			/* z=a+x */
		    return new ComplexNumber( a.real + x, a.imaginary);
		}

		public static function cplx_add_imag (a:ComplexNumber, y:Number):ComplexNumber
		{                               
		  	/* z=a+iy */
		  	return new ComplexNumber( a.real, a.imaginary + y);
		}


		public static function cplx_sub (a:ComplexNumber, b:ComplexNumber):ComplexNumber
		{                               
			/* z=a-b */
		  	return new ComplexNumber( a.real - b.real, a.imaginary - b.imaginary );
		}

		public static function cplx_sub_real (a:ComplexNumber, x:Number):ComplexNumber
		{                               
			/* z=a-x */
		 	return new ComplexNumber( a.real - x, a.imaginary);
		}

		public static function cplx_sub_imag (a:ComplexNumber, y:Number):ComplexNumber
		{                               
			/* z=a-iy */
		  	return new ComplexNumber( a.real, a.imaginary - y);
		}

		public static function cplx_mul (a:ComplexNumber, b:ComplexNumber):ComplexNumber
		{                               
			/* z=a*b */
		    return new ComplexNumber( a.real * b.real - a.imaginary * b.imaginary, a.real * b.imaginary + a.imaginary * b.real);
		}

		public static function cplx_mul_real (a:ComplexNumber, x:Number):ComplexNumber
		{                               
			/* z=a*x */
		  	return new ComplexNumber( x * a.real, x * a.imaginary);
		}

		public static function cplx_mul_imag (a:ComplexNumber, y:Number):ComplexNumber
		{                               
			/* z=a*iy */
		   	return new ComplexNumber( -y * a.imaginary, y * a.real);
		}

 		public static function cplx_div (a:ComplexNumber, b:ComplexNumber):ComplexNumber
		{                               
			/* z=a/b */
			var s:Number = 1.0 / cplx_abs(b);

			var sbr:Number = s * b.real;
			var sbi:Number = s * b.imaginary;
			
			var zr:Number = (a.real * sbr + a.imaginary * sbi) * s;
			var zi:Number = (a.imaginary * sbr - a.real * sbi) * s;
			
			return new ComplexNumber( zr, zi);
		}

		public static function cplx_div_real (a:ComplexNumber, x:Number):ComplexNumber
		{                               
			/* z=a/x */
		  	return new ComplexNumber( a.real / x, a.imaginary / x);
		}

		public static function cplx_div_imag (a:ComplexNumber, y:Number):ComplexNumber
		{                               
			/* z=a/(iy) */
		  	return new ComplexNumber( a.imaginary / y,  - a.real / y);
		}

		public static function cplx_conjugate ( a:ComplexNumber ):ComplexNumber
		{                               
			/* z=conj(a) */
		  	return new ComplexNumber( a.real, -a.imaginary);
		}

		public static function cplx_negative (a:ComplexNumber):ComplexNumber
		{                               
			/* z=-a */
		  	return new ComplexNumber( -a.real, -a.imaginary);
		}

		public static function cplx_inverse (a:ComplexNumber):ComplexNumber
		{                               
			/* z=1/a */
		  	var s:Number = 1.0 / cplx_abs (a);
		 	return new ComplexNumber( (a.real * s) * s, -(a.imaginary * s) * s);
		}

		/**********************************************************************
		 * Elementary complex functions
		 **********************************************************************/

		public static function cplx_sqrt ( a:ComplexNumber ):ComplexNumber
		{                               
			/* z=sqrt(a) */
		  	var z:ComplexNumber;
			var t:Number;
			
		  	if (a.real == 0.0 && a.imaginary == 0.0)
		    {
		      	z = new ComplexNumber( 0, 0);
		    } else
		    {
		      	var x:Number = Math.abs (a.real);
		     	var y:Number = Math.abs (a.imaginary);
		      	var w:Number;
		
		      	if (x >= y)
		      	{
		          	 t = y / x;
		         	 w = Math.sqrt(x) * Math.sqrt(0.5 * (1.0 + Math.sqrt(1.0 + t * t)));
		        } else
		        {
		          	  t = x / y;
		         	  w = Math.sqrt (y) * Math.sqrt (0.5 * (t + Math.sqrt (1.0 + t * t)));
		        }
		
		      	if (a.real >= 0.0)
		        {
		          z = new ComplexNumber( w, a.imaginary / (2.0 * w));
		        } else
		        {
		          var vi:Number = (a.imaginary >= 0) ? w : -w;
		          z = new ComplexNumber( a.imaginary / (2.0 * vi), vi);
		        }
		    }
		
		  	return z;
		}

		public static function cplx_sqrt_real (x:Number):ComplexNumber
		{                               
			  /* z=sqrt(x) */
			  var z:ComplexNumber;
		
			  if (x >= 0)
			  {
			      z = new ComplexNumber( Math.sqrt(x), 0.0);
			  } else
			  {
			      z = new ComplexNumber( 0.0, Math.sqrt(-x));
			  }
			  return z;
		}

		public static function cplx_exp (a:ComplexNumber):ComplexNumber
		{                              
			 /* z=exp(a) */
		  	var rho:Number = Math.exp (a.real);
		  	var theta:Number = a.imaginary;
		
		  	return new ComplexNumber( rho * Math.cos (theta), rho * Math.sin (theta));
		}

		public static function cplx_pow ( a:ComplexNumber, b:ComplexNumber):ComplexNumber
		{                               
		
			/* z=a^b */
		    var z:ComplexNumber;
		
		  	if (a.real == 0 && a.imaginary == 0.0)
		    {
		      z = new ComplexNumber( 0.0, 0.0);
		    } else
		    {
		      var logr:Number = cplx_logabs (a);
		      var theta:Number = cplx_arg (a);
		
		      var rho:Number = Math.exp (logr * b.real - b.imaginary * theta);
		      var beta:Number = theta * b.real + b.imaginary * logr;
		
		      z = new ComplexNumber( rho * Math.cos (beta), rho * Math.sin (beta));
		    }
		
		    return z;
		}

		public static function cplx_pow_real (a:ComplexNumber, b:Number ):ComplexNumber
		{                               
			/* z=a^b */
		  	var z:ComplexNumber;
		
		  	if (a.real == 0 && a.imaginary == 0)
		    {
		      z = new ComplexNumber( 0, 0);
		    } else
		    {
		      var logr:Number = cplx_logabs (a);
		      var theta:Number = cplx_arg (a);
		      var rho:Number = Math.exp (logr * b);
		      var beta:Number = theta * b;
		      z = new ComplexNumber( rho * Math.cos (beta), rho * Math.sin (beta));
		    }
		
		  return z;
		}

		public static function cplx_log (a:ComplexNumber):ComplexNumber
		{                               
			/* z=log(a) */
		  	var logr:Number = cplx_logabs (a);
		  	var theta:Number = cplx_arg (a);
			
			return new ComplexNumber( logr, theta );
		}

		 public static function cplx_log10 (a:ComplexNumber):ComplexNumber
		{                               
			/* z = Math.log10(a) */
		  	return cplx_mul_real (cplx_log (a), 1 / Math.log (10));
		}

		 public static function cplx_log_b (a:ComplexNumber, b:ComplexNumber):ComplexNumber
		{
		  return cplx_div (cplx_log (a), cplx_log (b));
		}

		/***********************************************************************
		 * Complex trigonometric functions
		 ***********************************************************************/

		 public static function cplx_sin (a:ComplexNumber):ComplexNumber
		{                               
			/* z = sin(a) */
		  
		  var z:ComplexNumber;
		
		  if ( a.imaginary == 0.0) 
		    {
		      /* avoid returing negative zero (-0.0) for the imaginary part  */
		
		      z = new ComplexNumber( Math.sin (a.real), 0.0);  
		    } 
		  else 
		    {
		      z = new ComplexNumber( Math.sin (a.real) * MathUtils.cosh (a.imaginary), Math.cos (a.real) * MathUtils.sinh (a.imaginary));
		    }
		
		  return z;
		}

		public static function cplx_cos (a:ComplexNumber):ComplexNumber
		{                               /* z = cos(a) */
		 	
		 	var z:ComplexNumber;
		 
		  	if (a.imaginary == 0.0) 
		    {
		      /* avoid returing negative zero (-0.0) for the imaginary part  */
		
		      z = new ComplexNumber( Math.cos (a.real), 0.0);  
		    } 
		  	else 
		    {
		      z = new ComplexNumber( Math.cos (a.real) *  MathUtils.cosh (a.imaginary), Math.sin (a.real) *  MathUtils.sinh (-a.imaginary));
		    }
		
		  return z;
		}

		 public static function cplx_tan (a:ComplexNumber):ComplexNumber
		{                               
			/* z = tan(a) */
		  	
		  	var z:ComplexNumber;
			var D:Number;
			
		  	if (Math.abs (a.imaginary) < 1)
		    {
		      D = Math.pow (Math.cos (a.real), 2.0) + Math.pow (  MathUtils.sinh (a.imaginary), 2.0);
		
		      z = new ComplexNumber( 0.5 * Math.sin (2 * a.real) / D, 0.5 *  MathUtils.sinh (2 * a.imaginary) / D);
		    }
		  else
		    {
		      var u:Number = Math.exp (-a.imaginary);
		      var C:Number = 2 * u / (1 - Math.pow (u, 2.0));
		      D = 1 + Math.pow (Math.cos (a.real), 2.0) * Math.pow (C, 2.0);
		
		      var S:Number = Math.pow (C, 2.0);
		      var T:Number = 1.0 /  MathUtils.tanh (a.imaginary);
		
		      z = new ComplexNumber( 0.5 * Math.sin (2 * a.real) * S / D, T / D);
		    }
		
		   return z;
		}

		public static function cplx_sec (a:ComplexNumber):ComplexNumber
		{                              
			 /* z = sec(a) */
		  	return cplx_inverse ( cplx_cos (a) );
		}

		public static function cplx_csc (a:ComplexNumber):ComplexNumber
		{                               
			/* z = csc(a) */
		  	return cplx_inverse(cplx_sin (a));
		}


		public static function cplx_cot (a:ComplexNumber):ComplexNumber
		{                               
			/* z = cot(a) */
		    return cplx_inverse (cplx_tan (a));
		}

		/**********************************************************************
		 * Inverse Complex Trigonometric Functions
		 **********************************************************************/
		
		 public static function cplx_arcsin (a:ComplexNumber):ComplexNumber
		{                               
		
			/* z = arcsin(a) */
		  	var z:ComplexNumber;
		
		  if (a.imaginary == 0)
		    {
		      z = cplx_arcsin_real (a.real);
		    }
		  else
		    {
		      var x:Number = Math.abs (a.real); 
		      var y:Number = Math.abs (a.imaginary);
		      var r:Number = MathUtils.hypot (x + 1, y)
		      var s:Number = MathUtils.hypot (x - 1, y);
		      var A:Number = 0.5 * (r + s);
		      var B:Number = x / A;
		      var y2:Number = y * y;
		
		      var real:Number;
		      var imag:Number;
		      var D:Number;
		
		      var A_crossover:Number = 1.5; 
		      var B_crossover:Number = 0.6417;
		
		      if (B <= B_crossover)
		        {
		          real = Math.asin (B);
		        }
		        
		      else
		        {
		          if (x <= 1)
		            {
		              D = 0.5 * (A + x) * (y2 / (r + x + 1) + (s + (1 - x)));
		              real = Math.atan (x / Math.sqrt (D));
		            }
		          else
		            {
		              var Apx:Number = A + x;
		              D = 0.5 * (Apx / (r + x + 1) + Apx / (s + (x - 1)));
		              real = Math.atan (x / (y * Math.sqrt (D)));
		            }
		        }
		
		      if (A <= A_crossover)
		        {
		          var Am1:Number;
		
		          if (x < 1)
		            {
		              Am1 = 0.5 * (y2 / (r + (x + 1)) + y2 / (s + (1 - x)));
		            }
		          else
		            {
		              Am1 = 0.5 * (y2 / (r + (x + 1)) + (s + (x - 1)));
		            }
		
		          imag =  MathUtils.log1p (Am1 + Math.sqrt (Am1 * (A + 1)));
		        }
		      else
		        {
		          imag = Math.log (A + Math.sqrt (A * A - 1));
		        }
		
		      z = new ComplexNumber( (a.real >= 0) ? real : -real, (a.imaginary >= 0) ? imag : -imag);
		    }
		
		  return z;
		}

		 public static function cplx_arcsin_real ( a:Number ):ComplexNumber
		{                              
			 /* z = arcsin(a) */
		  	var z:ComplexNumber;
		
		  if (Math.abs (a) <= 1.0)
		    {
		      z = new ComplexNumber( Math.asin (a), 0.0);
		    }
		  else
		    {
		      if (a < 0.0)
		        {
		          z = new ComplexNumber( - 0.5 * Math.PI,  MathUtils.acosh (-a));
		        }
		      else
		        {
		          z = new ComplexNumber( 0.5 * Math.PI, - MathUtils.acosh (a));
		        }
		    }
		
		  return z;
		}


		public static function cplx_arccos (a:ComplexNumber):ComplexNumber
		{                               /* z = arccos(a) */
			var z:ComplexNumber;
		
		  	if (a.imaginary == 0)
		    {
		      	z = cplx_arccos_real (a.real);
		    } else
		    {
		      var x:Number = Math.abs (a.real)
		      var y:Number = Math.abs (a.imaginary);
		      var r:Number = MathUtils.hypot (x + 1, y)
		      var s:Number = MathUtils.hypot (x - 1, y);
		      var A:Number = 0.5 * (r + s);
		      var B:Number = x / A;
		      var y2:Number = y * y;
		
		      var real:Number;
		      var imag:Number;
			  var D:Number;
		
		      var A_crossover:Number = 1.5
		      var B_crossover:Number = 0.6417;
		
		      if (B <= B_crossover)
		      {
		      	  real =  Math.acos (B);
		      } else
		      {
		          if (x <= 1)
		          {
		              D = 0.5 * (A + x) * (y2 / (r + x + 1) + (s + (1 - x)));
		              real = Math.atan (Math.sqrt (D) / x);
		          } else
		          {
		              var Apx:Number = A + x;
		              D = 0.5 * (Apx / (r + x + 1) + Apx / (s + (x - 1)));
		              real = Math.atan ((y * Math.sqrt (D)) / x);
		          }
		       }
		
		       if (A <= A_crossover)
		       {
		          var Am1:Number;
		
		          if (x < 1)
		          {
		              Am1 = 0.5 * (y2 / (r + (x + 1)) + y2 / (s + (1 - x)));
		          } else
		          {
		              Am1 = 0.5 * (y2 / (r + (x + 1)) + (s + (x - 1)));
		          }
		
		          imag =  MathUtils.log1p (Am1 + Math.sqrt (Am1 * (A + 1)));
		        } else
		        {
		          imag = Math.log (A + Math.sqrt (A * A - 1));
		        }
		
		        z = new ComplexNumber( (a.real >= 0) ? real : Math.PI - real, (a.imaginary >= 0) ? -imag : imag);
		    }
		
		  return z;
		}

		public static function cplx_arccos_real ( a:Number ):ComplexNumber
		{                               
			/* z = arccos(a) */
			var z:ComplexNumber;
			
			  if (Math.abs (a) <= 1.0)
			  {
			      z = new ComplexNumber( Math.acos (a), 0);
			  } else
			  {
			      if (a < 0.0)
			      {
			          z = new ComplexNumber( Math.PI, - MathUtils.acosh (-a));
			      } else
			      {
			          z = new ComplexNumber( 0,  MathUtils.acosh (a));
			      }
			  }
			
			  return z;
		}

		public static function cplx_arctan (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arctan(a) */
		  	var z:ComplexNumber;
		
		  	if (a.imaginary == 0)
		    {
		      	z = new ComplexNumber( Math.atan (a.real), 0);
		    } else
		    {
		      /* FIXME: This is a naive implementation which does not fully
		         take into account cancellation errors, overflow, underflow
		         etc.  It would benefit from the Hull et al treatment. */
		
		     	var r:Number =  MathUtils.hypot (a.real, a.imaginary);
			  	var imag:Number;
		
		        var u:Number = 2 * a.imaginary / (1 + r * r);
		
		      /* FIXME: the following cross-over should be optimized but 0.1
		         seems to work ok */
		
		      	if (Math.abs (u) < 0.1)
		        {
		          	imag = 0.25 * ( MathUtils.log1p (u) -  MathUtils.log1p (-u));
		        } else
		        {
		          var A:Number =  MathUtils.hypot (a.real, a.imaginary + 1);
		          var B:Number =  MathUtils.hypot (a.real, a.imaginary - 1);
		          imag = 0.5 * Math.log (A / B);
		        }
		
		      	if (a.real == 0)
		        {
		          if (a.imaginary > 1)
		          {
		              z = new ComplexNumber( 0.5* Math.PI, imag);
		          } else if (a.imaginary < -1)
		          {
		              z = new ComplexNumber( -0.5* Math.PI, imag);
		          }else
		          {
		              z = new ComplexNumber( 0, imag);
		          };
		        }
		      else
		        {
		          z = new ComplexNumber( 0.5 * Math.atan2 (2 * a.real, ((1 + r) * (1 - r))), imag);
		        }
		    }
		
		  return z;
		}

		public static function cplx_arcsec ( a:ComplexNumber ):ComplexNumber
		{                               
			/* z = arcsec(a) */
		  	return cplx_arccos (cplx_inverse (a));
		}

		public static function cplx_arcsec_real ( a:Number ):ComplexNumber
		{                               
			/* z = arcsec(a) */
		  	var z:ComplexNumber;
		
		  	if (a <= -1.0 || a >= 1.0)
		    {
		      	z = new ComplexNumber( Math.acos (1 / a), 0.0);
		    } else
		    {
		      	if (a >= 0.0)
		        {
		          z = new ComplexNumber( 0,  MathUtils.acosh (1 / a));
		        } else
		        {
		          z = new ComplexNumber( Math.PI, - MathUtils.acosh (-1 / a));
		        }
		    }
		
		  	return z;
		}

		public static function cplx_arccsc (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arccsc(a) */
		  	return cplx_arcsin (cplx_inverse (a));
		}

		public static function cplx_arccsc_real ( a:Number ):ComplexNumber
		{                               
			/* z = arccsc(a) */
		  	var z:ComplexNumber;
		
		  	if (a <= -1.0 || a >= 1.0)
		    {
		      	z = new ComplexNumber( Math.asin (1 / a), 0.0);
		    } else
		    {
		      	if (a >= 0.0)
		        {
		          	z = new ComplexNumber( 0.5 * Math.PI, - MathUtils.acosh (1 / a));
		        } else
		        {
		           z = new ComplexNumber( -0.5 * Math.PI,  MathUtils.acosh (-1 / a));
		        }
		    }
		
		  return z;
		}

		public static function cplx_arccot (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arccot(a) */
		   	var z:ComplexNumber;
		
		  	if (a.real == 0.0 && a.imaginary == 0.0 )
		    {
		      	z = new ComplexNumber( 0.5 * Math.PI, 0 );
		    } else
		    {
		      	z = cplx_arctan ( cplx_inverse (a) );
		    }
		
		  return z;
		}

		/**********************************************************************
		 * Complex Hyperbolic Functions
		 **********************************************************************/

		public static function cplx_sinh ( a:ComplexNumber ):ComplexNumber
		{                               
			/* z = sinh(a) */
		  	return new ComplexNumber(  MathUtils.sinh (a.real) * Math.cos (a.imaginary),  MathUtils.cosh (a.real) * Math.sin (a.imaginary));
		}

		public static function cplx_cosh ( a:ComplexNumber ):ComplexNumber
		{                               
			/* z = cosh(a) */
		  	return new ComplexNumber(  MathUtils.cosh (a.real) * Math.cos (a.imaginary),  MathUtils.sinh (a.real) * Math.sin (a.imaginary));;
		}

		public static function cplx_tanh ( a:ComplexNumber ):ComplexNumber
		{                               
			/* z = tanh(a) */
		  
		  	var z:ComplexNumber;
			var D:Number;
		  	if (Math.abs(a.real) < 1.0) 
		    {
		      D = Math.pow (Math.cos (a.imaginary), 2.0) + Math.pow ( MathUtils.sinh (a.real), 2.0);
		      
		      z = new ComplexNumber(  MathUtils.sinh (a.real) *  MathUtils.cosh (a.real) / D, 0.5 * Math.sin (2 * a.imaginary) / D);
		    } else
		    {
		       D = Math.pow (Math.cos (a.imaginary), 2.0) + Math.pow ( MathUtils.sinh (a.real), 2.0);
		      	var F:Number = 1 + Math.pow (Math.cos (a.imaginary) /  MathUtils.sinh (a.real), 2.0);
		
		      	z = new ComplexNumber( 1.0 / (  MathUtils.tanh (a.real) * F), 0.5 * Math.sin (2 * a.imaginary) / D);
		    }
		
		  	return z;
		}

		public static function cplx_sech ( a:ComplexNumber ):ComplexNumber
		{                               
			/* z = sech(a) */
		  	return cplx_inverse (cplx_cosh (a));
		}

		public static function cplx_csch (a:ComplexNumber):ComplexNumber
		{                               
			/* z = csch(a) */
		  	return cplx_inverse (cplx_sinh (a));
		}

		public static function cplx_coth (a:ComplexNumber):ComplexNumber
		{                               
			/* z = coth(a) */
		  	return cplx_inverse (cplx_tanh (a));
		}

		/**********************************************************************
		 * Inverse Complex Hyperbolic Functions
		 **********************************************************************/

		public static function cplx_arcsinh (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arcsinh(a) */
		 	return cplx_mul_imag (cplx_arcsin (cplx_mul_imag(a, 1.0)), -1.0);;
		}

		public static function cplx_arccosh (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arccosh(a) */
		  	var z:ComplexNumber = cplx_arccos (a);
		  	return cplx_mul_imag (z, z.imaginary > 0 ? -1.0 : 1.0);
		}

		public static function cplx_arccosh_real ( a:Number ):ComplexNumber
		{                               
			/* z = arccosh(a) */
		  	var z:ComplexNumber;
		
		  	if (a >= 1)
		    {
		      z = new ComplexNumber(  MathUtils.acosh (a), 0);
		    } else
		    {
		      	if (a >= -1.0)
		        {
		          	z = new ComplexNumber( 0, Math.acos (a));
		        } else
		        {
		          	z = new ComplexNumber(  MathUtils.acosh (-a), Math.PI );
		        }
		    }
		
		  	return z;
		}

		public static function cplx_arctanh (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arctanh(a) */
		  	if (a.imaginary == 0.0)
		    {
		      	return cplx_arctanh_real (a.real);
		    } else
		    {
		        return cplx_mul_imag (cplx_arctan (cplx_mul_imag(a, 1.0)), -1.0);
		    }
		}

		public static function cplx_arctanh_real ( a:Number ):ComplexNumber
		{                               
		
			/* z = arctanh(a) */
		  	var z:ComplexNumber;
		
		  	if (a > -1.0 && a < 1.0)
		    {
		      z = new ComplexNumber(  MathUtils.atanh (a), 0);
		    } else
		    {
		      z = new ComplexNumber(  MathUtils.atanh (1 / a), (a < 0) ? 0.5 * Math.PI : -0.5 * Math.PI);
		    }
		
		  return z;
		}

		public static function cplx_arcsech (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arcsech(a); */
		  	return cplx_arccosh (cplx_inverse (a));
		}

		public static function cplx_arccsch (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arccsch(a) */
		  	return cplx_arcsinh (cplx_inverse (a));
		}

		public static function cplx_arccoth (a:ComplexNumber):ComplexNumber
		{                               
			/* z = arccoth(a) */
		  	return cplx_arctanh (cplx_inverse (a));
		}
	}
}

