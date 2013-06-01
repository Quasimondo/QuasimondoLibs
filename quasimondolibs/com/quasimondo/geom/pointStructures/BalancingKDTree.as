package com.quasimondo.geom.pointStructures
{
	/*
		Based on code by Ralph Hauwert 
		http://www.unitzeroone.com
	*/
	
	import com.quasimondo.geom.Vector2;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class BalancingKDTree
	{
		private var firstNode:KDTreeNode;
		
		public function BalancingKDTree(){}
		
		public function insertPoint( point:Vector2, rebalance:Boolean = false, minRatio:Number = 0.2 ):void
		{
			if ( firstNode == null )
			{
				firstNode = new KDTreeNode();
				firstNode.depth = 0;
				firstNode.point = point;
			} else {
				var newNode:KDTreeNode = insertNode(point, firstNode );
				if ( rebalance ) checkNodeBalanceBottomUp( minRatio, newNode, null );
			}
		}
		
		public function insertPoints( points:Vector.<Vector2>, rebalance:Boolean = false, minRatio:Number = 0.2 ):void
		{
			if ( firstNode == null )
			{
				firstNode = new KDTreeNode();
				buildDepth( points.concat(), firstNode, 0 );
			} else {
				for each ( var point:Vector2 in points )
				{
					insertPoint( point );
				}
				if ( rebalance ) this.rebalance( minRatio );
			}
		}
		
		public function removePoint( point:Vector2, rebalance:Boolean = false, minRatio:Number = 0.2 ):void
		{
			if ( firstNode == null ) return;
			
			var node:KDTreeNode = findPoint( point, firstNode );
			if ( node == null ) return;
			var collector:Vector.<Vector2> = new Vector.<Vector2>();
			if ( node.parent == null )
			{
				firstNode = null;
			} else if ( node.parent.parent == null)
			{
				getPoints( node.parent, node, collector );
				firstNode = new KDTreeNode();
				firstNode.depth = 0;
				firstNode.point = collector[0];
			} else {
				node.parent.count--;
				getPoints( node.parent.parent, node, collector );
				buildDepth( collector, node.parent.parent, node.parent.parent.depth );
				if ( rebalance ) checkNodeBalanceBottomUp( minRatio, node.parent.parent, null );
			}
		}
		
		public function removeNearest( point:Vector2, rebalance:Boolean = false, minRatio:Number = 0.2 ):void
		{
			if ( firstNode == null ) return;
			
			var collector:Vector.<Vector2> = new Vector.<Vector2>();
			var node:KDTreeNode = findNearestForNode(point,firstNode);
			if ( node.parent == null )
			{
				firstNode = null;
			} else if ( node.parent.parent == null)
			{
				getPoints( node.parent, node, collector );
				firstNode = new KDTreeNode();
				firstNode.depth = 0;
				firstNode.point = collector[0];
			} else {
				node.parent.count--;
				getPoints( node.parent.parent, node, collector );
				buildDepth( collector, node.parent.parent, node.parent.parent.depth );
				if ( rebalance ) checkNodeBalanceBottomUp( minRatio, node.parent.parent, null );
			}
		}
		
		public function rebalance( minRatio:Number = 0.2 ):void
		{
			if ( firstNode == null ) return;
			checkNodeBalanceTopDown( minRatio, firstNode );
		}
		
		private function checkNodeBalanceTopDown( minRatio:Number, node:KDTreeNode ):void
		{
			if ( node.left && node.right )
			{
				var ratio:Number = Math.min( node.left.count, node.right.count ) /  Math.max( node.left.count, node.right.count );
				if ( ratio < minRatio )
				{
					rebalanceNode( node );
				} else {
					checkNodeBalanceTopDown( minRatio, node.left );
					checkNodeBalanceTopDown( minRatio, node.right );
				}
			} else if ( node.left ){
				if (  node.left.count > 1 )
				{
					rebalanceNode( node );
				}
			} else if ( node.right ){
				if (  node.right.count > 1 )
				{
					rebalanceNode( node );
				}
			}
		}
		
		private function checkNodeBalanceBottomUp( minRatio:Number, checkNode:KDTreeNode, balanceNode:KDTreeNode ):void
		{
			if ( checkNode == null )
			{
				if ( balanceNode != null ) rebalanceNode( balanceNode );
			} else {
				if ( checkNode.left && checkNode.right )
				{
					var ratio:Number = Math.min( checkNode.left.count, checkNode.right.count ) /  Math.max( checkNode.left.count, checkNode.right.count );
					checkNodeBalanceBottomUp( minRatio, checkNode.parent, ratio < minRatio ? checkNode : balanceNode );
				} else if ( checkNode.left ){
					checkNodeBalanceBottomUp( minRatio, checkNode.parent, checkNode.left.count > 1 ? checkNode : balanceNode );
				} else if ( checkNode.right ){
					checkNodeBalanceBottomUp( minRatio, checkNode.parent, checkNode.right.count > 1 ? checkNode : balanceNode );
				} else {
					checkNodeBalanceBottomUp( minRatio, checkNode.parent, balanceNode );
				}
			}
		}
		
		private function rebalanceNode( node:KDTreeNode ):void
		{
			var collector:Vector.<Vector2>  = new Vector.<Vector2>();
			
			if ( node.parent != null )
			{
				getPoints( node.parent, null, collector );
				buildDepth( collector, node.parent, node.parent.depth );
			} else {
				getPoints( firstNode, null, collector );
				firstNode = null;
				insertPoints( collector );
			}
		}
		
		private function insertNode( point:Vector2, node:KDTreeNode ):KDTreeNode
		{
			var insertedNode:KDTreeNode;
			
			if ( node.depth & 1 ? (point.y < node.point.y) : (point.x < node.point.x) )
			{
				if ( node.left )
				{
					node.count++;
					insertedNode = insertNode( point, node.left );
				} else if ( point.x != node.point.x || point.y != node.point.y )
				{
					node.count += 2;
					
					node.left = new KDTreeNode();
					node.left.parent = node;
					node.left.depth = node.depth + 1;
					node.left.point = point;
					
					node.right = new KDTreeNode();
					node.right.parent = node;
					node.right.depth = node.depth + 1;
					node.right.point = node.point;
					
					insertedNode = node.left;
					
				}
			} else {
				
				if ( node.right )
				{
					node.count++;
					insertedNode = insertNode( point, node.right );
				} else if ( point.x != node.point.x || point.y != node.point.y )
				{
					node.count += 2;
					
					node.left = new KDTreeNode();
					node.left.parent = node;
					node.left.depth = node.depth + 1;
					node.left.point = node.point;
					
					node.right = new KDTreeNode();
					node.right.parent = node;
					node.right.depth = node.depth + 1;
					node.right.point = point;
					
					insertedNode = node.right;
				}
			}
			
			return insertedNode;
		}
		
		
		private function buildDepth( points:Vector.<Vector2>, node:KDTreeNode, depth:int):void
		{
			node.depth = depth;
			if( points.length == 1 )
			{
				node.point = points[0];//If there are no more then 1 point for this node, let's keep it and make this an end node.
			} else {
				points.sort( depth & 1 ? sortY : sortX);//This can be higly optimized.	
				
				//This can be higly optimized.hm
				var half:int = int(points.length >> 1);
				var other:Vector.<Vector2> = points.splice(half,points.length-half);
				node.point = points[points.length-1];//This point will be the middle point.
					
				//Build the other nodes with the other 2 halves.
				if ( points.length > 0 )
				{
					node.count++;
					node.left = new KDTreeNode();
					node.left.parent = node;
					buildDepth(points, node.left, depth+1);
				}
				if (other.length > 0 )
				{
					node.count++;
					node.right = new KDTreeNode();
					node.right.parent = node;
					buildDepth(other, node.right, depth+1);
				}
				
				
			}	
		}
		
		public function findNearestFor(point:Vector2):KDTreeNode
		{
			if ( firstNode == null ) return null;
			return findNearestForNode(point,firstNode);
		}
		
		private function findNearestForNode(point:Vector2, node:KDTreeNode):KDTreeNode
		{
			if( node.left && node.right)
			{
				var side:int;
				var dist:Number;
				var sideA:KDTreeNode;
				var sideB:KDTreeNode;
				var nodeA:KDTreeNode;
				var nodeB:KDTreeNode;
				
				
				side = ( node.depth & 1 ) ? node.point.y - point.y : node.point.x - point.x;
				
				if(side <= 0){
					sideA = node.right;
					sideB = node.left;
				}else{
					sideA = node.left;
					sideB = node.right;
				}
				
				nodeA = findNearestForNode( point, sideA );//Traversal like this is costly in actionscript, so you could stack them and process them in one function instead.
				dist = nodeA.dist;
				
				if( dist < side*side){//Does it overlap a boundary ? 
					return nodeA;
				}else{
					nodeB = findNearestForNode(point, sideB );//Traversal like this is costly in actionscript, so you could stack them and process them in one function instead.
				}
				if(nodeB.dist < dist){//Get the shortest dist.
					return nodeB;
				}else{
					return nodeA;
				}
			} else if (node.left )
			{
				return findNearestForNode( point, node.left )
			} else if ( node.right )
			{
				return findNearestForNode( point, node.right )
			} else {
				node.dist = node.point.squaredDistanceToVector( point )
				return node;
			}
			return null;
		}
		
		
		private function findPoint(point:Vector2, node:KDTreeNode):KDTreeNode
		{
			if( node.left && node.right)
			{
				var nodeA:KDTreeNode = findPoint( point, node.left );//Traversal like this is costly in actionscript, so you could stack them and process them in one function instead.
				if ( nodeA != null ) return nodeA;
				var nodeB:KDTreeNode = findPoint(point, node.right );//Traversal like this is costly in actionscript, so you could stack them and process them in one function instead.
				if ( nodeB != null ) return nodeB;
			} else if (node.left )
			{
				return findPoint( point, node.left )
			} else if ( node.right )
			{
				return findPoint( point, node.right )
			} else {
				if ( node.point == point ) return node;
			}
			return null;
		}
		
		private function sortX(a:Vector2, b:Vector2):int
		{
			if(a.x > b.x){
				return 1;
			}
			return -1;
		}
		
		private function sortY(a:Vector2, b:Vector2):int
		{
			if(a.y > b.y){
				return 1;
			}
			return -1;
		}
		
		
		private function getPoints( node:KDTreeNode, ignore:KDTreeNode, collector:Vector.<Vector2> ):void
		{
			if(!node.left || !node.right)
			{
				if ( node != ignore ) collector.push(  node.point );
			} else {
				getPoints( node.left, ignore, collector );
				getPoints( node.right, ignore, collector );
			}
		}
		
		public function draw( bounds:Rectangle, canvas:Graphics ):void
		{
			canvas.drawRect(bounds.x,bounds.y,bounds.width,bounds.height)
			if ( firstNode != null ) drawNode( firstNode, bounds, canvas );
		}
		
		private function drawNode( node:KDTreeNode, bounds:Rectangle, canvas:Graphics ):void
		{
			if ( !node.left || !node.right ) canvas.drawCircle( node.point.x, node.point.y, 2 );
			if( node.depth & 1)
			{
				canvas.moveTo( bounds.x, node.point.y );
				canvas.lineTo( bounds.x + bounds.width, node.point.y );
				if ( node.left )
				{
					drawNode( node.left, new Rectangle(bounds.x, bounds.y, bounds.width ,node.point.y - bounds.y), canvas );
				} 
				if ( node.right )
				{
					drawNode( node.right, new Rectangle(bounds.x, node.point.y, bounds.width, bounds.y + bounds.height - node.point.y ), canvas );
				}
				
			} else{
				canvas.moveTo( node.point.x, bounds.y  );
				canvas.lineTo( node.point.x, bounds.y + bounds.height );
				if ( node.left )
				{
					drawNode( node.left, new Rectangle(bounds.x, bounds.y, node.point.x - bounds.x, bounds.height), canvas );
				} 
				if ( node.right )
				{
					drawNode( node.right, new Rectangle( node.point.x, bounds.y, bounds.x + bounds.width - node.point.x, bounds.height ), canvas );
				}
				
			}
		}
	}
}

