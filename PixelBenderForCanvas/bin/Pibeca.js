/*

Pibeca - Pixel Bender For Canvas v0.2

Pibeca allows the use of The Adobe® Pixel Bender™ technology
together with Canvas by having the bitmaps processed by
Adobe® Flash™. This tool is not endorsed or supported by Adobe®.

Version: 	0.2
Author:		Mario Klingemann
Contact: 	mario@quasimondo.com
Website:	http://www.quasimondo.com/PixelBenderForCanvas

Copyright (c) 2010 Mario Klingemann

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

var PibecaEngine;
var PibecaLookup;

function initPibeca()
{
	PibecaEngine = document.getElementById( "Pibeca" );
	PibecaLookup = [];
	for ( var i = 0; i < 256; i++ )
	{
		PibecaLookup[i] = String.fromCharCode(i);
	}
	PibecaLookup[0] = String.fromCharCode(1) + String.fromCharCode(1);
	PibecaLookup[1] = String.fromCharCode(1) + String.fromCharCode(2);
}

function filterImage( bitmapID, imageID, canvasID, kernelURL, parameters )
{
 	var img = document.getElementById( imageID );
	var w = img.naturalWidth;
    var h = img.naturalHeight;
       
	var canvas = document.getElementById( canvasID );
      
    canvas.style.width  = w + "px";
    canvas.style.height = h + "px";
    canvas.width = w;
    canvas.height = h;
    
    var context = canvas.getContext("2d");
    context.clearRect( 0, 0, w, h );
    context.drawImage( img, 0, 0 );

	filterCanvas( bitmapID, canvasID, 0, 0, w, h, kernelURL, parameters );
}


function filterCanvas( bitmapID, id, x, y, width, height, kernelURL, parameters )
{
	if ( PibecaEngine == null ) initPibeca();
	
	if ( !PibecaEngine.hasBitmap( bitmapID ) ) 
	{
		var canvas  = document.getElementById( id );
		try {
			var dataURL = canvas.toDataURL("image/png");
			PibecaEngine.setPNG( bitmapID, dataURL.substr(dataURL.indexOf(",")));
		} catch(e) {
			var context = canvas.getContext("2d");
		     
			var imageData;
			try {
			  try {
			    imageData = context.getImageData( x, y, width, height );
			  } catch(e) {
			    netscape.security.PrivilegeManager.enablePrivilege("UniversalBrowserRead");
			    imageData = context.getImageData( x, y, width, height );
			  }
			} catch(e) {
			  throw new Error("unable to access image data: " + e);
			}
			
			var iData = imageData.data;
			var data = "";
			for ( var i = 0; i < iData.length; i+=4 )
			{
				data += PibecaLookup[iData[i+3]];
				data += PibecaLookup[iData[i]];
				data += PibecaLookup[iData[i+1]];
				data += PibecaLookup[iData[i+2]];
			}
			
			PibecaEngine.setBitmap( bitmapID, width, height, data );
		
		}
	}
	
	PibecaEngine.runFilter( bitmapID, id, x, y, kernelURL, parameters );
	
}

function onFilterComplete( canvasID, x, y, width, height, data )
{
	var d;
	var j = 0;
	var i = 0;
	var rpl = [0,0,1];
	
	var cvs = document.getElementById( canvasID );
	var context = cvs.getContext("2d");
	var imageData = context.createImageData( width, height );
	var iData = imageData.data;
	while ( i < data.length )
	{
		iData[j++] = ( ( d = data.charCodeAt(i++) ) != 1 ? d : rpl[ data.charCodeAt(i++) ] );
	}
	
	context.putImageData( imageData, x ,y );
}

function flashLog( msg )
{
	alert(msg);
}