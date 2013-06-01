package
{
	import com.quasimondo.delaunay.DelaunayNodeProperties;
	
	public class ABDelaunayNodeProperties extends DelaunayNodeProperties
	{
		public var index:int;
		
		public function ABDelaunayNodeProperties( index:int)
		{
			super();
			this.index = index;
		}
	}
}