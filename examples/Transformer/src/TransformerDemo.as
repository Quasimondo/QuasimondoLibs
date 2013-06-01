package
{
	import com.quasimondo.display.InteractiveSprite;
	import com.quasimondo.tools.Transformer;
	import com.quasimondo.tools.TransformerHandle;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	public class TransformerDemo extends InteractiveSprite
	{
		private var transformer:Transformer;
		private var workspace:Sprite;
		
		public function TransformerDemo()
		{}
		
		override public function init():void
		{
			workspace = new Sprite();
			addChild(workspace);
			
			var shape1:Shape = new Shape();
			shape1.graphics.beginFill(0xff8000);
			shape1.graphics.drawCircle(200,200,100);
			workspace.addChild(shape1);
			
			var shape2:Shape = new Shape();
			shape2.graphics.beginFill(0x0080ff);
			shape2.graphics.drawRect(20,20,100,200);
			workspace.addChild(shape2);
			
			transformer = new Transformer();
			
			
		}
		
		override public function onMouseDown(event:MouseEvent):void
		{
			if ( event.target is Stage && ! transformer.hasActiveHandles())
			{
				transformer.hide();
			} else if ( event.target == workspace)
			{
				for ( var i:int = 0; i < workspace.numChildren; i++ )
				{
					if ( workspace.getChildAt(i).hitTestPoint(mouseX,mouseY,true))
					{
						transformer.show( workspace.getChildAt(i), Transformer.ALL, null, this, true );
						break;
					}
				}
			}
			
		}
	}
}