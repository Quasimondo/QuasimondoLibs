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

	public class EDTFastMax
	{
		private var width:int;
		private var height:int;
		private var data:Vector.<uint>;
		
		private var origin:Point = new Point();
		
		[Embed(source="pb/skeleton2.pbj", mimeType="application/octet-stream")]
		private var ShaderCode:Class;
		
		private var shader:Shader = new Shader( new ShaderCode() as ByteArray );
		private var skeletonFilter:ShaderFilter = new ShaderFilter( shader );
		
		public function EDTFastMax()
		{
		}
		
		
		
		public function apply( bitmapData:BitmapData ):Vector.<uint>
		{
			width = bitmapData.width;
			height = bitmapData.height;
			data = bitmapData.getVector( bitmapData.rect );
			for (var i:int = data.length; --i > -1;)
			{
				data[i] &= 0xffffff;
			}
			verticalDistance();
			meijster();
			
			return data;
		}
		
		public function getSkeleton( squaredDistances:Vector.<uint> ):BitmapData
		{
			var data2:Vector.<uint> = squaredDistances.concat();
			for (var i:int = data.length; --i > -1;)
			{
				data2[i] |= 0xff000000;
			}
			var map:BitmapData = new BitmapData( width, height, false, 0 );
			map.setVector( new Rectangle(0,0,width,height), data2 );
			map.applyFilter( map, map.rect, origin, skeletonFilter );
			return map;
		}
		
		private function verticalDistance():void
		{
			var b:uint;
			var d:uint;
			var ld:Vector.<uint> = data;
			var w:int = width;
			var h:int = height;
			for (var c:int=0; c < w; c++) 
			{
				b=1;
				for ( var r:int=1; r<h; r++)
					if ( ld[uint(r*w+c)] > ( d = ld[uint((r-1)*w+c)] + b ) ) 
					{
						ld[uint(r*w+c)] = d;
						b += 2;
					} else
						b = 1;
				b=1;
				for (r=h-2; r >= 0; r--) 
				{
					if (ld[uint(r*w+c)]  > ( d = ld[uint((r+1)*w+c)] + b )) 
					{
						ld[uint(r*w+c)] = d;
						b += 2;
					} else
						b = 1;
				}
			}
		}
		
		private function meijster():void
		{
			var ld:Vector.<uint> = data;
			var wd:int = width;
			var ht:int = height;
			
			var end:int = -1;
			var q:int, w:int;
			var s:Vector.<int> = new Vector.<int>( wd, true);
			var t:Vector.<int> = new Vector.<int>( wd, true);
			var row_copy:Vector.<uint>;
			var h:int;
			var j:int;
			var r:int;
			var u:int;
			var im_r_u:int;
			var index:int = 0;
			for (r=0; r< ht; r++,index += wd) 
			{
				q = s[0] = t[0] = 0;
				for (u = 1; u < wd; ++u) 
				{
					im_r_u = ld[int(index+u)];
					while (q != end 
						&& ( (h =t[q]-(j=s[q]))*h+ld[int(index+j)]) >
						((h=t[q]-u)*h+im_r_u) 
					) --q;
					
					if (q == end) 
					{
						q = 0; 
						s[0] = u;
					} else {
						w = 1 + ( (u*u - ((j=s[q])*j) + ld[int(index+u)] - ld[int(index+j)]) / (2*(u - j)) );
						if (w < wd) 
						{
							++q;
							s[q] = u;
							t[q] = w;
						}
					}
				}
				
				row_copy = ld.slice(index,index+wd);
				
				for (u = wd-1; u != end; --u) 
				{
					ld[int(index+u)] =((h=u-(j=s[q]))*h+row_copy[j]);
					if (u == t[q])
						--q;
				}
			}
		}
	}
}