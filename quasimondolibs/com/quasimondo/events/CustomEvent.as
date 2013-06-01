
package com.quasimondo.events
{

	import flash.events.Event;

	public dynamic class CustomEvent extends Event
	{
		
		public static var CHANGE : String = "mtv_change";
		public static var DELETE : String = "mtv_delete";
		public static var SELECT : String = "mtv_select";
		public static var UPDATE : String = "mtv_update";
		public static var DOUBLE : String = "mtv_double";
		
		public static var ERROR : String = "mtv_error";
		public static var TIMEOUT : String = "mtv_timeout";
		public static var COMPLETE : String = "mtv_complete";
		public static var PROGRESS : String = "mtv_progress";
		
		public static var ADD : String = "mtv_add";
		public static var REMOVE : String = "mtv_remove";
		
		public static var ACTIVATE : String = "mtv_activate";
		public static var DEACTIVATE : String = "mtv_deactivate";
				
		public static var DRAG_ENTER : String = "mtv_drag_enter";
		public static var DRAG_LEAVE : String = "mtv_drag_leave";
		public static var DRAG_DROP : String = "mtv_drag_drop";
		
		public static var ACCEPT : String = "mtv_accept";
		public static var DENY : String = "mtv_deny";
		
		
		//From Suha for Martin
		public static var ANIMATION : String = "mtv_animation";
		public static var BTN_OVER : String = "mtv_btn_over";
		public static var BTN_OUT : String = "mtv_btn_out";
		public static var BTN_UP : String = "mtv_btn_up";
		
		
		public function CustomEvent ( type : String  )
		{
			
			super( type );

		}

	}

}