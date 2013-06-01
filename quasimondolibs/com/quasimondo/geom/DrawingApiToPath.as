package com.quasimondo.geom
{
	import com.quasimondo.geom.MixedPath;
	
	public class DrawingApiToPath
	{
		private var _shape:CompoundShape;
		private var _currentPath:MixedPath;
		private var _commands:Vector.<DrawingCommand>;
		
		public function DrawingApiToPath()
		{
			_shape = new CompoundShape();
			_commands = new Vector.<DrawingCommand>();
		}
		
		public function startNewShape():void
		{
			trace("startNewShape");
			if ( _commands.length > 0  )
			{
				addShape();
			}
		}
		
		private function addShape():void
		{
			var nextIndex:int;
			for ( var i:int = 0; i < _commands.length; i++ )
			{
				if ( _commands[i].type == "moveTo" )
				{
					nextIndex = (i+1)%_commands.length;
					if ( _commands[nextIndex].type == "lineTo" &&  _commands[nextIndex].x == _commands[i].x && _commands[nextIndex].y == _commands[i].y )
					{
						_commands.splice( nextIndex, 1 );
						if ( nextIndex < i ) i--;
					}
				}
			}

			
			var startIndex:int = -1
			for ( i = 0; i < _commands.length; i++ )
			{
				if ( _commands[i].type == "moveTo" )
				{
					if ( i > 0 )
					{
						if ( ( _commands[i-1].type == "curveTo" || _commands[i-1].type == "lineTo" ) &&  _commands[i-1].x == _commands[i].x && _commands[i-1].y == _commands[i].y )
						{
							_commands.splice(i,1);
							continue;
						}
					}
					startIndex = i;
					
					
				} else if ( startIndex != -1 && (_commands[i].type == "curveTo" || _commands[i].type == "lineTo"))
				{
					if ( _commands[i].x == _commands[startIndex].x && _commands[i].y == _commands[startIndex].y )
					{
						var path:MixedPath = new MixedPath();
						for ( var j:int = startIndex; j <= i; j++ )
						{
							switch ( _commands[j].type )
							{
								case "moveTo":
								case "lineTo":
									path.addPoint( new Vector2( _commands[j].x, _commands[j].y ) );
								break;
								case "curveTo":
									path.addControlPoint( new Vector2( _commands[j].cx, _commands[j].cy ) );
									path.addPoint(new Vector2( _commands[j].x, _commands[j].y ) );
								break;
							}
						}
						path.setClosed( true );
						_shape.addShape( path )
						_commands.splice( startIndex, i - startIndex + 1 );
						startIndex = -1;
						i = -1;
					}
					
				}
			}
			if ( _commands.length != 0 )
			{
				throw( new Error("Looks like there is still something missing in the shape log algorithm"));
				_commands.length = 0;
			}
		}
		
		public function clear():void
		{
			_shape.clear();
			_currentPath = new MixedPath();
			_commands = new Vector.<DrawingCommand>();
		}
		
		public function moveTo( x:Number, y:Number ):void
		{
			_commands.push( new DrawingCommand("moveTo",x,y) );
		}
		
		public function lineTo( x:Number, y:Number ):void
		{
			_commands.push( new DrawingCommand("lineTo",x,y) );
		}
		
		public function curveTo( cx:Number, cy:Number, x:Number, y:Number ):void
		{
			_commands.push( new DrawingCommand("curveTo",x,y,cx,cy) );
		}
		
		public function get shape():CompoundShape
		{
			if ( _commands.length > 0  )
			{
				addShape();
			}
			return _shape;
		}
	}
}

internal final class DrawingCommand
{
	public var type:String;
	public var x:Number;
	public var y:Number;
	public var cx:Number;
	public var cy:Number;
	
	public function DrawingCommand( type:String, x:Number, y:Number, cx:Number = NaN, cy:Number = NaN )
	{
		this.type = type;
		this.x = x;
		this.y = y;
		this.cx = cx;
		this.cy = cy;
	}
}