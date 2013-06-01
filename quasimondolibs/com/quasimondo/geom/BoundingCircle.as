package com.quasimondo.geom
{
	import __AS3__.vec.Vector;
	
	// Author: Michael Baczynski
	// taken from http://lab.polygonal.de/2007/02/17/bounding-circle-computation/
	
	public class BoundingCircle
	{
		
		public static const BOUNDINGCIRCLE_SIMPLE:int = 0;
		public static const BOUNDINGCIRCLE_EFFICIENT:int = 1;
		public static const BOUNDINGCIRCLE_EXACT:int = 2;
		
		
		/**
		 * simple 'bounding-box style' approx.
		 */
		public static function boundingCircle1(points:Vector.<Vector2>):Circle
		{
			var v:Vector2 = points[0];
			var vx:int = v.x;
			var vy:int = v.y;
			
			var xmin:int = vx;
			var ymin:int = vy;
			var xmax:int = vx;
			var ymax:int = vy;
			
			var k:uint = points.length;
			for (var i:uint = 1; i < k; i ++)
			{
				v = points[i];
				vx = v.x;
				vy = v.y;
				
				if (vx < xmin) xmin = vx;
				if (vy < ymin) ymin = vy;
				if (vx > xmax) xmax = vx;
				if (vy > ymax) ymax = vy;
			}
			
			var cx:int = (xmin + xmax) >> 1;
			var cy:int = (ymin + ymax) >> 1;
			
			var tx:int = (xmax - xmin) >> 1;
			var ty:int = (ymax - ymin) >> 1;
			
			var r:uint = tx + ty - (Math.min(tx, ty) >> 1);
			return new Circle(cx, cy, r);
		}
		
		/**
		 * An Efficient Bounding Sphere by Jack Ritter
		 * from "Graphics Gems", Academic Press, 1990
		 */
		public static function boundingCircle2(points:Vector.<Vector2>):Circle
		{
			//FIRST PASS: find 4 minima/maxima points
			var xmin:Vector2 = new Vector2(1e+10, 0);
			var ymin:Vector2 = new Vector2(0, 1e+10);
			var xmax:Vector2 = new Vector2(-1e+10, 0);
			var ymax:Vector2 = new Vector2(0, -1e+10);
			
			var i:uint, k:uint = points.length, p:Vector2;
			for (i = 0; i < k; i++)
			{
				p = points[i];
				if (p.x < xmin.x)
					xmin = p; //New xminimum point
				if (p.x > xmax.x)
					xmax = p;
				if (p.y < ymin.y)
					ymin = p;
				if (p.y > ymax.y)
					ymax = p;
			}
			//Set xspan = distance between the 2 points xmin & xmax (squared)
			var dx:int = xmax.x - xmin.x;
			var dy:int = xmax.y - xmin.y;
			var xspan:int = dx * dx + dy * dy;
			
			//same for y span
			dx = ymax.x - ymin.x;
			dy = ymax.y - ymin.y;
			var yspan:int = dx * dx + dy * dy;
			
			//Set points dia1 & dia2 to the maximally separated pair
			var dia1:Vector2 = xmin; //assume xspan biggest
			var dia2:Vector2 = xmax;
			var maxspan:Number = xspan;
			
			if (yspan > maxspan)
			{
				maxspan = yspan;
				dia1 = ymin;
				dia2 = ymax;
			}
			
			//dia1,dia2 is a diameter of initial circle
			//calc initial center
			var cx:int = (dia1.x + dia2.x) >> 1;
			var cy:int = (dia1.y + dia2.y) >> 1;
			
			//calculate initial radius**2 and radius 
			dx = dia2.x - cx; //x component of radius vector
			dy = dia2.y - cy; //y component of radius vector
			
			var rSq:Number = dx * dx + dy * dy;
			var r:Number = Math.sqrt(rSq);
			
			var t0:Number, t1:Number;
			
			var dSq:Number, d0:Number, d1:Number;
			
			//SECOND PASS: increment current circle 
			for (i = 0; i < k; i++)
			{	//this point is outside of current circle
				p = points[i];
				
				dx = p.x - cx;
				dy = p.y - cy;
				dSq = dx * dx + dy * dy;
				if (dSq > rSq) //do r**2 test first
				{ 
					d0 = Math.sqrt(dSq);
					
					//calc radius of new circle
					r = (r + d0) >> 1;
					rSq = r * r;  //for next r**2 compare
					d1 = d0 - r;
					
					// calc center of new sphere
					cx = (r * cx + d1 * p.x) / d0;
					cy = (r * cy + d1 * p.y) / d0;
				}
			}
			
			return new Circle(cx, cy, r);
		}
		
		/**
		 * easy bounding circle (exact) by Jon Rokne
		 * from "graphics gems II"
		 */
		public static function boundingCircle3(vertices:Vector.<Vector2>):Circle
		{
			var P:Vector2, Q:Vector2, R:Vector2;
			var pi:Number, qi:Number, ri:Number;
			
			var dx0:Number, dy0:Number, dx1:Number, dy1:Number;
			
			var cx:Number, cy:Number, radius:Number;
			
			//determine a point P with the smallest y value
			var i:Number, v:Vector2, vx:Number, vy:Number, ymin:Number = -1e+8;
			var k:Number = vertices.length;
			for (i = 0; i < k; i++)
			{
				v = vertices[i]; vy = v.y;
				if (vy > ymin)
				{
					ymin = vy;
					pi = i;
					P = v;
				}
			}
			
			var px:Number = P.x;
			var py:Number = P.y;
			
			// find a point Q such that the angle of the line segment
			// PQ with the x axis is minimal
			var dot_max:Number = Number.NEGATIVE_INFINITY, dot:Number;
			for (i = 0; i < k; i++)
			{
				if (i == pi) continue;
				
				v = vertices[i];
				dx0 = v.x - px;
				dy0 = v.y - py;
				
				dot = (dx0 < 0 ? -dx0 : dx0) / Math.sqrt(dx0 * dx0 + dy0 * dy0);
				if (dot > dot_max)
				{
					dot_max = dot;
					Q  = v;
					qi = i;
				}
			}
			var qx:Number = Q.x;
			var qy:Number = Q.y;
			
			var rx:Number, ry:Number;
			for (i = 0; i < k; i++)
			{
				dot_max = Number.NEGATIVE_INFINITY;
				
				//find R such that the absolute value
				//of the angle PRQ is minimal
				for (var j:Number = 0; j < k; j++)
				{
					if (j == pi) continue;
					if (j == qi) continue;
					
					v = vertices[j];
					
					vx = v.x;
					vy = v.y;
					
					dx0 = px - vx; dy0 = py - vy;
					dx1 = qx - vx; dy1 = qy - vy;
					
					dot = (dx0 * dx1 + dy0 * dy1) / (Math.sqrt(dx0 * dx0 + dy0 * dy0) * Math.sqrt(dx1 * dx1 + dy1 * dy1));
					if (dot > dot_max)
					{				
						dot_max = dot;
						R  = v;
						ri = j;
					}
				}
				rx = R.x;
				ry = R.y;
				
				//check for case 1 (angle PRQ is obtuse), the circle is determined
				//by two points, P and Q. radius = |(P-Q)/2|, center = (P+Q)/2
				if (dot_max < 0)
				{
					dx0 = px - qx;
					dy0 = py - qy;
					
					cx = (px + qx) / 2;
					cy = (py + qy) / 2;
					radius = Math.sqrt(((dx0 * dx0) / 4) + ((dy0 * dy0) / 4));
					return new Circle(cx, cy, radius);
				}
				
				//check if angle RPQ is acute
				dx0 = rx - px;
				dy0 = ry - py;
				
				dx1 = qx - px;
				dy1 = qy - py;
				
				dot = (dx0 * dx1 + dy0 * dy1) / (Math.sqrt(dx0 * dx0 + dy0 * dy0) * Math.sqrt(dx1 * dx1 + dy1 * dy1));
				
				// if angle RPQ is 
				if (dot < 0)
				{
					P = R;
					px = rx;
					py = ry;
					continue;
				}
				
				// angle PQR is acute ?
				dx0 = px - qx;
				dy0 = py - qy;
				
				dx1 = rx - qx;
				dy1 = ry - qy;
				
				dot = (dx0 * dx1 + dy0 * dy1) / (Math.sqrt(dx0 * dx0 + dy0 * dy0) * Math.sqrt(dx1 * dx1 + dy1 * dy1));
				
				if (dot < 0)
				{
					Q = R;
					qx = rx;
					qy = ry;
					continue;
				}
				
				//all angles in PQR are acute; quit
				break;
			}
			
			var mPQx:Number = (px + qx) / 2;
			var mPQy:Number = (py + qy) / 2;
			var mQRx:Number = (qx + rx) / 2;
			var mQRy:Number = (qy + ry) / 2;
			
			var numer:Number = -(-mPQy * ry + mPQy * qy + mQRy * ry - mQRy * qy - mPQx * rx + mPQx * qx + mQRx * rx - mQRx *qx);
			var denom:Number =  (-qx * ry + px * ry - px * qy + qy * rx - py * rx + py * qx);
			
			var t:Number = numer / denom;
			
			cx  = -t * (qy - py) + mPQx;
			cy  =  t * (qx - px) + mPQy;
			
			dx0 = cx - px;
			dy0 = cy - py;
			
			radius = Math.sqrt(dx0 * dx0 + dy0 * dy0);
			
			return new Circle(cx, cy, radius);
		}
	}
}