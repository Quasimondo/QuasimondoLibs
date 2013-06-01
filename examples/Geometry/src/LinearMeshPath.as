package
{
	import com.quasimondo.display.InteractiveSprite;
	import com.quasimondo.geom.LineSegment;
	import com.quasimondo.geom.LinearMesh;
	import com.quasimondo.geom.LinearPath;
	import com.quasimondo.geom.Vector2;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	public class LinearMeshPath extends InteractiveSprite
	{
		private static const MODE_DRAW:String = "MODE_DRAW";
		private static const MODE_SELECT:String = "MODE_SELECT";
		
		private var mode:String = MODE_DRAW;
		
		private var lineStart:Vector2;
		private var lineEnd:Vector2;
		private var drawingLine:Boolean;
		private var mesh:LinearMesh;
		private var newLine:LineSegment;
		private var tf:TextField;
		
		
		public function LinearMeshPath()
		{
			super();
		}

		override public function init():void
		{
			lineStart = new Vector2();
			lineEnd = new Vector2();
			drawingLine = false;
			mesh = new LinearMesh();
			newLine = new LineSegment(lineStart,lineEnd );
			
			tf = new TextField();
			tf.autoSize = "left";
			addChild(tf);
			tf.text = "Draw lines by clicking and dragging. Press SPACE to switch to SELECT mode";
		}
		
		override public function onKeyDown(event:KeyboardEvent):void
		{
			switch ( event.keyCode )
			{
				case Keyboard.SPACE:
					if ( mode == MODE_DRAW )
					{
						mode = MODE_SELECT;
						tf.text = "Click node to select new end point. Press SPACE to switch to DRAW mode";
					} else if ( mode == MODE_SELECT )
					{
						mode = MODE_DRAW;
						tf.text = "Draw lines by clicking and dragging. Press SPACE to switch to SELECT mode";
					}
					render();
				break;
			}
		}
		
		override public function onMouseDown(event:MouseEvent):void
		{
			switch ( mode )
			{
				case MODE_DRAW:
					lineStart.x = mouseX;
					lineStart.y = mouseY;
					drawingLine = true;
				break;
				case MODE_SELECT:
					lineEnd.setValue( lineStart );
					lineStart.setValue( mesh.getNearestPoint( new Vector2( mouseX, mouseY ) ));
					
					render();
				break;
			}
		}
		
		override public function onMouseUp(event:MouseEvent):void
		{
			switch ( mode )
			{
				case MODE_DRAW:
					drawingLine = false;
					mesh.addLineSegment( newLine );
					render();
					break;
			}
		}
		
		override public function onMouseMove(event:MouseEvent):void
		{
			switch ( mode )
			{
				case MODE_DRAW:
					if (drawingLine)
					{
						lineEnd.x = mouseX;
						lineEnd.y = mouseY;
						render();
					}

					break;
			}
		}
		
		private function render():void
		{
			g.clear();
			g.lineStyle(0,0,0.25);
			mesh.drawLines(g);
			g.lineStyle(0,0);
			mesh.drawExtras(g);
			
			switch ( mode )
			{
				case MODE_DRAW:
					if ( drawingLine )
					{
						g.lineStyle(0,0xff8000);
						newLine.draw(g);
					}
				break;
				case MODE_SELECT:
					g.lineStyle(0,0xff8000);
					lineStart.drawCircle(g,2);
					lineEnd.drawCircle(g,2);
					
					var path:LinearPath = mesh.getShortestPath( lineStart, lineEnd );
					if ( path.pointCount > 2 )
					{
						path.getSmoothPath( 50, LinearPath.SMOOTH_PATH_ABSOLUTE_EDGEWISE ).draw(g);
					} else {
						path.draw( g );
					}
				break;
			}
			
			
		}
	}
}