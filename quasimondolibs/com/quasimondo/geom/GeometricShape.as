package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class GeometricShape implements IIntersectable
	{
		public static var SNAP_DISTANCE:Number = 0.0000000001;
		
		public var fillColor:uint;
		
		function GeometricShape()
		{
		}
		
		public function booleanOperation( that:GeometricShape, operation:String ):CompoundShape
		{
			return BooleanShapeOperation.operate( this, that, operation );
		}
		
		public function get type():String
		{
			return "GeometricShape";
		}
		
		/*
		public function offset( offset:Vector2 ):void
		{
			throw new Error("Must override offset!");
		}
		*/
		
		public function drawExtras( g:Graphics, factor:Number = 1 ):void
		{
			throw new Error("Must override drawExtras!");
		}
		
		public function export( g:IGraphics ):void
		{
			throw new Error("Must override export!");
		}
		
		public function draw( g:Graphics ):void
		{
			throw new Error("Must override draw!");
		}
		
		public function drawTo( g:Graphics ):void
		{
			throw new Error("Must override drawTo!");
		}
		
		public function moveToStart( g:Graphics ):void
		{
			throw new Error("Must override moveToStart!");
		}
		
		public function moveToEnd ( g: Graphics ): void
		{
			throw new Error("Must override moveToEnd!");
		}
		
	 	public function exportDrawTo ( g: IGraphics ):void
		{
			throw new Error("Must override exportDrawTo!");
		}
		
		public function exportMoveToStart ( g: IGraphics ):void
		{
			throw new Error("Must override exportMoveToStart!");
		}
		
		public function exportMoveToEnd ( g: IGraphics ): void
		{
			throw new Error("Must override exportMoveToEnd!");
		}
		
		public function hasPoint( v:Vector2 ):Boolean
		{
			throw new Error("Must override hasPoint!");
			return null;
		}
		
		public function getPoint( t:Number ):Vector2
		{
			throw new Error("Must override getPoint!");
			return null;
		}
		
		public function getPointAtOffset( offset:Number ):Vector2
		{
			throw new Error("Must override getPointAtOffset!");
			return null;
		}
		
		public function getNormalAtPoint( p:Vector2 ):Vector2
		{
			throw new Error("Must override getNormalAt!");
			return null;
		}
		
		public function getClosestPoint( p:Vector2 ):Vector2
		{
			throw new Error("Must override getClosestPoint!");
			return null;
		}
		
		public function getClosestT( p:Vector2 ):Number
		{
			throw new Error("Must override getClosestT!");
			return 0;
		}
		
		public function translate( offset:Vector2 ):GeometricShape
		{
			throw new Error("Must override translate!");
			return null;
		}
		
		public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			throw new Error("Must override rotate!");
			return null;
		}
		
		public function scale( factorX:Number, factorY:Number, center:Vector2 = null ):GeometricShape
		{
			throw new Error("Must override scale!");
			return null;
		}
		
		public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
			throw new Error("Must override getBoundingRect!");
			return null;
		}
		
		public function get length():Number
		{
			throw new Error("Must override length");
			return 0;
		}
		
		public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			throw new Error("Must override isInside");
			return false;
		}
		
		public function intersect ( that:IIntersectable ):Intersection 
		{
			return Intersection.intersect( this, that );
		};
		
		public function clone( deepClone:Boolean = true ):GeometricShape
		{
			throw new Error("Must override clone()");
			return null;
		}
		
		public function reflect( lineSegment:LineSegment ):GeometricShape
		{
			throw new Error("Must override reflect()");
			return null;
		}
		
		public function applyTransformationMatrix( matrix:Matrix, clone:Boolean = false ):GeometricShape
		{
			throw new Error("Must override applyTransformationMatrix()");
			return null;
		}
		
		
	}
}