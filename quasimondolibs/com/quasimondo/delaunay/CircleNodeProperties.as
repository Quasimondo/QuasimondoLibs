package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class CircleNodeProperties extends DelaunayNodeProperties
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
		public var w:Number;
		public var h:Number;
		public var viewRadius:Number;
		public var viewCenterX:Number = 0;
		public var viewCenterY:Number = 0;
		
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
		
		
		
		public function CircleNodeProperties():void
 		{
    	}
    	
    	public static function set flowAngle( a:Number ):void
    	{
    		m.identity();
    		m.rotate(a);
    		__flowAngle = a;
    	}
    	
    	public static function get flowAngle( ):Number
    	{
			return __flowAngle;
    	}
    	
    	public function setRadius( r:Number ):void
    	{
    		currentRadius = radius = r;
    	}
    	
    	public function move():void
		{
			if (stuck)
			{
				xSpeed *= 0.9;
				ySpeed *= 0.9;
				node.x = (1-mouseAttraction) * node.x + mouseAttraction * container.mouseX;
				node.y = (1-mouseAttraction) * node.y + mouseAttraction *  container.mouseY;
				
				currentRadius = 0.98 * currentRadius + 0.02 * selectedRadius;
			} else {
				if ( fixed ) {
					xSpeed *= 0.5;
					ySpeed *= 0.5;
				}	
			
				node.x -=  xSpeed;
				node.y -=  ySpeed;
			
				dx = node.x - xTarget;
				dy = node.y - yTarget;
				
				currentRadius = 0.98 * currentRadius + 0.02 * radius;
				if ( !fixed ) {
					xSpeed += accelleration * ( dx / currentRadius) * stickyness;
					ySpeed += accelleration * ( dy / currentRadius) * stickyness;
					speed =  xSpeed * xSpeed + ySpeed * ySpeed ;
					if (speed > maxSpeedSquared)
					{
						speed = Math.sqrt(speed);
						xSpeed = xSpeed / speed * maxSpeed;
						ySpeed = ySpeed / speed * maxSpeed;
					} 
				}
					
				
		   		dx2 = viewCenterX - ( node.x - viewRadius - currentRadius );
				dy2 = viewCenterY - ( node.y - viewRadius - currentRadius );
				r = viewRadius * viewRadius
		   	
		   		if ( dx*dx+dy*dy < r && dx2*dx2+dy2*dy2 > r  ) 
				{
					update("setNewTarget");
					update("setNewStart");
				}
				
   			}
			
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
			
			if ( !fixed )
			{
				if (colorMap !=  null )
				{ 
					var c:int = colorMap.getPixel( node.x, node.y );
					var r1:int = (c >> 16 ) & 0xff;
					var g1:int = (c >> 8  ) & 0xff;
					var b1:int =  c         & 0xff;
					var r2:int = (color >> 16 ) & 0xff;
					var g2:int = (color >> 8  ) & 0xff;
					var b2:int =  color         & 0xff;
					
					color = int(0.95 * r2 + 0.05 * r1)<<16 | int(0.95 * g2 + 0.05 * g1)<<8 | int(0.95 * b2 + 0.05 * b1);
				}
				
				g.beginFill( color );
				g.drawCircle( node.x,node.y,currentRadius);
				g.endFill();
			}
		}
		
		override public function solve( otherNodeProperties:DelaunayNodeProperties, marker:int ):Boolean
		{
			
			var nodeProperties:CircleNodeProperties = CircleNodeProperties( otherNodeProperties );
			
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
					p.x = NEW_START_FACTOR * viewRadius + Math.random()*5;
		      		p.y = Math.random() * viewRadius * 2 - viewRadius;
		      		p = m.transformPoint(p);
		      		node.x = viewCenterX + p.x;		
		      		node.y = viewCenterY + p.y;
      				break;
      			
      			case "setNewTarget":
					p.x =  - 2* viewRadius -currentRadius;
		      		p.y =  Math.random()*2*viewRadius - viewRadius;
		      		p = m.transformPoint(p);
		      		xTarget = viewCenterX+ p.x;
		      		yTarget = viewCenterY+ p.y;
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