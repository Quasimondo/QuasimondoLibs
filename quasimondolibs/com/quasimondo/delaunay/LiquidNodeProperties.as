package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class LiquidNodeProperties extends DelaunayNodeProperties
	{
		public var fixed:Boolean = false;
		public var stuck:Boolean = false;
		public var marker1:int = -1;
		public var remove:Boolean = false;
		
		public var radius:Number = 0;
		public var xTarget:Number;
		public var yTarget:Number;
		public var xSpeed:Number = 0;
		public var ySpeed:Number = 0;
		public var accelleration:Number = 0.001;
		
		private var maxSpeed:Number = 0.5;
		private var maxSpeedSquared:Number = maxSpeed*maxSpeed;
		
		public var clip:Sprite;
		
		public var left:Number;
		public var top:Number;
		
		public var width:Number;
		public var height:Number;
		
		public var color:int = 0xffffff;
		
		public var container:Sprite;
		public var mouseAttraction:Number = 0.01;
		public var selectedRadius:Number = 0;
		public var currentRadius:Number = 0;
		public var type:String;
		
		private static var p:Point = new Point();
		private static var m:Matrix = new Matrix();
		private static var __flowAngle:Number = 0;
		
		private static const NEW_START_FACTOR:Number = 2.0;
		private var dx:Number;
		private var dy:Number;
		private var speed:Number;
		private var dx2:Number;
		private var dy2:Number;
		private var a:Number;
		private var r:Number;
		
		
		private static const STICK_FACTOR:Number = 0.1;
			
		public var stickyness:Number = 1;
		
		private var offset_x:Number = 0;
		private var offset_y:Number = 0;
		private var absolute_offset_x:Number = 0;
		private var absolute_offset_y:Number = 0;
		
		
		
		public function LiquidNodeProperties():void
 		{
    	}
    	
    	public function setRadius( r:Number ):void
    	{
    		currentRadius = radius = r;
    	}
    	
    	public function setViewport( left:Number, top:Number, width:Number, height:Number ):void
    	{
    		this.left = left;
    		this.top = top;
    		this.width = width;
    		this.height = height;
    	}
    	
    	public function move():void
		{
			var d:Number;
			/*
			if (stuck)
			{
				xSpeed *= 0.9;
				ySpeed *= 0.9;
				node.x = (1-mouseAttraction) * node.x + mouseAttraction * container.mouseX;
				node.y = (1-mouseAttraction) * node.y + mouseAttraction *  container.mouseY;
				
				currentRadius = 0.98 * currentRadius + 0.02 * selectedRadius;
			} else {
				*/
				
				dx = node.x - (left + width * 0.5 );
				dy = node.y - (top + height * 0.5 );
				d = Math.atan2( dy,dx ) + Math.PI * 0.49;
				
				xSpeed += 0.01 *  Math.cos( d );
				ySpeed += 0.01 *  Math.sin( d );
				
				d = Math.sqrt( xSpeed*xSpeed+ySpeed*ySpeed);
				if ( d > 3 )
				{
					xSpeed = xSpeed / d * 3;
					ySpeed = ySpeed / d * 3;
					
				}
				
				node.x +=  xSpeed;
				node.y +=  ySpeed;
			
				
				
				/*
				xSpeed *= 0.99;
				ySpeed *= 0.99;
				*/
				
				//currentRadius = 0.98 * currentRadius + 0.02 * radius;
				
		   		if ( xSpeed < 0 && node.x + currentRadius < left  ) 
				{
					node.x += left + width + 2 * currentRadius;
				}
				
				if ( xSpeed > 0 && node.x - currentRadius > left + width  ) 
				{
					node.x -= left + width + 2 * currentRadius;
				}
				
				if ( ySpeed < 0 && node.y + currentRadius < top  ) 
				{
					node.y += top + height + 2 * currentRadius;
				}
				
				if ( ySpeed > 0 && node.y - currentRadius > top + height  ) 
				{
					node.y -= top + height + 2 * currentRadius;
				}
				
   			//}
   		}

		override public function updateView():void
  	    {
	  		clip.x = node.x;
			clip.y = node.y;
			clip.width = 2 * currentRadius;
      		clip.scaleY = clip.scaleX;
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
			
			g.beginFill( 0xffffff );
			g.drawCircle( node.x,node.y,currentRadius);
			g.endFill();
			
		}
		
		override public function solve( otherNodeProperties:DelaunayNodeProperties, marker:int ):Boolean
		{
			
			var nodeProperties:LiquidNodeProperties = LiquidNodeProperties( otherNodeProperties );
			
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
					node.x = left - currentRadius + Math.random() * ( width + currentRadius );		
		      		node.y = top - currentRadius + Math.random() * ( height + currentRadius );		
      				break;
      			
      			case "stickyness":
      				return;
					// update stickyness
					var o1:Number = offset_x * offset_x + offset_y * offset_y;
					var o2:Number = absolute_offset_x * absolute_offset_x + absolute_offset_y * absolute_offset_y;
					
					var factor:Number;
					if (o2 != 0 )
					{
						factor = o1 / o2;
						if ( factor < STICK_FACTOR )
						{
							stickyness *= 0.95;
						} else {
							stickyness = 0.05 + stickyness * 0.95
						}
					} else if ( o2 != o1 )
					{
						stickyness *= 0.95;
					} else {
						stickyness = 0.05 + stickyness * 0.95
					}
					
					offset_x = offset_y = absolute_offset_x = absolute_offset_y = 0;
					break;
			}
		}
		
		override public function clone( replaceNode:Boolean = true, newNode:DelaunayNode = null ):DelaunayNodeProperties
		{
			throw new Error("sorry, but the clone function still needs to be implemented");
		}
	}
}