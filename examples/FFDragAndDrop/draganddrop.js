/*
	This code is based in big parts on the example of Paul Rouget 
	on this page:
	http://hacks.mozilla.org/2009/12/file-drag-and-drop-in-firefox-3-6/

*/


var dropArea;
function initDragAndDrop( id ) {
    dropArea = document.getElementById( id );
    dropArea.addEventListener("dragenter", dragenter, true);
    dropArea.addEventListener("dragleave", dragleave, true);
    dropArea.addEventListener("dragover", dragover, true);
    dropArea.addEventListener("drop", drop, true);
}

function dragenter(e) {
 	dropArea.setAttribute("dragenter", true);
 	dropArea.onDragEnter( e.dataTransfer.types  );
}

function dragleave(e) {
    dropArea.removeAttribute("dragenter");
    dropArea.onDragLeave( e.dataTransfer.types  );
}

function dragover(e) {
    e.preventDefault();
    dropArea.onDragOver( e.dataTransfer.types  );
}

function drop(e) {

	var dt = e.dataTransfer;
    var files = dt.files;
	
	e.preventDefault();

	if (files == null) {
        handleData(dt);
        return;
    }

    for (var i = 0; i < files.length; i++) {
        var file = files[i];
        handleFile(file);
    }
	
    return false;
}

function handleData( dt )
{
	dropArea.onDropData( packageData(dt));
}

function packageData( dt )
{
	var data = {};
    for (var i = 0; i < dt.types.length; i++) 
    {
    	data[dt.types[i]] = dt.getData(dt.types[i]);
    }
	return data;
}


function handleFile(file) {
    var reader = new FileReader();
        
    reader.onloadend = function() {
    	dropArea.onDropFile( file.type, reader.result );
        img.src = reader.result;
    }
    reader.readAsBinaryString(file);

   return true;
}

