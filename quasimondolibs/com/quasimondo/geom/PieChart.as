package com.quasimondo.geom
{
	import flash.display.Graphics;

	public class PieChart 
	{
		public function PieChart()
		{
			super();
		}
		
		static public function draw( weights:Vector.<Number>, colors:Vector.<uint>, center:Vector2, radius:Number, startAngle:Number, canvas:Graphics ):void
		{
			
			var total:Number = 0;
			for ( var i:int = 0; i < weights.length; i++ )
			{
				total += weights[i];
			}
			
			var angles:Vector.<Number> = new Vector.<Number>();
			var angle:Number = startAngle;
			angles.push( angle );
			for ( i = 0; i < weights.length; i++ )
			{
				angle += weights[i] / total * 2 * Math.PI;
				angles.push( angle );
			}
			
			for ( i = 0; i < weights.length; i++ )
			{
				var arc:Arc = new Arc( center, radius, angles[i], angles[i+1] );
				canvas.beginFill(colors[i]);
				arc.draw(canvas);
				canvas.lineTo(center.x,center.y);
				canvas.endFill();
			}
			
			
		}
	}
}