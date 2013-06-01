package com.quasimondo.display
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	public class InteractiveSprite extends Sprite
	{
		
		protected var shiftIsDown:Boolean = false;
		protected var ctrlIsDown:Boolean = false;
		protected var mouseIsDown:Boolean = false;
		protected const g:Graphics = graphics;
		
		public function InteractiveSprite()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, setup );
		}
		
		protected function setup( event:Event):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, setup );
			
			addListeners();
			stage.scaleMode = "noScale";	
			stage.align = "TL";	
			
			init();
		}
		
		private function addListeners():void
		{
			addEventListener( Event.REMOVED_FROM_STAGE, removeListeners );
			
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, _onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, _onKeyUp );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, _onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, _onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
		}
		
		private function removeListeners( event:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, removeListeners );
			
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, _onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, _onKeyUp );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, _onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, _onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
		}
		
		public function init():void
		{
		}
		
		public function onEnterFrame( event:Event ):void
		{
			
		}
		
		private function _onKeyDown( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.SHIFT ) shiftIsDown = true;
			if ( event.keyCode == Keyboard.CONTROL ) ctrlIsDown = true;
			
			onKeyDown( event );
		}
		
		public function onKeyDown( event:KeyboardEvent ):void
		{
		}
		
		private function _onKeyUp( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.SHIFT ) shiftIsDown = false;
			if ( event.keyCode == Keyboard.CONTROL ) ctrlIsDown = false;
			onKeyUp( event );
		}
		
		public function onKeyUp( event:KeyboardEvent ):void
		{
			
		}
		
		public function _onMouseDown( event:MouseEvent ):void
		{
			mouseIsDown = true;
			onMouseDown( event );
		}
		
		public function onMouseDown( event:MouseEvent ):void
		{
			
		}
		
		public function _onMouseUp( event:MouseEvent ):void
		{
			mouseIsDown = false;
			onMouseUp( event );
		}
		
		public function onMouseUp( event:MouseEvent ):void
		{
			
		}
		
		public function onMouseMove( event:MouseEvent ):void
		{
			
		}
		
		public function onMouseWheel( event:MouseEvent ):void
		{
			
		}
	}
}