package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class StippleNodeProperties extends DelaunayNodeProperties
	{
		public var fixed:Boolean = false;
		public var stuck:Boolean = false;
		public var marker1:int = -1;
		public var remove:Boolean = false;
		
		private var maxSpeed:Number = 0.5;
		private var maxSpeedSquared:Number = maxSpeed*maxSpeed;
		
		public var clip:Sprite;
		public var w:Number;
		public var h:Number;
		
		public var stippleMap:BitmapData;
		
		public var color:int = 0xffffff;
		
		public var currentRadius:Number = 0;
		public var minRadius:Number = 1;
		public var maxRadius:Number = 25;
		
		
		public var type:String;
		
		private static var p:Point = new Point();
		private static var m:Matrix = new Matrix();
		
		
		private var dx:Number;
		private var dy:Number;
		private var speed:Number;
		private var dx2:Number;
		private var dy2:Number;
		private var a:Number;
		private var r:Number;
		
		
		private var offset_x:Number = 0;
		private var offset_y:Number = 0;
		private var absolute_offset_x:Number = 0;
		private var absolute_offset_y:Number = 0;
		
		
		
		public function StippleNodeProperties():void
 		{
    	}
    	
    	
    	public function setRadius( r:Number ):void
    	{
    		currentRadius  = r;
    	}
    	
    	override public function offset( dx:Number, dy:Number ):void
		{
			node.x += dx;
			node.y += dy;
			
			offset_x += dx;
			offset_y += dy;
			
			absolute_offset_x += dx > 0 ? dx : -dx;
			absolute_offset_y += dy > 0 ? dy : -dy;
				
			
		}
		
		override public function draw( g:Graphics, colorMap:BitmapData = null ):void
		{
			g.lineStyle();
			g.beginFill( color );
			g.drawRect( Math.round(node.x),Math.round(node.y),1,1);
			g.endFill();
			
		}
		
		override public function solve( otherNodeProperties:DelaunayNodeProperties, marker:int ):Boolean
		{
			
			var nodeProperties:StippleNodeProperties = StippleNodeProperties( otherNodeProperties );
			
			var dx:Number = nodeProperties.node.x - node.x;
	      	var dy:Number = nodeProperties.node.y - node.y;
	      	var rr:Number = dx*dx + dy*dy;
	      	var d:Number = nodeProperties.currentRadius +  currentRadius
	      	var dd:Number = d * d;
	      	
	      	if ( rr < dd )
	      	{
	      		rr = Math.sqrt(rr);
	        	dd = (Math.sqrt(dd) - rr) / rr;
	        	dx *= dd;
	        	dy *= dd;
	        	
	        	if (( fixed || stuck || ( marker1 == marker && nodeProperties.marker1 != marker && !nodeProperties.stuck)) && !nodeProperties.fixed )
	        	{
	        		nodeProperties.offset( dx, dy );
	          		nodeProperties.marker1 = marker;
	          	} else if ((nodeProperties.fixed || nodeProperties.stuck || ( nodeProperties.marker1 == marker && marker1 != marker  && !stuck)) && !fixed)
	        	{
	        		offset( -dx, -dy );
	          		marker1 = marker;
	        	} else {
	        		d = nodeProperties.currentRadius / d;
	        		offset( -dx * d, -dy * d );
	        		nodeProperties.offset( dx * (1-d), dy * (1-d) );
	        	}
	        	return true;
      		} 
      		
      		return false;
		}
		
		override public function update( mode:String ):void
		{
			switch ( mode )
			{
				case "setNewStart":
					
		      		node.x = 1;		
		      		node.y = 1;
      				break;
      			
      			case "stipple":
      				if ( node.x < 0 || node.x > stippleMap.width || node.y < 0 || node.y > stippleMap.height )
      				{
      					node.x = Math.random() * stippleMap.width;
      					node.y = Math.random() * stippleMap.height;
      				}
      				
      				var p:int = stippleMap.getPixel( node.x, node.y );
      				currentRadius = minRadius + ( maxRadius - minRadius) * ((( (p >> 16 ) & 0xff ) * 212 + ((p >> 8 )&0xff) * 715 + (p & 0xff) * 72)) / 256000; 
      				
      			break;
      		}
		}
		
		override public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			throw ( new Error("sorry but clone has to be implemented yet"));
		}
	}
}