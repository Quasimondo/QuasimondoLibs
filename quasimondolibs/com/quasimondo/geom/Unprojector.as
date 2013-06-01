package com.quasimondo.geom
{
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	public class Unprojector
	{
		private var a11:Number;
		private var a21:Number;
		private var a31:Number;
		private var a12:Number;
		private var a22:Number;
		private var a32:Number;
		private var a13:Number;
		private var a23:Number;
		
		private var m11:Number;
		private var m21:Number;
		private var m31:Number;
		private var m12:Number;
		private var m22:Number;
		private var m32:Number;
		private var m13:Number;
		private var m23:Number;
		
		private var det:Number;
		
		public function Unprojector()
		{
		}
		
		public function unproject( u:Number, v:Number, resultXY:Object):void
		{
			var z:Number = a13 * u + a23 * v + 1;
			resultXY.x = (a11 * u + a21 * v + a31 ) / z;
			resultXY.y = (a12 * u + a22 * v + a32 ) / z;
		}
		
		
		public function project( x:Number, y:Number, resultUV:Object ):void 
		{
			var z:Number =  det / ((m13 * x + m23 * y) * det + 1);
			resultUV.x = (m11 * x + m21 * y + m31 ) * z;
			resultUV.y = (m12 * x + m22 * y + m32 ) * z;
		}
		
		
		public function updateFactors( TL:Object, TR:Object, BR:Object, BL:Object ):void
		{
			var dx1:Number = TR.x - BR.x;
			var dx2:Number = BL.x - BR.x;
			var dx3:Number = TL.x - TR.x + BR.x - BL.x;
			
			var dy1:Number = TR.y - BR.y;
			var dy2:Number = BL.y - BR.y;
			var dy3:Number = TL.y - TR.y + BR.y - BL.y;
			
			var z:Number = dx1 * dy2 - dy1 * dx2;
			
			a13 = ((dx3*dy2)-(dy3*dx2))/z;
			a23 = ((dy3*dx1)-(dx3*dy1))/z;
		 
		 	a11 = TR.x - TL.x + a13 * TR.x;
			a21 = BL.x - TL.x + a23 * BL.x;
			a31 = TL.x;
		 	a12 = TR.y - TL.y + a13 * TR.y;
			a22 = BL.y - TL.y + a23 * BL.y;
			a32 = TL.y;
			
			det = 1 / ( a11*a22 - a21*a12 );
			
			m11 = a22-a32*a23;
			m12 = a32*a13-a12;
			m13 = a23*a12-a22*a13;
			m21 = a31*a23-a21;
			m22 = a11-a31*a13;
			m23 = a21*a13-a23*a11;
			m31 = a32*a21-a31*a22;
			m32 = a31*a12-a32*a11;
			
			trace("good",[m11,m12,m13,m21,m22,m23,m31,32,det]);
		}
	}
}