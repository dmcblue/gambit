package dmcblue.gambit;

import dmcblue.gambit.PieceTools;
import dmcblue.gambit.errors.NotIslandError;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.errors.NotIslandError;
import dmcblue.gambit.errors.OccupiedSpaceError;

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

	public function getPositionsWithMoves(team:Piece):Array<Position> {
		var positions = this.getPositions(team);
		var positionsWithMoves:Array<Position> = [];
		for(position in positions) {
			var moves = this.getMoves(position);
			if (moves.length > 0) {
				positionsWithMoves.push(position);
			}
		}

		return positionsWithMoves;
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

	public function move(move:Move) {
		var end = this.pieceAt(move.to);
		if (end != Piece.NONE) {
			throw new OccupiedSpaceError(move.to, end);
		}

		var middle = this.midPoint(move.from, move.to);
		this.board[middle.y][middle.x] = Piece.NONE;

		this.board[move.to.y][move.to.x] = this.board[move.from.y][move.from.x];
		this.board[move.from.y][move.from.x] = Piece.NONE;
	}

	public function pieceAt(position:Position) {
		return this.board[position.y][position.x];
	}

	public function isOver() {
		return !this.hasAnyMoreMoves(Piece.WHITE) && !this.hasAnyMoreMoves(Piece.BLACK);
	}

	public function hasAnyMoreMoves(team:Piece):Bool {
		var positions = this.getPositions(team);
		for(position in positions) {
			if(this.getMoves(position).length > 0) {
				return true;
			}
		}

		return false;
	}

	public function calculateScore(team:Piece):Int {
		var score = 0;
		var positions = this.getPositions(team);
		var checkedPositions = new Map<String, Bool>();
		for(position in positions) {
			if (!checkedPositions.exists(position.toString())) {
				checkedPositions.set(position.toString(), true);

				try {
					var island = this.getIsland(position);
					for(p in island) {
						checkedPositions.set(p.toString(), true);
					}
					score += switch island.length {
						case 1: 1;
						case 2: 3;
						case 3: 5;
						case 4: 7;
						case 5: 9;
						default: 0;
					}
				} catch(error:NotIslandError) {
					continue;
				}
			}
		}

		return score;
	}

	public function getIsland(position:Position):Array<Position> {
		var surroundingPositions:Array<Position> = [
			new Position(-1, -1),
			new Position(0, -1),
			new Position(1, -1),
			new Position(-1, 0),
			new Position(1, 0),
			new Position(-1, 1),
			new Position(0, 1),
			new Position(1, 1)
		];
		var positionsChecked = new Map<String, Bool>();
		var positionsToCheck = [position];
		var island = [position];
		var inIsland = new Map<String, Bool>();
		inIsland.set(position.toString(), true);
		var team = this.pieceAt(position);
		while(positionsToCheck.length > 0) {
			var positionBeingChecked = positionsToCheck.shift();
			if (!positionsChecked.exists(positionBeingChecked.toString())) {
				positionsChecked.set(positionBeingChecked.toString(), true);

				for(offset in surroundingPositions) {
					var testPosition = positionBeingChecked + offset;

					if(this.isInBounds(testPosition)) {
						var adjacentTeam = this.pieceAt(testPosition);
						if (adjacentTeam == team) {
							if (!inIsland.exists(testPosition.toString())) {
								island.push(testPosition);
								inIsland.set(testPosition.toString(), true);
							}
							positionsToCheck.push(testPosition);
						} else if (adjacentTeam == Piece.NONE) {
							positionsChecked.set(testPosition.toString(), false); // i don't know if I need to do anything
						} else { // opposing team
							throw new NotIslandError(testPosition);
						}
					}
				}
			}
		}

		return island;
	}

	public function toString() {
		var str = '';
		for(rows in this.board) {
			for(cell in rows) {
				str += PieceTools.toString(cell);
			}
			str += "\n";
		}
		return str;
	}
}
