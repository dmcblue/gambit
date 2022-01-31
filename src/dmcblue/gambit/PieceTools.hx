package dmcblue.gambit;

class PieceTools {
	static public function toString(piece: Piece): String {
		return switch(piece) {
			case Piece.NONE: '0';
			case Piece.WHITE: '1';
			case Piece.BLACK: '2';
			default: '0';
		};
	}

	static public function fromString(s:String): Piece {
		return switch(s) {
			case '0': Piece.NONE;
			case '1': Piece.WHITE;
			case '2': Piece.BLACK;
			default: Piece.NONE;
		};
	}
}
