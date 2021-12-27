package dmcblue.gambit;

// enum Piece {
// 	NONE;
// 	WHITE;
// 	BLACK;
// }

@:enum abstract Piece(Int) to Int {
	var NONE = 0;
	var WHITE = 1;
	var BLACK = 2;
}
