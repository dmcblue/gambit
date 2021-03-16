package dmcblue.gambit;

import haxe.iterators.StringKeyValueIteratorUnicode;

using StringTools;

class Board {
	static public function fromString(str:String):Board {
		var board = new Board();
		for(i in 0...str.length) {
			var c = str.charAt(i);
			var y = Math.floor(i / 8);
			var x = i % 8;
			board.board[y][x] = PieceTools.fromString(c);
		}
		return board;
	}

	static public function newGame():Board {
		var str =
			'00000000' +
			'11111111' +
			'22222222' +
			'00000000';
		var board = Board.fromString(str);
		return board;
	}

	public var board: Array<Array<Piece>>;
	public function new() {
		this.board = [for(y in 0...4)[
			for (x in 0...8) Piece.NONE
		]];
	}

	public function getPositions(team:Piece): Array<Position> {
		var positions = [];
		if (team == Piece.NONE) {
			return positions;
		}


		for(i => row in this.board) {
			for (j => cell in row) {
				if (cell == team) {
					positions.push({ x: j, y: i });
				}
			}
		}

		return positions;
	}

	public function getMoves(position:Position) {
		var moves:Array<Position> = [];
		// any diagonal
		for (i in (position.x - 1)...(position.x + 2)) {
			if (i > -1 && i < this.board.length) {
				for (j in (position.y - 1)...(position.y + 2)) {
					if (j > -1 && j < this.board[i].length) {
						if (this.board[i][j] == Piece.NONE) {
							moves.push({ x: j, y: i });
						}
					}
				}
			}
		}
		// any jump over an enemy piece


		return moves;
	}

	public function debugString(?position:Position, ?moves:Array<Position>) {
		Sys.println();
		if (position != null) {
		Sys.println('x: ${}')
		}
	}
}
