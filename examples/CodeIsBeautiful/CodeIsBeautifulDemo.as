// Code is Beautiful 
// for Adobe Flash Camp 2010
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2006-2010 Mario Klingemann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package {
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.quasimondo.delaunay.Delaunay;
	import com.quasimondo.geom.CompoundShape;
	import com.quasimondo.geom.DrawingApiToPath;
	import com.quasimondo.geom.LineSegment;
	import com.quasimondo.geom.LinearPath;
	import com.quasimondo.geom.MixedPath;
	import com.quasimondo.geom.Quasimondo_AS3SWF_PathExporter;
	import com.quasimondo.geom.Vector2;
	import com.quasimondo.presentation.PresentationDemo;
	
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	
	[SWF( width="1024",height="768",framerate="60",backgroundColor="#000000")]
	public class CodeIsBeautifulDemo extends PresentationDemo
	{
		// This contains the "Code is Beautiful" shape
		[Embed (source="assets/CodeIsBeautifulAssets.swf", mimeType="application/octet-stream")]
		public static const Assets:Class;
		
		private var delaunay:Delaunay;
		private var shape:CompoundShape;
		private var nextShapeIndex:int;
		private var nextPointIndex:int;
		private var currentPath:LinearPath;
		
		public function CodeIsBeautifulDemo()
		{}
		
		override public function start( ):void
		{
			process();
		}
		
		override public function end( ):void
		{
			process();
		}
		
		/*
			In order to make the construction process a bit easier to
			see, I separated it into several steps. For the final
			result this is not really necessesary but it is nicer
			to look at.
		*/
		private function process(step:int = 0):void
		{
			switch (step)
			{
				case 0:
					extraxtShape();
					prepareDelaunay();
					renderDelaunay()
					setTimeout(	process,1000,1);
				break;
				case 1:
					nextShapeIndex = 0;
					nextPointIndex = 0;
					insertShapeIntoDelaunay();
				break;
				case 2:
					randomizeRays();
				break;
			}
		}
		
		
		/*
			First I use the VectorShapes class by Guojian Miguel Wu to
			extract the "Code Is Beautiful" shape from the
			stage of the first frame of the swf.
		
			VectorShapes was actually written for Away3D to
			create type extrusions, so I had to write my
			own class DrawingApiToPath which will behave
			like a Graphics object but will log all the
			drawingAPI calls made to it and extract
		    CompoundShape objects from it.
		
			CompoundShapes are geometric objects that
			can consist out of several paths whereas
			each path can contain a mix of lines and
			curves. Nasty to work with if you want
			to do further geometric operations on it
		
		*/
		
		private function extraxtShape():void
		{
			var swf:SWF = new SWF( new Assets() as ByteArray);
			var logger:Quasimondo_AS3SWF_PathExporter = new Quasimondo_AS3SWF_PathExporter(swf);
			
			for (var i:uint = 0; i < swf.tags.length; i++) {
				var tag:ITag = swf.tags[i];
				// Check if tag is a DefineShape
				if (tag is TagDefineShape) {
					// Export shape
					TagDefineShape(tag).export(logger);
				}
			}

			shape = logger.shape;
		}
		
		/*
			This step is just for documenting the progress. It will
			draw the extracted CompoundShapes.
		
			As you can see each Compound Shape consists out of one or more
			MixedPath objects. A MixedPath an open or closed path that
		    can be assembled from lines, quadratic and/or cubic bezier
			segments.
		*/
		private function renderShape():void
		{
			graphics.clear();
			graphics.lineStyle(0,0xffffff,1,false,"normal",CapsStyle.SQUARE);
			for ( var i:int = 0; i < shape.shapeCount; i++ )
			{
				var path:MixedPath = MixedPath( shape.getShapeAt( i ) );
				path.draw( graphics );
			}
		}
		
		/*
			In this step a Delaunay triangulation is prepared
			in this case it will be created from 300 points
			that are arranged in a circle of radius 29000
			around the center. This will later create the rays
			once we create a Voronoi diagram from the delaunay
		*/
		private function prepareDelaunay():void
		{
			delaunay = new Delaunay();
			
			// it is recommended to create and initial triangle which is
			// as big to hold all the later points
			// this reduces the risk of ending up with bad
			// point configurations
			delaunay.createBoundingTriangle(550,900);
			
			for ( var i:int = 0; i < 300; i++ )
			{
				delaunay.insertXY( 512 + 2900 * Math.cos( i * Math.PI * 2 /  300) , 384 + 2900 * Math.sin( i * Math.PI * 2 / 300 ), new ABDelaunayNodeProperties(i));
			}
		}
		
		/*
			Here you can see the ray Voronois
		*/
		private function renderDelaunay():void
		{
			graphics.clear();
			graphics.lineStyle(0,0xffffff,1,false,"normal",CapsStyle.SQUARE);
			delaunay.drawVoronoiDiagram( graphics );
		}
			
		
		/*
			In this step we will move along the outline of the 
			"Code is Beautiful" type and insert points in a
			certain stepsize into the Voronoi diagram
			In order to watch the process I actually split the
			whole process into little chunks
		
			
		*/
		private function insertShapeIntoDelaunay():void
		{
			var t:int = getTimer();
			
			var r:Rectangle = shape.getBoundingRect();
			var offset:Vector2 = new Vector2( 512 - r.width * 0.5 + r.x, 384 - r.height * 0.5 + r.y) ;
			
			
			while ( nextShapeIndex < shape.shapeCount )
			{
				var path:MixedPath = MixedPath( shape.getShapeAt( nextShapeIndex ) );
							
				if ( path.isValidPath() )
				{
					// since a MixedPath can contain a mixture of curves and lines
					// in this step we convert it into a LinearPath which just consists
					// of line segments. In this case they should be approximately 4 pixels long
					if ( currentPath == null ) currentPath = path.toLinearPath( 4 );
					while ( nextPointIndex < currentPath.pointCount  )
					{
						delaunay.insertXY( currentPath.points[nextPointIndex].x-200 + offset.x, currentPath.points[nextPointIndex].y-200+ offset.y, new ABDelaunayNodeProperties(nextPointIndex));
						nextPointIndex++;
						if ( getTimer() - t > 3 )
						{
							renderDelaunay();
							setTimeout(	insertShapeIntoDelaunay,2);
							return;
						}
					}
				}
				currentPath = null;
				nextShapeIndex++;
				nextPointIndex = 0;
			}
			
			setTimeout(	process,200,2);
			
		}
		
		/*
			in the last step the rays are shortened to give the sunburst effect
			therefore only lines that have points that are outside of the viewing rect
			are considered and shortened to a random length between 50% and 100%
			of their original length
		*/
		private function randomizeRays():void
		{
			graphics.clear();
			graphics.lineStyle( 0,0xffffff,1,false,"normal",CapsStyle.SQUARE);	
			
			var lines:Vector.<LineSegment> = delaunay.getVoronoiLines();
			var fullRect:Rectangle = new Rectangle( 50, 50, 924,668 );
			for each ( var line:LineSegment in lines )
			{
				if( !fullRect.contains( line.p1.x, line.p1.y ) )
				{
					line.p1.lerp( line.p2, 0.5 + Math.random() * 0.5);
				} else if ( !fullRect.contains( line.p2.x, line.p2.y ) ) 
				{
					line.p2.lerp( line.p1, 0.5 + Math.random() * 0.5);
				} 
				
				if( !fullRect.contains( line.p1.x, line.p1.y ) )
				{
					line.p1.lerp( line.p2, 0.5 + Math.random() * 0.5);
				} else if ( !fullRect.contains( line.p2.x, line.p2.y ) ) 
				{
					line.p2.lerp( line.p1, 0.5 + Math.random() * 0.5);
				} 
				
				line.draw( graphics );
			}
		}
		
		
	}
}
