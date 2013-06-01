package com.quasimondo.geom
{
	//Directly ported from Jonathan Blow's example code to his article
	//"My Friend, the Covariance Body" published in Game Developer Magazine
	//http://www.number-none.com/product/My%20Friend,%20the%20Covariance%20Body/index.html
	//http://www.gdmag.com/src/sep02.zip
	
	public class CovarianceMatrix2
	{
		public var a:Number;
		public var b:Number;
		public var c:Number;
		
		public function CovarianceMatrix2()
		{
			reset();
		}
		
		public function reset():void 
		{
			a = b = c = 0;
		}
		
		public function invert():CovarianceMatrix2 
		{
			var det:Number = a*c - b*b;
			var factor:Number = 1.0 / det;
			
			var result:CovarianceMatrix2 = new CovarianceMatrix2();
			result.a = c * factor;
			result.b = -b * factor;
			result.c = a * factor;
			
			return result;
		}
		
		public function add( other:CovarianceMatrix2 ): CovarianceMatrix2 
		{
			var result:CovarianceMatrix2 = new CovarianceMatrix2();
			result.a = a + other.a;
			result.b = b + other.b;
			result.c = c + other.c;
			
			return result;
		}
			
		public function scale( factor:Number ):void 
		{
			a *= factor;
			b *= factor;
			c *= factor;
		}
		
		public function rotate( theta:Number ):void 
		{
			var s:Number = Math.sin(theta);
			var t:Number = Math.cos(theta);
			
			var a_prime:Number = a*t*t + b*2*s*t + c*s*s;
			var b_prime:Number = -a*s*t + b*(t*t - s*s) + c*s*t;
			var c_prime:Number = a*s*s - b*2*s*t + c*t*t;
			
			a = a_prime;
			b = b_prime;
			c = c_prime;
		}
		
		
		private function solve_quadratic_where_discriminant_is_known_to_be_nonnegative( a:Number, b:Number, c:Number ):CovarianceMatrixSolution_Set 
		{
			var result:CovarianceMatrixSolution_Set = new CovarianceMatrixSolution_Set();
			
			if (a == 0.0) {  // Then bx + c = 0; thus, x = -c / b
				if (b == 0.0) {
					result.num_solutions = 0;
					return result;
				}
				
				result.solutions[0] = -c / b;
				result.num_solutions = 1;
				return result;
			}
			
			var discriminant:Number = b * b - 4 * a * c;
			if (discriminant < 0.0) discriminant = 0.0;
			
			var sign_b:Number = 1.0;
			if (b < 0.0) sign_b = -1.0;
			
			var nroots:int = 0;
			var q:Number = -0.5 * (b + sign_b * Math.sqrt(discriminant));
			
			nroots++;
			result.solutions[0] = q / a;
			
			if (q != 0.0) {
				var solution:Number = c / q;
				if (solution != result.solutions[0]) {
					nroots++;
					result.solutions[1] = solution;
				}
			}
			
			result.num_solutions = nroots;
			return result;
		}
		
		// The CovarianceMatrix2 eigenvector path is completely separate (I wrote
		// it first, and it was simpler to just crank out).  
		
		public function find_eigenvalues( eigenvalues:Vector.<Number> ):int 
		{
			var qa:Number, qb:Number, qc:Number;
			qa = 1;
			qb = -(a + c);
			qc = a * c - b * b;
			
			var solution:CovarianceMatrixSolution_Set = 
						solve_quadratic_where_discriminant_is_known_to_be_nonnegative(qa, qb, qc );
			
			// If there's only one solution, explicitly state it as a
			// double eigenvalue.
			if (solution.num_solutions == 1) 
			{
				solution.solutions[1] = solution.solutions[0];
				solution.num_solutions = 2;
			}
			
			eigenvalues[0] = solution.solutions[0];
			eigenvalues[1] = solution.solutions[1];
			return solution.num_solutions;
		}
		
		public function find_eigenvectors( eigenvalues:Vector.<Number>, eigenvectors:Vector.<Vector2>):int 
		{
			var num_eigenvalues:int = find_eigenvalues(eigenvalues);
			if (num_eigenvalues != 2)
			{
				throw( new Error("Did not get 2 Eigenvalues but "+num_eigenvalues ));
			};
			
			// Now that we have the quadratic coefficients, find the eigenvectors.
			
			const VANISHING_EPSILON:Number = 1.0e-5;
			const SAMENESS_LOW:Number = 0.9999;
			const SAMENESS_HIGH:Number = 1.0001;
			
			var punt:Boolean = false;
			const A_EPSILON:Number = 0.0000001;
			
			if (a < A_EPSILON) {
				punt = true;
			} else {
				var ratio:Number = Math.abs(eigenvalues[1] / eigenvalues[0]);
				if ((ratio > SAMENESS_LOW) && (ratio < SAMENESS_HIGH)) punt = true;
			}
			
			if (punt) {
				eigenvalues[0] = a;
				eigenvalues[1] = a;
				
				eigenvectors[0] = new Vector2(1, 0);
				eigenvectors[1] = new Vector2(0, 1);
				num_eigenvalues = 2;
				return num_eigenvalues;
			}
			
			var j:int;
			for (j = 0; j < num_eigenvalues; j++) {
				var lambda:Number = eigenvalues[j];
				
				var result1:Vector2 = new Vector2(-b, a - lambda);
				var result2:Vector2 = new Vector2(-(c - lambda), b);
				
				var result:Vector2;
				if (result1.length_squared > result2.length_squared) {
					result = result1;
				} else {
					result = result2;
				}
				
				result.normalize();
				eigenvectors[j] = result;
			}
			
			return num_eigenvalues;
		}
		
		public function move_to_global_coordinates( dest:CovarianceMatrix2, x:Number, y:Number):void
		{
			dest.a = a + x*x;
			dest.b = b + x*y;
			dest.c = c + y*y;
		}
		
		public function move_to_local_coordinates( dest:CovarianceMatrix2, x:Number, y:Number):void 
		{
			dest.a = a - x*x;
			dest.b = b - x*y;
			dest.c = c - y*y;
		}
				
	}
}

final internal class CovarianceMatrixSolution_Set 
{
	public var num_solutions:int = 0;
	public var solutions:Vector.<Number> = new Vector.<Number>(3,true);
};







