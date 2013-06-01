package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class CompoundShape extends GeometricShape implements IIntersectable, ICountable, IPolygonHelpers
	{
		private var shapes:Vector.<GeometricShape>;
		
		public static function fromPolygons( polygons:Vector.<Polygon> ):CompoundShape
		{
			var result:CompoundShape = new CompoundShape();
			for each ( var poly:Polygon in polygons )
			{
				result.addShape( poly );
			}
			return result;
		}
		
		public function CompoundShape()
		{
			super();
			shapes = new Vector.<GeometricShape>();
		}
		
		public function addShape( shape:GeometricShape ):void
		{
			if ( shape is CompoundShape )
			{
				for ( var i:int = 0; i < CompoundShape(shape).shapeCount; i++ )
				{
					shapes.push( CompoundShape(shape).getShapeAt(i)); 
				}
			} else {
				shapes.push( shape );
			}
		}
		
		override public function translate(offset:Vector2):GeometricShape
		{
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shapes[i].translate( offset );
			}
			return this;
		}
		
		override public function rotate(angle:Number, center:Vector2=null):GeometricShape
		{
			if ( center == null ) {
				var r:Rectangle = getBoundingRect();
				center = new Vector2( r.x + r.width * 0.5, r.y + r.height * 0.5 );
			}
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shapes[i].rotate(angle, center);
			}
			return this;
		}
		
		override public function scale(factorX:Number, factorY:Number, center:Vector2 = null):GeometricShape
		{
			if ( center == null ) {
				var r:Rectangle = getBoundingRect();
				center = new Vector2( r.x + r.width * 0.5, r.y + r.height * 0.5 );
			}
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shapes[i].scale(factorX, factorY, center);
			}
			return this;
		}
		
		override public function reflect(lineSegment:LineSegment):GeometricShape
		{
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shapes[i].reflect(lineSegment);
			}
			return this;
		}
		
		public function clear():void
		{
			shapes.length = 0;
		}
		
		public function get shapeCount():int
		{
			return shapes.length;
		}
		
		public function get pointCount():int
		{
			var c:int = 0;
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				c += ICountable(shapes[i]).pointCount;
			}
			return c;
		}
		
		public function getShapeAt( index:int ):GeometricShape
		{
			return shapes[index];
		}
		
		override public function draw( canvas:Graphics ):void
		{
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shapes[i].draw( canvas );
			}
		}
		
		override public function export( canvas:IGraphics ):void
		{
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shapes[i].export( canvas );
			}
		}
		
		override public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			for each ( var shape:GeometricShape in shapes )
			{
				if( shape.isInside( p, true ) && !shape.isInside( p, false )) return includeVertices;
			}
			
			var inside:int = 0;
			for each ( shape in shapes )
			{
				if (shape.isInside( p, false )) inside++;
			}
			
			return (inside % 2 == 1);
		}

		public function addPointAtClosestSide( p:Vector2 ):void
		{
			var closestPoly:Polygon;
			var closestDistance:Number = Number.MAX_VALUE;
			
			for each ( var shape:GeometricShape in shapes )
			{
				if ( shape is Polygon )
				{
					var d:Number = Polygon(shape).squaredDistanceToPoint(p);
					if ( d < closestDistance )
					{
						closestDistance = d;
						closestPoly = Polygon(shape);
					}
				}
			}
			
			if ( closestPoly != null ) closestPoly.addPointAtClosestSide( p );
		}
		
		public function detangle():void
		{
			for each ( var shape:GeometricShape in shapes )
			{
				if ( shape is IPolygonHelpers ) IPolygonHelpers(shape).detangle();
			}
		}
		
		public function fractalize( factor:Number = 0.5, range:Number = 0.5, minSegmentLength:Number = 2, iterations:int = 1 ):void
		{
			for each ( var shape:GeometricShape in shapes )
			{
				if ( shape is IPolygonHelpers ) IPolygonHelpers(shape).fractalize(factor,range,minSegmentLength,iterations);
			}
		}
		
		public function getPointAt( index:int ):Vector2
		{
			var l:int = pointCount;
			index = int(((index % l) + l )% l);
			var c:int = 0;
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				if ( index >= ICountable(shapes[i]).pointCount )
				{
					index -= ICountable(shapes[i]).pointCount;
				} else {
					return ICountable(shapes[i]).getPointAt( index );
				}
			}
			return null;
		}
		
		override public function getClosestPoint(p:Vector2):Vector2
		{
			var closest:Vector2;
			var shortest:Number;
			var d:Number;
			for each ( var shape:GeometricShape in shapes )
			{
				var v:Vector2 = shape.getClosestPoint( p );
				if ( closest == null || v.squaredDistanceToVector( p ) < shortest )
				{
					shortest = v.squaredDistanceToVector( p );
					closest = v;
				}
			}
			return closest;
		}
		
		override public function hasPoint( v:Vector2 ):Boolean
		{
			for each ( var shape:GeometricShape in shapes )
			{
				if ( shape.hasPoint( v ) ) return true;
			}
			return false;
		}
		
		
		override public function getBoundingRect(loose:Boolean=true):Rectangle
		{
			var r:Rectangle = shapes[0].getBoundingRect(loose);
			for ( var i:int = 1; i < shapes.length; i++ )
			{
				r = r.union(shapes[i].getBoundingRect(loose));
			}
			return r;
		}
		
		override public function clone( deepClone:Boolean = true ):GeometricShape
		{
			var shape:CompoundShape = new CompoundShape();
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shape.addShape( shapes[i].clone( deepClone ) );
			}
			return shape;
		}
		
		override public function get type():String
		{
			return "CompoundShape";
		}
	}
}