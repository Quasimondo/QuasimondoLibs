package
{
	import com.quasimondo.utils.ITableIterator;
	import com.quasimondo.utils.ListTableIterator;
	import com.quasimondo.utils.NumericTableIterator;
	import com.quasimondo.utils.Table;
	
	import flash.display.Sprite;
	
	public class TableTest extends Sprite
	{
		public function TableTest()
		{
			var result:Vector.<*> = Table( f2, new <ITableIterator>[ new ListTableIterator(["John","Anne"]), 
																	 new ListTableIterator(["buys","eats","sees"]), 
																	 new NumericTableIterator(1,3),
																	 new ListTableIterator(["dog","cat","cheese"] )] );
			trace( result );
			
			/*
			John buys 1 dog,
			John buys 1 cat,
			John buys 1 cheese,
			John buys 2 dogs,
			John buys 2 cats,
			John buys 2 cheeses,
			John buys 3 dogs,
			John buys 3 cats,
			John buys 3 cheeses,
			John eats 1 dog,
			John eats 1 cat,
			John eats 1 cheese,
			John eats 2 dogs,
			John eats 2 cats,
			John eats 2 cheeses,
			John eats 3 dogs,
			John eats 3 cats,
			John eats 3 cheeses,
			John sees 1 dog,
			John sees 1 cat,
			John sees 1 cheese,
			John sees 2 dogs,
			John sees 2 cats,
			John sees 2 cheeses,
			John sees 3 dogs,
			John sees 3 cats,
			John sees 3 cheeses,
			Anne buys 1 dog,
			Anne buys 1 cat,
			Anne buys 1 cheese,
			Anne buys 2 dogs,
			Anne buys 2 cats,
			Anne buys 2 cheeses,
			Anne buys 3 dogs,
			Anne buys 3 cats,
			Anne buys 3 cheeses,
			Anne eats 1 dog,
			Anne eats 1 cat,
			Anne eats 1 cheese,
			Anne eats 2 dogs,
			Anne eats 2 cats,
			Anne eats 2 cheeses,
			Anne eats 3 dogs,
			Anne eats 3 cats,
			Anne eats 3 cheeses,
			Anne sees 1 dog,
			Anne sees 1 cat,
			Anne sees 1 cheese,
			Anne sees 2 dogs,
			Anne sees 2 cats,
			Anne sees 2 cheeses,
			Anne sees 3 dogs,
			Anne sees 3 cats,
			Anne sees 3 cheeses
			*/
		}
		
		private function f2( a:String, b:String, n:int, c:String ):String
		{
			return "\n"+a+" "+b+" "+ n +" "+c + (n>1 ? "s" : "");
		}
	}
}