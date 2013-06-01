// HoughAccumulator Class v1.0
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2010 Mario Klingemann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package com.quasimondo.bitmapdata
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	public class HoughAccumulator extends EventDispatcher
	{
		private var hough:Vector.<uint>;
		private var width:int;
		private var height:int;
		
		private var border:int; 
  		private var inputMap:BitmapData;
		
		  private var  xEnd:int;
		  private var yEnd:int;              /* end of image within borders */
		  private var thetaHt:int; 
		  private var rhoWid:int;         /* width and height of Hough space */
		  private var rhoWidM1:int;                /* rho width minus 1 */
		  private var rho:Number
		  private var theta:Number;            /* radius and angle in Hough space */
		  private var tanTheta:Number;              /* tan of theta angle */
		  private var denom:Number;                 /* denominator */
		  private var rhoNorm:Number;               /* normalization factor for rho */
		  private var max:int;
		  private var xMax:int;
		  private var yMax:int;         /* peak point in Hough space */
		  private var x1:Number;
		  private var y1:Number; 
		  private var rmax:Number;
		  private const TAN_TOO_BIG:Number =  263;
 
 		private static const TIMESLICE:Number     = 1500;
		
		
		// supply a binary bitmap here with black (0xff000000) white (0xffffffff) pixels only
		// for example the result of a Canny edge detection:
		function HoughAccumulator( inputMap:BitmapData ) 
		{
			width  = inputMap.width;
			height = inputMap.height;
			rmax = Math.ceil(Math.sqrt(width*width + height*height));
			
			this.inputMap = inputMap;
		}
		
		public function accumulate( ):void
		{
			var w:Number = width;
			var h:Number = height;
			
			hough = new Vector.<uint>(rmax*360,true);
			
			var r:Number;
			var th_pi:Number = Math.PI / 360;
			var x:Number, y:Number, theta:int;
			var th_r:Number;
			
			var pixels:Vector.<uint> = inputMap.getVector( inputMap.rect );
			var i:int = 0;
			
			for( y=0; y < h; y++ ) 
			{
				for( x =0;x<w;x++) 
				{
					if ( pixels[i++] == 0xffffffff )
					{
						for ( theta = 0, th_r = 0; theta<360; theta++, th_r += th_pi ) 
						{
							r = x * Math.cos(th_r) + y * Math.sin(th_r);
							if ((r > 0) && (r <= rmax)) hough[int(r*360+theta)]++;
						}
					}
				}
			}
		}
			
		public function getLines( amount:int ):Array
		{
		
			var result:Array = new Array();
			if ( amount== 0 || hough == null ) return result;
			
			var idx:int = 0;
			var dr:int, dt:int;
			var MINDIST:int = 8*8;
			var ok:Boolean;
			
			for (var j:int = 0; j < rmax; j++) 
			{
			 	for (var i:int = 0; i < 360; i++) 
			  	{
			    
			     if ( result.length<amount)
			     {
			      		result.push({ max:hough[idx],r:j,t:i});
			      		result.sortOn( "max",Array.NUMERIC );
			      } else if (hough[idx] > result[0].max ) 
			      {
			      	ok = true;
			      	for (var k:int = 0;k<amount && ok;k++)
			      	{
			      		dr = j - result[k].r;
			      		dt = i - result[k].t;
			      		if ( dr*dr+dt*dt < MINDIST ) {
				      		ok = false;
				      		if (result[k].max<hough[idx])
				      		{
				      			 result[k] = { max:hough[idx],r:j,t:i};
				      			 result.sortOn( "max",Array.NUMERIC );
				      		} else if (result[k].max==hough[idx])
				      		{
				      			 result[k].r = 0.5 * ( result[k].r+j);
				      			 result[k].t = 0.5 * ( result[k].t+i);
				      		} 
			      		}
			      	}
			      	if (ok)
			      	{
			      		 result[0] = { max:hough[idx],r:j,t:i};
				      	 result.sortOn( "max",Array.NUMERIC );
				      }
			      }
			      idx++;
			    }
			  }
			  
			  var rho:Number, theta:Number;
			  var x:Number;
			  var y:Number;
			  var ct:Number;
			  var st:Number; 
			 
			  var p1:Point;
			  var p2:Point;
			 var m:Number;
			 var xp:Number;
			 var yp:Number;
			 
			 var lines:Array = new Array();
			  
			  for (i = 0;i<amount;i++)
			  {
			  	 rho = result[i].r; // / rhoNorm;
			  	 //theta =  Math.PI + result[i].t * Math.PI / Number(thetaHt);
			  	 theta = result[i].t * Math.PI / 360;
			  	 st = Math.cos(theta);
			  	 ct = Math.sin(theta);
			  	
			  	/*
			  	 m = Math.tan(theta+Math.PI/2);
			  	 xp =  rho * Math.cos(theta);
			  	 yp =  rho * Math.sin(theta);
			  	 */
			  	 
				 p1 = null;
				 p2 = null;
			  	
			  	 
			  	 //y = - xp * m  + yp;
			  	 if (ct!=0)
			  	 {
			  	 	y = rho / ct;
			  	 	if ( y >=0 && y<= height)
			  		{
			  	 		p1 = new Point( 0, y );
			  		}
			  		y = ( rho -  width * st) / ct;
			  		if ( y >=0 && y<= height)
			  		 {
			  	 		p2 = new Point( width, y );
			  		 }
			  	 }
			  	 	
			  	 
			  	 //y = m * (width - xp) + yp
			  	 //m!=0 && 
			  	 
			  	 if ((st!=0) && (p1==null || p2==null))
			  	 {
			  	 	x = rho / st
			  	 	//x =  - yp  / m + xp 
			  	 	if ( x >=0 && x<= width)
			  	 	{
			  	 		if (p1==null)
			  	 		{
			  	 			p1 = new Point( x, 0 );
			  	 		} else {
			  	 			p2 = new Point( x, 0 );
			  	 		}
			  	 	}
			  	 	
			  	 	if (p1==null||p2==null)
			  	 	{
			  	 		//x =  ( height - yp ) / m + xp 
			  	 		x= ( rho - height * ct ) / st
			  	 		if ( x >=0 && x<= width)
			  	 		{
				  	 		if (p1==null)
				  	 		{
				  	 			p1 = new Point( x, height );
				  	 		} else {
				  	 			p2 = new Point( x, height );
				  	 		}
				  	 	}
			  	 	}
			  	 }
			  	if (p1!=null&&p2!=null)
			  	 {
			  		 lines.push({p1:p1,p2:p2});
			  	 }
			  }
			  return lines;
		}
		
	}
}
