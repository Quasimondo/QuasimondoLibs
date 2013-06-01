package com.quasimondo.delaunay
{
	import com.quasimondo.geom.Vector2;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.utils.Dictionary;
	
	public class DelaunayNodes {
		
		private var first:DelaunayNode;
		public var size:int = 0;
		
		private static var depot:Vector.<DelaunayNode> = new Vector.<DelaunayNode>();
		
		private var dismin:Number=0.0;
		private var s:Number;
		
		public static function getNode( x:Number, y:Number, data:DelaunayNodeProperties = null ):DelaunayNode
		{
			var node:DelaunayNode;
			if ( data == null ) data = new DelaunayNodeProperties();
			
			if ( depot.length>0){
				node = depot.pop();
				node.x = x;
				node.y = y;
				
				node.data = data;
			} else {
				node = new DelaunayNode( x,y,data );
			}
			data.node = node;
			return node;
		}
		
		public static function deleteNode( node:DelaunayNode ):void
		{
			node.reset();
			depot.push(node);
		}
		
		public function DelaunayNodes() {
		}

		public function addElement( e:DelaunayNode ):void
		{
			e.next = first;
			first = e;
			size++;
		}
	
		public function elementAt( index:int ):DelaunayNode
		{
			var nd:DelaunayNode = first;
			while ( index-- > 0 && nd != null )
			{ 
				nd = nd.next 
			}
			return nd;
		}
		
		public function removeFirstElement():DelaunayNode
		{
			var nd:DelaunayNode;
			if (first!=null)
			{
				size--;
				nd = first;
				first = first.next;
				nd.next = null;
			}
			return nd;
		}
		
		public function removeElement( e:DelaunayNode ):void
		{
			var nd:DelaunayNode;
			var tnd:DelaunayNode;
			if ( first === e )
			{
				size--;
				tnd = first;
				first = first.next;
				tnd.next = null;
				return;
			}
			nd = first;
			while ( nd!=null )
			{
				if ( nd.next === e )
				{
					size--;
					tnd = nd.next
					nd.next = nd.next.next;
					tnd.next = null;
					return;
				}
				nd = nd.next;
			}
		}
		
		public function apply( f:Function ):void
		{
			var nd:DelaunayNode = first;
			while ( nd!=null )
			{
				f(nd);
				nd = nd.next;
			}
		}
		
		public function deleteElement( e:DelaunayNode ):void
		{
			var nd:DelaunayNode;
			var tnd:DelaunayNode;
			if ( first === e )
			{
				size--;
				nd = first;
				first = first.next;
				deleteNode(nd);
				return;
			}
			nd = first;
			while ( nd!=null )
			{
				if ( nd.next === e )
				{
					size--;
					tnd = nd.next
					nd.next = nd.next.next;
					deleteNode(tnd);
					return;
				}
				nd = nd.next;
			}
		}
		
		public function removeAllElements():void
		{
			while ( first != null )
		 	{
		 		deleteNode(removeFirstElement());
		 	}
		}
		
		public function nearest( x:Number, y:Number):DelaunayNode
	  	{
			if ( first == null ) return null;
		    // locate a node nearest to (px,py)
			var nd:DelaunayNode = first;
			var n:DelaunayNode = nd;
		    dismin = n.squaredDistance(x,y);
		    n = n.next;
			while (n)
			{
				s = n.squaredDistance(x,y);
				if( s < dismin ) 
		    	{ 
		    		dismin = s;
		    		nd = n;
		    	}
				n = n.next;
			}
			return nd;
	  }
	  
	  public function drawPoints( g:Graphics, fixedToo:Boolean, colorMap:BitmapData = null ):void
	  {
		  var nd:DelaunayNode = first;
		  while ( nd!=null )
		  {
				nd.draw(g,fixedToo, colorMap);
				nd = nd.next;
		  }
	  	
	  }
	
	  public function updateSprites():void
	  {
		  var nd:DelaunayNode = first;
			while ( nd!=null )
			{
				nd.data.updateView();
				nd = nd.next;
			}
	  }
	  
	  public function updateData( mode:String ):void
	  {
		  var nd:DelaunayNode = first;
	  		while ( nd!=null )
			{
				if ( nd.data ) nd.data.update( mode );
				nd = nd.next;
			}
	  	
	  }
	  
	  public function getVectors( ignoreOuterTriangle:Boolean = true ):Vector.<Vector2>
	  {
		  var result:Vector.<Vector2> = new Vector.<Vector2>()
		  var nd:DelaunayNode = first;
		  var loop:Dictionary = new Dictionary(false);
		  while ( nd!=null )
		  {
			  if ( loop[nd] != null ){
				  trace("ERROR: loop in nodes!");
				  break;
			  } 
			  loop[nd] = true;
			  if ( !(nd.data is BoundingTriangleNodeProperties) || !ignoreOuterTriangle )
			  {
			  	result.push( new Vector2(nd.x,nd.y) );
			  }  
			  nd = nd.next;
		  }
		  return result;
	  }
	  
	 
	  
	}
			
}