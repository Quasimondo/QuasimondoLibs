package com.quasimondo.bitmapdata
{
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.BlurFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class RadialBlur
	{
		private static const origin:Point = new Point();
		private static const blur:BlurFilter = new BlurFilter(0,0,2);
		private static const copyPoint:Point = new Point();
		
		[Embed(source="pb/cartesiantopolar.pbj", mimeType="application/octet-stream")]
		private static const C2P:Class;
		
		[Embed(source="pb/polartocartesian.pbj", mimeType="application/octet-stream")]
		private static const P2C:Class;
		
		private static const c2p_shader:Shader = new Shader( new C2P() as ByteArray );
		private static const c2p_Filter:ShaderFilter = new ShaderFilter(c2p_shader);
		
		private static const p2c_shader:Shader = new Shader( new P2C() as ByteArray );
		private static const p2c_Filter:ShaderFilter = new ShaderFilter(p2c_shader);
		
		public function RadialBlur( )
		{
		}
		
		public static function render( map:BitmapData, blurRadius:Number, center:Point, radial:Boolean = true, quality:Number = 1, borderColor:uint = 0x00000000, clampBorder:Boolean = false ):void
		{
			if ( radial )
			{
				blur.blurX = blurRadius * quality;
				blur.blurY = 0;
			} else {
				blur.blurY = blurRadius * quality;
				blur.blurX = 0;
			}
			
			var map2:BitmapData = new BitmapData( blurRadius + quality * ( map.width + Math.abs( center.x - map.width * 0.5 ) * 2 ), blurRadius + quality * ( map.height + Math.abs( center.y - map.height * 0.5 ) * 2 ), true,borderColor);
			var rect:Rectangle = map2.rect;
			var copyRect:Rectangle = map.rect;
			
			copyRect.x = copyPoint.x = map2.width  * 0.5 - ((center.x - map.width * 0.5 ) + map.width * 0.5) * quality;
			copyRect.y = copyPoint.y = map2.height * 0.5 - ((center.y - map.height * 0.5 ) + map.height * 0.5) * quality;
			
			if ( quality == 1 )
			{
				map2.copyPixels( map, map.rect, copyPoint );
			} else {
				var copyMatrix:Matrix = new Matrix( quality,0,0,quality, copyPoint.x, copyPoint.y);
				map2.draw( map, copyMatrix, null,"normal",null, true );
			}
			
			if ( clampBorder )
			{
				var copyMap:BitmapData = new BitmapData( map.width * quality, 1, true, 0 );
				
				copyMap.copyPixels( map2, new Rectangle( copyRect.x, copyRect.y, quality * copyMap.width, 1 ), origin );
				map2.draw( copyMap, new Matrix( 1,0,0,copyRect.y,copyRect.x,0));
				
				copyMap.copyPixels( map2, new Rectangle( copyRect.x, copyRect.y + quality * copyRect.height -1 , copyMap.width, 1 ), origin );
				map2.draw( copyMap, new Matrix( 1,0,0,map2.height - ( copyRect.y+ quality * copyRect.height ),copyRect.x,copyRect.y+ quality * copyRect.height));
				
				copyMap.dispose();
				
				copyMap = new BitmapData( 1,map2.height, true, 0 );
				copyMap.copyPixels( map2, new Rectangle( copyRect.x , 0, 1, map2.height ), origin );
				map2.draw( copyMap, new Matrix( copyRect.x,0,0,1,0,0));
				
				copyMap.copyPixels( map2, new Rectangle( copyRect.x+ quality * copyRect.width - 1, 0, 1, map2.height ), origin );
				map2.draw( copyMap, new Matrix(map2.width - (copyRect.x+ quality * copyRect.width),0,0,1,copyRect.x+ quality * copyRect.width,0));
				
			}
			
			
			
			c2p_shader.data.dimensions.value = [rect.width, rect.height ];
			c2p_shader.data.angleFactor.value = [radial ? 1 + blurRadius / 100 : 1.01 ];
			
			p2c_shader.data.dimensions.value = [rect.width, rect.height ];
			p2c_shader.data.angleFactor.value = [ radial ? 1 + blurRadius / 100 : 1.01 ];
			
			map2.applyFilter( map2, rect, origin, c2p_Filter );
			map2.applyFilter( map2, rect, origin, blur );
			map2.applyFilter( map2, rect, origin, p2c_Filter );
			
			if ( quality == 1 )
			{
				map.copyPixels( map2, copyRect, origin );
			} else {
				map.fillRect( map.rect, 0 );
				copyMatrix.a = copyMatrix.d = 1 / quality;
				copyMatrix.tx = -copyPoint.x * copyMatrix.a;
				copyMatrix.ty = -copyPoint.y * copyMatrix.d;
				map.draw( map2, copyMatrix, null,"normal",null, true );
			}
		}
	}
}