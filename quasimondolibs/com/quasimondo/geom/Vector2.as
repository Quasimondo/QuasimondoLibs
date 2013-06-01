/*
2d Vector Class

based on javascript code by Kevin Lindsey
http://www.kevlindev.com/

ported, optimized and augmented for Actionscript by Mario Klingemann
*/
package com.quasimondo.geom
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Vector2
	{
		public var x:Number;
		public var y:Number;
		
		//-- CONSTRUCTOR
		//
		
		static public function fromAngle( angle:Number, length:Number ):Vector2
		{
			return new Vector2( Math.cos( angle ) * length, Math.sin( angle ) * length );
		}
		
		public function Vector2( value1:* = null, value2:* = null )
		{
			setValue( value1, value2 );
		}
		
		public function setValue( value1:* = null, value2:* = null ):Vector2
		{
			if ( !isNaN(value1) && !isNaN(value2) )
			{
				x = Number(value1);
				y = Number(value2);
				if ( x == Infinity || y == Infinity )
				{
					throw new Error( "Infinity: "+value1+" / "+value2);
				}
			} else if ( value1 == null && value2 == null  )
			{
				x = y = 0;
			} else if ( value1 is Vector2 && value2 == null )
			{
				x = Vector2(value1).x
				y = Vector2(value1).y;
			} else  if ( value1 is Vector2 && value2 is Vector2 )
			{
				x = Vector2(value2).x - Vector2(value1).x;
				y = Vector2(value2).y - Vector2(value1).y;
			} else if ( value1 is DisplayObject && value2 == null )
			{
				x = DisplayObject(value1).x;
				y = DisplayObject(value1).y;
			} else if ( value1 is Point && value2 == null )
			{
				x = Point(value1).x;
				y = Point(value1).y;
			} else {
				throw new Error( "Vector2 unsupported constructor set: "+value1+" / "+value2);
			}
			
			if ( isNaN( x ) || isNaN( y )) throw new Error( "WARNING: Vector2 isNaN!");
			
			return this;
		}
		
		
		public function get length():Number
		{
			return Math.sqrt( x * x + y * y );
		}
		
		public function get length_squared():Number
		{
			return x * x + y * y;
		}
		
		public function get angle( ): Number
		{
			return Math.atan2( y , x );
		}
		
		public function angleTo( v:Vector2 ):Number
		{
			return Math.atan2( v.y - y, v.x - x );
		};
		
		public function dot( v:Vector2 ): Number
		{
			return x * v.x + y * v.y;
		}
		
		public function cross( v: Vector2 ): Number
		{
			return x * v.y - y * v.x;
		}
			
		public function angleBetween( v:Vector2 ): Number
		{
			return Math.acos ( dot( v ) / ( length * v.length ) );
		}
		
		public function cornerAngle( v1:Vector2, v2:Vector2 ): Number
		{
			return v1.getMinus(this).angleBetween( v2.getMinus(this) );
		}
		
		public function reset( ):Vector2
		{
			x = y = 0;
			return this;
		}
		
		public function reflect( normal: Vector2 ): Vector2
		{
			var dp: Number = 2 * dot( normal );
			
			x -= normal.x * dp;
			y -= normal.y * dp;
			
			return this;
		}
		
		public function getReflect( normal: Vector2 ): Vector2
		{
			var dp: Number = 2 * dot( normal );
			
			return new Vector2( x - normal.x * dp, y - normal.y * dp );
		}
		
		
		
		public function mirror( vector: Vector2 ): Vector2
		{
			
			x = 2 * vector.x - x;
			y = 2 * vector.y - y;
			
			return this;
		}
		
		public function getMirror( vector: Vector2 ): Vector2
		{
			
			return new Vector2( 2 * vector.x - x, 2 * vector.y - y );
		}
		
		
		public function negate( ): Vector2
		{
			x = -x;
			y = -y;
			
			return this;
		}
		
		public function getNegate( ):Vector2
		{
			return new Vector2( -x , -y );
		}
		
		public function orth( ):Vector2
		{
			var tx: Number = -y;
			
			y = x;
			x = tx;
			
			return this;
		}
		
		public function getOrth( ):Vector2
		{
			return new Vector2 ( -y , x );
		}
		
		public function normalize( ): Vector2
		{
			var l: Number = length;
			if ( l != 0 )
			{
				x /= l;
				y /= l;
			} else {
				x = y = 0;
			}
			return this;
		}
		
		public function getNormalize( ): Vector2
		{
			var l: Number = length;
			if ( l != 0 )
			{
				return new Vector2( x / l, y / l );
			} else {
				return new Vector2();
			}
		}
		
		public function normal( ):Vector2
		{
			var l: Number = length;
			if ( length != 0 )
			{
				var tx: Number = -y / l;
	
				y = x / l;
				x = tx;
			} else {
				x = y = 0;
			}
			return this;
		}
		
		public function getNormal( ):Vector2
		{
			var l: Number = length;
			if ( l != 0 )
				return new Vector2 ( -y / l , x / l );
			else
				return new Vector2();
		}
		
		
		public function getAddCartesian( angle:Number, length:Number ):Vector2
		{
			return new Vector2 (x + Math.cos ( angle ) * length, y+ Math.sin ( angle ) * length );
		}
		
		public function addCartesian( angle:Number, length:Number ):Vector2
		{
			x += Math.cos ( angle ) * length;
			y += Math.sin ( angle ) * length;
			return this;
		}
		
		public function rotateBy( angle:Number ): Vector2
		{
			var ca: Number = Math.cos ( angle );
			var sa: Number = Math.sin ( angle );
			var rx: Number = x * ca - y * sa;
			y = x * sa + y * ca;
			x = rx;
			
			return this;
		}
		
		public function rotateByCosSin( ca:Number, sa:Number ): Vector2
		{
			var rx: Number = x * ca - y * sa;
			y = x * sa + y * ca;
			x = rx;
			
			return this;
		}
		
		public function getRotateBy( angle:Number ):Vector2
		{
			var ca: Number = Math.cos ( angle );
			var sa: Number = Math.sin ( angle );
			var rx: Number = x * ca - y * sa;
			
			return new Vector2( rx , x * sa + y * ca );
		}
		
		public function getRotateByCosSin( ca:Number, sa:Number ):Vector2
		{
			var rx: Number = x * ca - y * sa;
			
			return new Vector2( rx , x * sa + y * ca );
		}
		
		public function rotateTo( angle:Number ):Vector2
		{
			var l: Number = length;
			x = Math.cos( angle ) * l;
			y = Math.sin( angle ) * l;
			
			return this;
		}
		
		public function getRotateTo( angle:Number ):Vector2
		{
			var l: Number = length;
			
			return new Vector2( Math.cos( angle ) * l, Math.sin( angle ) * l );
		}
		
		public function newLength( len:Number ):Vector2
		{
			var l: Number = length;
			if ( l == 0 ) return this;
			x *= len / l;
			y *= len / l;
			
			return this;
		}
		
		public function getNewLength( len:Number ):Vector2
		{
			var l: Number = length;
			
			return new Vector2( x / l * len, y / l * len );
		}
		
		public function plus( v:Vector2 ): Vector2
		{
			x += v.x;
			y += v.y;
			
			return this;
		}
		
		public function getPlus( v:Vector2 ):Vector2
		{
			return new Vector2( x + v.x, y + v.y );
		}
		
		public function plusXY( tx:Number, ty:Number ): Vector2
		{
			x += tx;
			y += ty;
			
			return this;
		}
		
		public function getPlusXY( tx:Number, ty:Number ): Vector2
		{
			return new Vector2( x + tx, y + ty );
		}
		
		public function minus( v:Vector2 ):Vector2
		{
			x -= v.x;
			y -= v.y;
			
			return this;
		}
		
		public function getMinus( v:Vector2 ):Vector2
		{
			return new Vector2( x - v.x, y - v.y );
		}
		
		public function multiply( f:Number ):Vector2
		{
			x *= f;
			y *= f;
			
			return this;
		}
		
		public function getMultiply( f:Number ):Vector2
		{
			return new Vector2( x * f, y * f );
		}
		
		public function multiplyXY( fx:Number, fy:Number ):Vector2
		{
			x *= fx;
			y *= fy;
			
			return this;
		}
		
		public function getMultiplyXY( fx:Number, fy:Number ):Vector2
		{
			return new Vector2( x * fx, y * fy );
		}
		
		public function divide( d:Number ):Vector2
		{
			x /= d;
			y /= d;
			
			return this;
		}
		
		public function getDivide( d:Number ): Vector2
		{
			return new Vector2( x / d, y / d );
		}
		
		public function getClone( ): Vector2
		{
			return new Vector2( x, y );
		}
		
		
		
		public function squaredDistanceTo( px:Number, py:Number ): Number
		{
			var dx:Number = x - px;
			var dy:Number = y - py;
			return dx * dx + dy * dy;
		}
		
		public function squaredDistanceToVector( v:Vector2 ): Number
		{
			var dx:Number = x - v.x;
			var dy:Number = y - v.y;
			return dx * dx + dy * dy;
		}
		
		public function distanceToVector( v:Vector2 ): Number
		{
			return Math.sqrt( squaredDistanceToVector(v) );
		}
		
		public function distanceToLine( v1:Vector2, v2:Vector2 ):Number
		{
			if (  v1.equals(v2))
			{
				return distanceToVector(v1);
			} 
			
			return getArea( v1,v2 ) / v1.distanceToVector( v2 ) * 2;
		}
		
		public function getArea( v1:Vector2, v2:Vector2 ):Number
		{
			return Math.abs( 0.5 * ( v1.x * v2.y + v2.x * y + x * v1.y - 
				v2.x * v1.y - x * v2.y - v1.x * y ));
		}
		
		public function draw ( g:Graphics, radius:Number = 2 ):void
		{
			g.moveTo(x-radius,y)
			g.lineTo(x+radius,y);
			g.moveTo(x,y-radius);
			g.lineTo(x,y+radius);
			//g.drawRect(x-radius,y-radius,radius+radius,radius+radius);
		}
		
		public function drawCircle ( g:Graphics, radius:Number = 2 ):void
		{
			g.drawRect(x-0.5,y-0.5,1,1);
			g.drawCircle(x,y,radius);
		}
		
		public function drawRect ( g:Graphics, radius:Number = 2 ):void
		{
			g.drawRect(x-radius,y-radius,radius+radius,radius+radius);
		}
		
		public function min( v:Vector2 ):Vector2 
		{
			x = Math.min( x, v.x);
			y = Math.min( y, v.y);
			return this;
		};
		
		public function minXY( px:Number, py:Number ):Vector2 
		{
			x = Math.min( x, px);
			y = Math.min( y, py);
			return this;
		};
		
		public function getMin( v:Vector2 ):Vector2 
		{
			return new Vector2(Math.min( x, v.x), Math.min(y, v.y));
		};
		
		public function max( v:Vector2 ):Vector2 
		{
			x = Math.max( x, v.x);
			y = Math.max( y, v.y);
			return this;
		};
		
		public function maxXY( px:Number, py:Number ):Vector2 
		{
			x = Math.max( x, px);
			y = Math.max( y, py);
			return this;
		};
		
		public function getMax( v:Vector2 ):Vector2
		{
			return new Vector2(Math.max( x, v.x), Math.max(y, v.y));
		};
		
		public function getLerp ( v:Vector2, l:Number ): Vector2
		{
			return new Vector2( x + (v.x - x) * l, y + (v.y - y) * l );
	
		}
		
		public function lerp ( v:Vector2, l:Number ): Vector2
		{
			x += (v.x - x) * l
			y += (v.y - y) * l;
			return this;
			
		}
		
		public function equals ( v:Vector2 ):Boolean 
		{
			return (x == v.x && y == v.y);
		};
		
		public function snaps ( v:Vector2, squaredSnapDistance:Number = 0.00000001 ):Boolean 
		{
			return squaredDistanceToVector( v ) < squaredSnapDistance;
		};
		
		public function isLower(v:Vector2):Boolean 
		{
			return (x<v.x && y<v.y);
		};
		
		public function isLowerOrEqual(v:Vector2):Boolean 
		{
			return (x<=v.x && y<=v.y);
		};
		
		public function isGreater(v:Vector2):Boolean 
		{
			return (x>v.x && y>v.y);
		};
		
		public function isGreaterOrEqual(v:Vector2):Boolean
		{
			return (x>=v.x && y>=v.y);
		};
		
		public function isLessOrEqual(v:Vector2):Boolean
		{
			return (x<=v.x && y<=v.y);
		};
		
		public function isLeft( p0:Vector2,p1:Vector2):Number
		{
			return (p1.x-p0.x)*(y-p0.y)-(x-p0.x)*(p1.y-p0.y);
		}
		
		public function windingDirection( p0:Vector2,p1:Vector2):int
		{
			var result:Number = (p0.x - p1.x) * (p1.y - y) - (p0.y - p1.y) * (p1.x - x);
    		if (result < 0) return -1;	
    		if (result > 0) return  1;	
    		return 0;
			
		}
		
		public function rotateAround ( angle:Number, rotationPoint:Vector2 ):Vector2
		{
			minus(rotationPoint);
			rotateBy( angle );
			plus(rotationPoint);
			return this;
		 }
		
		public function getRotateAround ( angle:Number, rotationPoint:Vector2 ):Vector2
		{
			var p:Vector2 = getMinus(rotationPoint);
			p.rotateBy( angle );
			p.plus(rotationPoint);
			return p;
		}
	
		public function randomize( minx:Number, maxx:Number, miny:Number, maxy:Number ):Vector2
		{
			x =  minx + Math.random() * (maxx-minx);
			y =  miny + Math.random() * (maxy-miny);
			
			return this;
		}
		
		public function compare( v:Vector2 ):int
		{
			if (x < v.x) return -1;	
		    if (x > v.x) return  1;	
		    if (y < v.y) return -1;	
		    if (y > v.y) return  1;
		    return 0;			
		}
		
		public function applyTransformationMatrix( matrix:Matrix ):Vector2
		{
			var tx:Number = x * matrix.a + y * matrix.c + matrix.tx;
			y = x * matrix.b + y * matrix.d + matrix.ty;
			x = tx;
			return this;
		}
		
		public function getApplyTransformationMatrix( matrix:Matrix ):Vector2
		{
			return new Vector2( x * matrix.a + y * matrix.c + matrix.tx, x * matrix.b + y * matrix.d + matrix.ty );
		}
		
		public function addLabel( label:String, canvas:Sprite, color:int = 0, backgroundColor:int = 0xffffff, lineColor:int = 0, backgroundAlpha:Number = 0.6 ):void
		{
			canvas.graphics.lineStyle()
			canvas.graphics.beginFill(backgroundColor);
			canvas.graphics.drawCircle( x,y,2);
			canvas.graphics.endFill();
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("Arial",9,color);
			tf.autoSize = "left";
			tf.text = label;
			tf.x = x + 6;
			tf.y = y - 17;
			canvas.addChild(tf);
			
			
			canvas.graphics.beginFill(backgroundColor,backgroundAlpha);
			canvas.graphics.drawRect( x+4,y-15, tf.width + 5, 12 );
			canvas.graphics.endFill();
			
			canvas.graphics.lineStyle(0,lineColor);
			canvas.graphics.moveTo(x,y);
			canvas.graphics.lineTo(x+4,y-4);
			
		}
		
		public function toString( ): String
		{
			var rx: Number = Math.round ( x * 1000 ) / 1000;
			var ry: Number = Math.round ( y * 1000 ) / 1000;
			
			return 'new Vector2(' + rx + ',' + ry + ')';
		}
		
		public function toSVG():String
		{
			return x + " "+ y + " ";
		}
		
		public function toPoint():Point
		{
			return new Point(x,y);
		}
	}
}