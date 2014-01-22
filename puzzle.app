@ = require(['mho:std', 'mho:app'])

// Puzzle layout
//
//  <---width--->
//
//	|--xpos-->
//
//	+---+---+---+ 	 - 		^
//	| 1 | 2 | 3 | 	 |   	|
//	+---+---+---+	ypos	|
//	| 4 | 5 | 6 |  	 |	  height
//	+---+---+---+    |		|
//	| 7 | 8 | 9 |    v		|
//	+---+---+---+    		v

//----------------------------------------------------------------
//config
var puzzlesrc = "http://upload.wikimedia.org/wikipedia/commons/1/1a/Bachalpseeflowers.jpg";
var puzzlesize = {
	tilesize: 170, 	//square
	width: 4, 		//tiles
	height: 3, 		//tiles
};

//----------------------------------------------------------------
//puzzle state
var pieces = []; //contains all pieces
var grabInfo = {
	pid: -1,
	sx: 0, //start position of cursor
	sy: 0,
}

//----------------------------------------------------------------
// build the puzzle

for (var i = 0; i < (puzzlesize.width * puzzlesize.height); i++){
	//calc coord in the grid
	xpos = (i%puzzlesize.width);
	ypos = (i-(i%puzzlesize.width))/puzzlesize.width;
	
	// model which hold piece state
	var piece = {
			x : @ObservableVar( puzzlesize.tilesize * xpos ),
			y : @ObservableVar( puzzlesize.tilesize * ypos ),		
		};
		
	//create img tag to be placed in the pieceElement, with appropriate offset
	var image = @Img({src: puzzlesrc}) 
		.. @Attrib('draggable', 'false') //this prevents users (in modern browsers) to drag out the image file
		.. @Style("{
			margin-left: -#{piece.x.get()}px;
			margin-top: -#{piece.y.get()}px;
		}");

	//create piece element to be placed in document 
	var pieceElement = @Div(image)
		//piece index, to find associated model, there might be a nicer way to associate oneanother
		.. @Prop('pid', i) 
		//quasi style which 'observes' the piece model
		.. @Style(`{ 
			position: absolute;
			width: ${puzzlesize.tilesize}px;
			height: ${puzzlesize.tilesize}px;
			overflow: hidden;
			left: ${piece.x}px;
			top: ${piece.y}px;
		}`)
		//function bound to this piece to initiate a drag
		.. @Mechanism(function(d){
			d .. @when('mousedown'){
				|event|
				// console.log("grep: #{d.pid}");
				grabInfo.pid = d.pid; //reference the piece being dragged
				// store inital position
				grabInfo.sx = event.x - pieces[d.pid].x.get(); 
				grabInfo.sy = event.y - pieces[d.pid].y.get(); 		
				console.log(pieces[d.pid]);	
			}
		});
	//add the piece model to pieces
	pieces.push(piece);
	//add the pieceElement to the document
	@mainContent .. @appendContent(pieceElement);
}

//add mousemove & mouseup eventlisteners to the document
// note that execution will stop after waitfor{}or{} until either stops
// not sure how to add them nicely whilst preventing this (like with the @Mechanism)  
waitfor {
	document .. @when('mousemove'){
		|event|
		if (grabInfo.pid > -1){
			//if any piece is being dragged, update its position accordingly
			pieces[grabInfo.pid].x.modify(x -> (event.x - grabInfo.sx));
			pieces[grabInfo.pid].y.modify(y -> (event.y - grabInfo.sy));
		}
	};
} or {
	document .. @when('mouseup'){
		|event|
		//reset grabbed piece information
		// console.log('release');
		grabInfo.pid = -1;
		grabInfo.sx = 0;
		grabInfo.sy = 0;			
	};
}