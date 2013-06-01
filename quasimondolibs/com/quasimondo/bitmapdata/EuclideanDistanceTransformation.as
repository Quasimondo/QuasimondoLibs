/*
* =============================================================================
*
* LOTUFO ZAMPIROLLI'S EXACT EDT 
*
* Euclidean Distance Transformation
* ported to ActionScript by Mario Klingemann <mario@quasimondo.com>
* 
* based on original C code from
* ANIMAL - ANIMAL IMage Processing LibrarY
* Copyright (C) 2002,2003  Ricardo Fabbri <rfabbri@if.sc.usp.br>
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* =============================================================================
*/ 

package com.quasimondo.bitmapdata
{
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class EuclideanDistanceTransformation
	{
		private var width:int;
		private var height:int;
		private var data:Vector.<uint>;
		
		[Embed(source="pb/triangulator.pbj", mimeType="application/octet-stream")]
		private var ShaderCode:Class;
		
		private var shader:Shader = new Shader( new ShaderCode() as ByteArray );
		private var indexFilter:ShaderFilter = new ShaderFilter( shader );
		private var origin:Point = new Point();
		
		
		public function EuclideanDistanceTransformation()
		{
		}
		
		public function getIndexMap( bitmapData:BitmapData, invert:Boolean = false, useAlphaChannel:Boolean = false ):void
		{
			apply( bitmapData, true, false, invert, useAlphaChannel );
			shader.data.width.value = [ bitmapData.width];
			bitmapData.applyFilter(  bitmapData,bitmapData.rect,origin, indexFilter );
		}
		
		public function apply( bitmapData:BitmapData, squaredDistance:Boolean = false, negative:Boolean = false, invert:Boolean = false, useAlphaChannel:Boolean = false ):void
		{
			bitmapData.lock();
			
			width = bitmapData.width;
			height = bitmapData.height;
			var rect:Rectangle = bitmapData.rect;
			
			data = bitmapData.getVector( rect );
			if ( useAlphaChannel )
			{
				for ( var i:int = data.length; --i > -1;)
				{
					data[i] = ((data[i] & 0xff000000) == 0) == invert ? 0xffffff : 0;
				}
			} else {
				for ( i = data.length; --i > -1;)
				{
					data[i] = ((data[i] & 0xffffff) == 0) == invert ? 0xffffff : 0;
				}
			}
			verticalDistance();
			meijster();
			
			if ( negative )
			{
				var data2:Vector.<uint> = data.concat();
				
				data = bitmapData.getVector( rect );
				if ( useAlphaChannel )
				{
					for ( i = data.length; --i > -1;)
					{
						data[i] = ((data[i] & 0xff000000) == 0) != invert ? 0xffffff : 0;
					}
				} else {
					for ( i = data.length; --i > -1;)
					{
						data[i] = ((data[i] & 0xffffff) == 0) != invert ? 0xffffff : 0;
					}
				}
				
				verticalDistance();
				//horizontalDistance();
				meijster();
				
				if ( !squaredDistance )
				{
					for ( i = data.length; --i > -1;)
					{
						data[i] = 0xff000000 | ( 0x7fffff +  uint( 0.5 + ( data[i] == 0 ? -Math.sqrt(data2[i]) : Math.sqrt(data[i]) )));
					}
				} else {
					for ( i = data.length; --i > -1;)
					{
						data[i] = 0xff000000  | uint( 0x7fffff + data2[i] - data[i]);
					}
				}
			} else {
				if ( !squaredDistance )
				{
					for ( i = data.length; --i > -1;)
					{
						data[i] = 0xff000000 | uint( 0.5 + Math.sqrt( data[i])) ;
					}
				} else {
					for ( i = data.length; --i > -1;)
					{
						data[i] |= 0xff000000;
					}
				}
			}
			bitmapData.setVector( rect, data );
			bitmapData.unlock();
			data.length = 0;
		}
		
		
		private function verticalDistance():void
		{
			var b:uint;
			var d:uint;
			 
			for (var c:int=0; c < width; c++) 
			{
				b=1;
				for ( var r:int=1; r<height; r++)
					if ( data[uint(r*width+c)] > ( d = data[uint((r-1)*width+c)] + b ) ) 
					{
						data[uint(r*width+c)] = d;
						b += 2;
					} else
						b = 1;
				b=1;
				for (r=height-2; r >= 0; r--) 
				{
					if (data[uint(r*width+c)]  > ( d =data[uint((r+1)*width+c)] + b )) 
					{
						data[uint(r*width+c)] = d;
						b += 2;
					} else
						b = 1;
				}
			}
		}
		
		
		private function horizontalDistance():void
		{
			var Wq_ini:uint; 
			var Wq_end:uint;  
			var Eq_ini:uint;  
			var Eq_end:uint;
			var Wq2_end:uint;
			var Eq2_end:uint;
			
			var r:uint;
			var c:uint;
			var b:uint;
			var d:uint;
			var index:uint = 0;
			
			var Eq:Vector.<uint> = new Vector.<uint>(width,true);
			var Eq2:Vector.<uint> = new Vector.<uint>(width,true);
			var Wq:Vector.<uint> = new Vector.<uint>(width,true);
			var Wq2:Vector.<uint> = new Vector.<uint>(width,true);
			var tmp_q:Vector.<uint>;
			
			for (r=0; r<height; r++) 
			{
				for (c=0; c < width-1; ++c) 
				{
					Wq[c] = c+1;
					Eq[c] = width-2-c;
				}
				Wq_end = Eq_end = width - 1;
				Wq_ini = Eq_ini = 0;
				
				
				b = 1;
				/* while a queue is not empty */
				while (Wq_end > Wq_ini || Eq_end > Eq_ini) 
				{ 
					Eq2_end = Wq2_end = 0;
					while (Eq_end > Eq_ini) 
					{
						c = Eq[Eq_ini++];  /* remove from queue */
						if (data[uint(index+c+1)] > ( d = data[uint(index+c)] + b )) 
						{
							data[uint(index+c+1)] = d;
							if (c+1 < width-1)
								Eq2[Eq2_end++] = c+1;  /* insert into queue */
						}
					}
					
					while (Wq_end > Wq_ini) 
					{
						c = Wq[Wq_ini++];  /* remove from queue */
						if (data[uint(index+c-1)] > ( d = data[uint(index+c)] + b ) ) 
						{
							data[uint(index+c-1)] = d;
							if (c-1 > 0)
								Wq2[Wq2_end++] = c-1;  /* insert into queue */
						}
					}
					
					tmp_q  = Wq; Wq = Wq2; Wq2 = tmp_q;
					tmp_q  = Eq; Eq = Eq2; Eq2 = tmp_q;
					Wq_end = Wq2_end; Eq_end = Eq2_end;
					Wq_ini = Eq_ini = 0;
					b += 2;
				}
				index += width;
			}
		}
		
		private function meijster():void
		{
			var end:int = -1;
			var q:int, w:int;
			var s:Vector.<int> = new Vector.<int>( width, true);
			var t:Vector.<int> = new Vector.<int>( width, true);
			var row_copy:Vector.<uint>;
			var h:int;
			var j:int;
			var r:int;
			var u:int;
			var im_r_u:int;
			var index:int = 0;
			for (r=0; r<height; r++,index += width) 
			{
				q = s[0] = t[0] = 0;
				for (u = 1; u < width; ++u) 
				{
					im_r_u = data[int(index+u)];
					while (q != end 
						&& ( (h =t[q]-(j=s[q]))*h+data[int(index+j)]) >
						((h=t[q]-u)*h+im_r_u) 
					) --q;
					
					if (q == end) 
					{
						q = 0; 
						s[0] = u;
					} else {
						w = 1 + ( (u*u - ((j=s[q])*j) + data[int(index+u)] - data[int(index+j)]) / (2*(u - j)) );
						if (w < width) 
						{
							++q;
							s[q] = u;
							t[q] = w;
						}
					}
				}
				
				row_copy = data.slice(index,index+width);
				
				for (u = width-1; u != end; --u) 
				{
					data[int(index+u)] =((h=u-(j=s[q]))*h+row_copy[j]);
					if (u == t[q])
						--q;
				}
			}
		}
	}
}