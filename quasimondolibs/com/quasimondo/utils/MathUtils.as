package com.quasimondo.utils
{
	import __AS3__.vec.Vector;
	
	import com.quasimondo.math.PrimeNumber;
	
	public class MathUtils
	{
		//public static var primes:Vector.<Number>;
		private static var firstPrime:PrimeNumber = new PrimeNumber(2);
		private static var lastPrime:PrimeNumber = firstPrime.setNext(3).setNext(5).setNext(7);
		
		public static function distance( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			return hypot(x1-x2,y1-y2);
		}
		
		public static function hypot( x:Number, y:Number ):Number
        {
            return Math.sqrt( x * x + y * y);
        }
        
		public static function floor( n:Number ):Number
		{
			return n>>0;
		}
		
		public static function abs( n:Number ):Number
		{
			return ( n < 0 ? -n : n );
		}
		
		public static function sgn( n:Number ):Number
		{
			return ( n < 0 ? -1 : n > 0 ? 1 : 0 );
		}
		
		public static function log1p( x:Number ):Number
        {
            var u:Number = 1 + x;
            if (u == 1)
                return x;
            else
                return Math.log( u ) * x / ( u - 1 );
        }
        
        public static function expm1( x:Number ):Number
        {
            var u:Number = Math.exp(x);
            if (u == 1)
                return x;
            if (u-1 == -1)
                return -1;
            return ( u - 1 ) * x / Math.log(u);  /* where log is natural logarithm */
        }
        
        public static function sinh( x:Number ):Number
        {
         	var u:Number = expm1(x);
        	return .5 * u / (u+1) * (u+2);
        }
        
        public static function cosh( x:Number ):Number
        {
        	// this has to be tested
        	return 0.5 * ( expm1( 2 * x) + 2)
        }
        
        public static function tanh( x:Number ):Number
        {
        	// this has to be tested
        	
        	return expm1(2*x) / (expm1(2*x) + 2);
        }
        
        public static function asinh( x:Number ):Number
        {
          return log1p(x * (1 + x/(Math.sqrt(x*x+1)+1)));
        }
        
        public static function acosh( x:Number ):Number
        {
        	if ( isNaN(x) || x < 1) {
				return Number.NaN;
			} else if (x < 94906265.62) {
				// 94906265.62 = 1.0/Math.sqrt(EPSILON_SMALL)
				return Math.log(x+Math.sqrt(x*x-1.0));
			} else {
				return 0.69314718055994530941723212145818 + Math.log(x);
			}
		}
		
		public static function atanh( x:Number ):Number
        {
        	return 0.5 * Math.log( (1+x) / ( 1-x) );
        }
		
		public static function linearInterpolation( values:Array, t:Number ):Number
		{
			if ( values.length == 0 ) return 0;
			if ( values.length == 1 || t == 0 || t < 0 ) return values[0];
			if ( t >= 1 ) return values[values.length - 1];
			
			var i:int = (values.length - 1) * t ;
			var ts:Number = 1 /  (values.length - 1);
			var f:Number = ( t % ts ) / ts;
			return (1-f) * values[i] + ( f * values[i+1] );
			
		}
		
		//Greatest Common Divisor
		public static function GCD( n1:Number, n2:Number ):Number
		{
			var a:Number = Math.max( n1, n2 );
			var b:Number = Math.min( n1, n2 );
			
			return ( b == 0 ? a : GCD(b, a % b) );
		}
		
		public static function isPrime( n:Number ):Boolean
		{
			if ( ( n & 1 ) == 0 || ( n > 5 && n % 5 == 0) ) return false;
			
			var max:Number = Math.sqrt( n );
			if ( max == Math.floor(max) ) return false;
			
			var p:PrimeNumber = firstPrime;
			var pn:Number;
			while ( p != null )
			{
				if ( (pn = p.n) > max )  return true;
				if ( n % pn == 0 ) return false;
				p = p.p;
			}
			
			var divisor:Number = lastPrime.n;
			while ( ( divisor += 2 ) <= max )
			{
				if ( !isPrime(divisor) ) continue;
				lastPrime = lastPrime.setNext( divisor );
				if ( divisor > max ) return true;
				if ( n % divisor == 0 ) return false;
			} 
			 
			return true;
		}
		
		public static function GLSL( m:Vector.<Number> ):void
		{
			var q:Number;
			var i:int, j:int, k:int;
			for ( j = 0; j < 3; j++) 
			{
				q = m[ int( j * 5 ) ];
				
				if (q == 0) 
				{
					for ( i = j + 1; i < 3; i++) 
					{
						if ( m [ int( i * 4 + j ) ] != 0 )
						{
							for ( k = 0; k < 4; k++) 
							{
								m[ int(j * 4 + k)] += m[ int( i * 4 + k) ];
							}
							q = m[ int( j * 5 ) ];
							break;
						}
					}
				}
				
				if (q != 0) 
				{
					for ( k=0; k < 4; k++)
					{
						m[ int( j * 4 + k )] = m[ int( j * 4 + k )]  / q;
					}
				}
				
				for ( i = 0; i < 3; i++)
				{
					if ( i != j )
					{
						q = m[ int( i * 4 + j )];
						for ( k=0; k < 4; k++)
						{
							m[ int( i * 4 + k )] -= q * m[ int( j * 4 + k )];
						}
					}
				}
			}
		}
		/*
		public static function isPrime( n:Number ):Boolean
		{
			if ( ( n & 1 ) == 0 ) return false;
			
			if ( primes == null )
			{
				primes = new Vector.<Number>();
				primes[0] = 2;
				primes[1] = 3;
			}
			n = Math.abs( n );
			var max:Number = Math.sqrt( n );
			if ( max == Math.floor(max) ) return false;
			
			var primeCount:uint = primes.length;
			var primeIdx:uint = 0;
			while ( primeIdx < primeCount )
			{
				if ( primes[primeIdx] > max ) return true;
				if ( n % primes[primeIdx++] == 0 ) return false;
			}
			
			var divisor:Number = primes[primeIdx-1];
			var maxDivisor:Number;
			while ( (divisor+=2) <= max )
			{
				if ( !isPrime(divisor) ) continue;
				primes.push( divisor );
				if ( divisor > max ) return true;
				if ( n % divisor == 0 ) return false;
			} 
			 
			
			return true;
		}
		*/
		
		static public function nextPrime( n:Number ):Number
		{
			n += ( (n & 1) == 0 ? 1 : 2 );
			
			
			if ( lastPrime.n > n )
			{
				var p:PrimeNumber = firstPrime;
				while ( true )
				{
					if (p.n>=n) return p.n;
					p = p.p;
				}
			} else {
				while ( !isPrime(n) ) n+=2;
			}
			return n; 
		}
		
		
		static public function getPrimeFactors( n:Number ):Vector.<Number>
		{
			var result:Vector.<Number> = new Vector.<Number>();
			var factor:Number = 2;
			while ( n > 1 )
			{
				if ( n % factor == 0 )
				{
					result.push( factor );
					n /= factor;
				} else {
					factor = nextPrime( factor );
				}
			}
			return result;
		}
		
		
		static public function isTriangular( n:Number ):Boolean
		{
			var t:Number = Math.sqrt( 8 * n + 1 );
			return t==Math.floor(t);
		}
		
		static public function isPentagonal( n:Number ):Boolean
		{
			return isTriangular( n * 3 );
		}
		
		static public function isSquare( n:Number ):Boolean
		{
			var t:Number = Math.sqrt( n );
			return t==Math.floor(t);
		}
		
		static public function countSetBits(n:uint):int
		{
			var c:int = 0;
			while ( n > 0 )
			{
				c += (n & 1);
				n>>=1;	
			}
			return  c;
		}
		
		static public function getDigitalRoot( n:Number ):Number
		{
			var sum:int = 0;
			while ( n > 9 )
			{
				sum += n % 10;
				n = (n - n%10 ) / 10;
			}	
			return sum;
		}
		
		
		static public function isKlingemannPrime( n:Number ):Boolean
		{
			if ( (n & 1 ) == 0 ) return false;
			var primeAngles:Array = [1,7,11,13];
			var angle:Number = (11 * n) % 30;
			
			for each ( var primeAngle:Number in primeAngles )
			{
				if (  primeAngle == angle || 30 - angle == primeAngle){
					//trace((461 * n) % 6469693230);
					return true;
				} 
			}
			return false;		
		}
		
		// get nth permutation of a set of symbols
		static public function factorial( n:uint ):uint 
		{
			var r:uint = 1;
			do
			{
				r *= n;
			} while ( --n > 1 )
			return r;
		}
		
		// get nth permutation of a set of symbols
		static public function getNthPermutation( symbols:Array, n:uint ):Array 
		{
			return permutation(symbols, n_to_factoradic(n));
		}
		
		// convert n to factoradic notation
		static public function n_to_factoradic( n:uint, p:uint=2):Vector.<uint> 
		{
			if(n < p) return Vector.<uint>([n]);
			var ret:Vector.<uint> = n_to_factoradic(n/p, p+1);
			ret.push(n % p);
			return ret;
		}
		
		// return nth permutation of set of symbols via factoradic
		static public function permutation( symbols:Array, factoradic:Vector.<uint>):Array 
		{
			factoradic.push(0);
			while(factoradic.length < symbols.length) factoradic.unshift(0);
			var ret:Array = [];
			var s:Array = symbols.concat();
			while(factoradic.length) {
				var f:uint = factoradic.shift();
				ret.push(s[f]);
				s.splice(f, 1);
			}
			return ret;
		}
		
		
	}
}