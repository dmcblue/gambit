package dmcblue.gambit;

import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.Position;
import dmcblue.gambit.error.NotIslandError;
import dmcblue.gambit.error.OccupiedSpaceError;
import interealmGames.common.errors.Error;

using StringTools;

class Board {
	/**
		Accepts a 32 character string with each successive
		rows of the board being its contents.
		0's are empty spaces,
		1's are the one player,
		2's are the opposing player.
		example:
			'00000000' +
			'11111111' +
			'22222222' +
			'00000000'
	**/
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

	/**
		Creates a board with all pieces in their starting positions
	**/
	static public function newGame():Board {
		var str =
			'00000000' +
			'11111111' +
			'22222222' +
			'00000000';
		var board = Board.fromString(str);
		return board;
	}

	/**
		The pieces in each location.
		The first array/index is the y coordinate.
		The inner array/index is the x coordinate.
	**/
	public var board: Array<Array<Piece>>;

	public function new() {
		this.board = [for(y in 0...4)[
			for (x in 0...8) Piece.NONE
		]];
	}

	/**
		Calculates the current score for a player
	**/
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

	/**
		Given a position, returns all positions that form an island with that
		position (including the given position).
		Islands are groups of adjacent positions that all share the same Piece/Team.
		@throws NotIslandError if the island has mixed Pieces/Teams OR if
			the starting position does not have a legitimate Piece.
	**/
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
		if(team == Piece.NONE) {
			throw new NotIslandError(position);
		}
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
							positionsChecked.set(testPosition.toString(), false);
						} else { // opposing team
							throw new NotIslandError(testPosition);
						}
					}
				}
			}
		}

		return island;
	}

	/**
		Given a position, returns all possible moves (positions to move to)
		that the piece at that location can make. If there is no piece at
		that location, will return an empty array.
	**/
	public function getMoves(position:Position) {
		var moves:Array<Position> = [];
		var piece:Piece = this.pieceAt(position);
		if (piece == Piece.NONE) {
			return [];
		}
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

	/**
		Returns all Positions for one player currently on the board
	**/
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

	/**
		Returns the positions of pieces for a player that have possible moves.
	**/
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

	/**
		Whether a player has any available moves to make
	**/
	public function hasAnyMoreMoves(team:Piece):Bool {
		var positions = this.getPositions(team);
		for(position in positions) {
			if(this.getMoves(position).length > 0) {
				return true;
			}
		}

		return false;
	}

	/**
		Helper function that returns whether a postion is on the board
	**/
	public function isInBounds(position:Position) {
		return position.x > -1 && position.x < this.board[0].length
			&& position.y > -1 && position.y < this.board.length;
	}

	/**
		Determines if a move is valid
		@TODO Should this be in the Board class?
	**/
	// public function isValidMove(move:Move):Null<Error> {
	public function isValidMove(move:Move):Bool {
		var start = this.pieceAt(move.from);
		// if (start != this.currentPlayer) {
		// 	return new WrongTeamError(start);
		// }
		var end = this.pieceAt(move.to);
		if (end != Piece.NONE) {
			//return new OccupiedSpaceError(move.to, end);
			return false;
		}

		var distX = Math.abs(move.from.x - move.to.x);
		var distY = Math.abs(move.from.y - move.to.y);
		if (Std.int(Math.max(distX, distY)) != 2) {
			return false;
		}

		if (distX == 1 || distY == 1) {
			return false;
		}

		var midPoint = this.midPoint(move.from, move.to);
		if (this.pieceAt(midPoint) != (start == Piece.BLACK ? Piece.WHITE : Piece.BLACK)) {
			return false;
		}

		// return null;
		return true;
	}

	/**
		Returns the position between two other positions.
		Assumes the two input positions are at least two spaces apart.
	**/
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

	/**
		Moves a piece from one position to another
		Removes the piece that is jumped over.
		@throws OccupiedSpaceError if the destination is currently occupied.
	**/
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

	/**
		Gets the Piece/Player/Team occupying a particular position on the board
	**/
	public function pieceAt(position:Position) {
		return this.board[position.y][position.x];
	}

	/**
		Converts the board to a readable format.
		0's are empty spaces,
		1's are the one player,
		2's are the opposing player.
		example:
			'00000000' +
			'11111111' +
			'22222222' +
			'00000000'
	**/
	public function toString() {
		var str = '';
		for(rows in this.board) {
			for(cell in rows) {
				str += PieceTools.toString(cell);
			}
		}
		return str;
	}
}
