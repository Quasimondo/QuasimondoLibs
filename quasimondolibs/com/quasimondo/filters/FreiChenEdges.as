package com.quasimondo.filters
{
	import flash.display.*;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;

	public class FreiChenEdges extends ShaderFilter
	{
		[Embed(source="FreiChen.pbj", mimeType="application/octet-stream")]
        private var Kernel:Class;
        
		private var _shader:Shader;
		
		private var _threshold:Number = 0;
		private var _strength:Number = 1;
		private var _gamma:Number = 1;
		private var _invert:Boolean = false;
		
		public function FreiChenEdges( )
		{
			_shader = new Shader( new Kernel() as ByteArray );
			
			super(_shader);
		}
		
		public function get threshold():Number
		{
			return _threshold;
		}
		
		public function set threshold( value:Number ):void
		{
			_shader.data.threshold.value = [ _threshold = value ];
		}
		
		public function get gamma():Number
		{
			return _gamma;
		}
		
		public function set gamma( value:Number ):void
		{
			_shader.data.gamma.value = [ _gamma = value ];
		}
		
		public function get invert():Boolean
		{
			return _invert;
		}
		
		public function set invert( value:Boolean ):void
		{
			_shader.data.invert.value = [ value ? 1 : 0];
		}
		
		public function get strength():Number
		{
			return _strength;
		}
		
		public function set strength( value:Number ):void
		{
			_shader.data.factor.value = [ _strength = value ];
		}
	}
}