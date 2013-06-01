package
{
	import com.adobe.images.PNGEncoder;
	import com.bit101.components.CheckBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import com.quasimondo.BitmapData.CameraBitmap;
	import com.quasimondo.display.InteractiveSprite;
	import com.quasimondo.filters.FreiChenEdges;
	import com.quasimondo.utils.BitmapDataUtils;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	
	public class FreiChenDemo extends InteractiveSprite
	{
		private var cameraMap:CameraBitmap;
		private var freiChen:FreiChenEdges;
		private var rect:Rectangle;
		private var origin:Point;
		
		private var threshold_slider:HUISlider;
		private var factor_slider:HUISlider;
		private var invert_chk:CheckBox;
		private var snapshot:PushButton;
		
		private var cm:ColorMatrixFilter;
		
		public function FreiChenDemo()
		{
			super();
		}
		
		override public function init():void
		{
			cameraMap = new CameraBitmap(640,480,25);
			cameraMap.addEventListener( Event.RENDER, update );
			rect = cameraMap.bitmapData.rect;
			origin = new Point();
			
			addChild( new Bitmap( cameraMap.bitmapData ) );
			
			threshold_slider = new HUISlider(this,10,485,"Threshold" );
			threshold_slider.minimum = 0;
			threshold_slider.maximum = 255;
			threshold_slider.value = 0;
			
			factor_slider = new HUISlider(this,threshold_slider.x + threshold_slider.width,485,"Strength" );
			factor_slider.minimum = 0;
			factor_slider.maximum = 100;
			factor_slider.value = 10;
			
			invert_chk = new CheckBox( this, factor_slider.x + factor_slider.width , 490,"Invert");
			
			snapshot = new PushButton( this, 640 - 80,485,"Snapshot", onSnapshot );
			snapshot.width = 80;
			
			cm = new ColorMatrixFilter([-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0]);
			
			
			freiChen = new FreiChenEdges();
			
		}
		
		private function update( event:Event ):void
		{
			freiChen.threshold = threshold_slider.value / 255;
			freiChen.strength = factor_slider.value / 10;
			
			cameraMap.bitmapData.applyFilter( cameraMap.bitmapData, rect, origin, freiChen );
			if ( invert_chk.selected )
			{
				cameraMap.bitmapData.applyFilter( cameraMap.bitmapData, rect, origin, cm );
			}
		}
		
		private function onSnapshot( event:Event ):void
		{
			var fr:FileReference = new FileReference();
			fr.save( PNGEncoder.encode( cameraMap.bitmapData ), "snapshot.png" );
			
		}
	}
}