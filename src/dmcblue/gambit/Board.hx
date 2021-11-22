package dmcblue.gambit;

import dmcblue.gambit.Position;
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
					positions.push(new Position(j, i));
				}
			}
		}

		return positions;
	}

	public function getMoves(position:Position) {
		var moves:Array<Position> = [];
		var piece:Piece = this.pieceAt(position);
		// any jump over an enemy piece
		var possibleMoves:Array<Position> = [
			new Position(-2, -2),
			new Position(0, -2),
			new Position(2, -2),
			new Position(-2, 0),
			new Position(2, 0),
			new Position(-2, 2),
			new Position(0, 2),
			new Position(2, 2)
		];
		for (move in possibleMoves) {
			// var destination = new Position(position.x + move.x, position.y + move.y);
			var destination = position + move;
			if (position != destination && this.isInBounds(destination) && this.pieceAt(destination) == Piece.NONE) {
				var middle = this.midPoint(position, destination);
				var middlePiece = this.pieceAt(middle);

				if (middlePiece != piece && middlePiece != Piece.NONE) {
					moves.push(destination);
				}
			}
		}

		return moves;
	}

	public function debugString(?position:Position, ?moves:Array<Position>) {
		// Sys.println();
		if (position != null) {
			Sys.println('x: ${position.x}, y: ${position.y}');
		}
	}

	public function isInBounds(position:Position) {
		return position.x > -1 && position.x < this.board[0].length
			&& position.y > -1 && position.y < this.board.length;
	}

	public function midPoint(here:Position, there:Position):Position {
		var distX = Std.int(Math.abs(Math.floor((here.x - there.x)/2)));
		var distY = Std.int(Math.abs(Math.floor((here.y - there.y)/2)));

		var position = here.clone();
		if (here.x > there.x) {
			position.x = here.x - distX;
		} else if (here.x < there.x) {
			position.x = here.x + distX;
		}

		if (here.y > there.y) {
			position.y = here.y - distY;
		} else if (here.y < there.y) {
			position.y = here.y + distY;
		}

		return position;
	}

	public function pieceAt(position:Position) {
		return this.board[position.y][position.x];
	}
}
