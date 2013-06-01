package
{
	import com.quasimondo.delaunay.BoundingTriangleNodeProperties;
	import com.quasimondo.delaunay.Delaunay;
	import com.quasimondo.delaunay.DelaunayColorNodeProperties;
	import com.quasimondo.delaunay.DelaunayEdge;
	import com.quasimondo.delaunay.DelaunayNode;
	import com.quasimondo.delaunay.DelaunayNodeProperties;
	import com.quasimondo.delaunay.VoronoiRegion;
	import com.quasimondo.display.InteractiveSprite;
	import com.quasimondo.geom.ConvexPolygon;
	import com.quasimondo.geom.Intersection;
	import com.quasimondo.geom.LineSegment;
	import com.quasimondo.geom.Polygon;
	import com.quasimondo.geom.Vector2;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class DelaunayRelax extends InteractiveSprite
	{
		private var d:Delaunay;
		private var fullyRelaxed:Boolean;
		private var constrain:Polygon;
		
		public function DelaunayRelax()
		{
			super();
		}
		
		override public function init():void
		{
			var w:int = 500;
			var h:int = 500;
			d = new Delaunay();
			d.createBoundingTriangle();
			
			constrain = Polygon.getCenteredStar( 250,100,5,new Vector2(450,350),-0.25);
			
			for ( var i:int = 0; i < constrain.pointCount; i++ )
			{
				d.insertVector2( constrain.getPointAt(i), new DelaunayColorNodeProperties( 0xffff0000, false) );
			}
			
			
			for ( i = 0; i < 30; i++ )
			{
				var a:Number = Math.random() * Math.PI * 2;
				var r:Number = Math.random() * 250;
				d.insertXY( 450 + r * Math.sin(a),350 + r * Math.cos(a), new DelaunayColorNodeProperties( 0xffff0000 ) );	
			}
			fullyRelaxed = false;
			render();
		}
		
		
		
		private function render():void
		{
			g.clear();
			g.lineStyle(0,0x000000);
			constrain.draw(g);
			
			g.lineStyle(0,0x0000);
			var v:Vector.<DelaunayEdge> = d.getEdges();
			for each ( var e:DelaunayEdge in v )
			{
				var l:LineSegment = e.toLine();
				var intersection:Intersection = constrain.intersect( l );
				
				var outside:Boolean = false;
				for each ( var p:Vector2 in intersection.points )
				{
					if ( !(p.snaps( l.p1 ) || p.snaps( l.p2 )))
					{
						outside = true;
						break;		
					}
				}
				if ( !outside )
				{
					outside = !constrain.isInside( l.getPoint(0.5) ); 
					
				}
				if ( !outside )
				{
					l.draw(g)
				}
			}
			
			g.lineStyle(0,0xff0000);
			
			d.drawPoints( g );
			
		}
		
		override public function onMouseDown(event:MouseEvent):void
		{
			var props:DelaunayColorNodeProperties = new DelaunayColorNodeProperties( 0xffff0000, !shiftIsDown );
			d.insertXY( mouseX, mouseY, props );
			fullyRelaxed = false;
		}
		
		override public function onEnterFrame(event:Event):void
		{
			if ( !fullyRelaxed)
			{
				fullyRelaxed = !d.relaxVoronoi(1,constrain);
				//relaxVoronoi(1);
				render();
			}
		}
	}
}