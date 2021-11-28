package dmcblue.gambit;

import dmcblue.gambit.Position;
import dmcblue.gambit.errors.OccupiedSpaceError;
import dmcblue.gambit.errors.WrongTeamError;
import dmcblue.gambit.Board;
import dmcblue.gambit.Display;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import interealmGames.common.errors.Error;

class Game {
	public var board:Board;
	public var currentPlayer:Piece;
	public var display:Display;

	public function new(display:Display, ?startingPlayer:Piece = Piece.WHITE) {
		this.currentPlayer = startingPlayer;
		this.display = display;
	}

	// should be in Board?
	public function isValidMove(move:Move):Null<Error> {
		var start = this.board.pieceAt(move.from);
		if (start != this.currentPlayer) {
			return new WrongTeamError(start);
		}
		var end = this.board.pieceAt(move.to);
		if (end != Piece.NONE) {
			return new OccupiedSpaceError(move.to, end);
		}

		return null;
	}

	public function getNextMove(positions:Array<Position>):Null<Move> {
		var hasMoves = false;
		for(position in positions) {
			hasMoves = hasMoves || this.board.getMoves(position).length > 0;
		}

		if (!hasMoves) {
			return null;
		}

		var move: Move = {
			from: new Position(0, 0),
			to: new Position(0, 0)
		};
		var isValidMove:Bool = false;
		while (isValidMove == false) {
			move = this.display.requestNextMove(
				this.currentPlayer,
				positions,
				this
			);
			if (move == null) {
				return null;
			}

			var error = this.isValidMove(move);
			if (error == null) {
				isValidMove = true;
			} else {
				this.display.displayError(error);
			}
		}

		return move;
	}

	public function getFollowUpMove(position:Position) {
		var move: Move = {
			from: new Position(0, 0),
			to: new Position(0, 0)
		};
		var isValidMove:Bool = false;
		while (isValidMove == false) {
			move = this.display.requestFollowUpMove(
				this.currentPlayer,
				position,
				this.board.getMoves(position),
				this
			);

			if (move == null) {
				return null;
			}

			var error = this.isValidMove(move);
			if (error == null) {
				isValidMove = true;
			} else {
				this.display.displayError(error);
			}
		}

		return move;
	}

	// this should be part of an interface and the display be changed accordingly
	public function getMoves(position:Position):Array<Position> {
		return this.board.getMoves(position);
	}

	public function run() {
		var playing = true;
		while (playing) {
			this.board = Board.newGame();
			while(!this.board.isOver()) {
				var move = this.getNextMove(this.board.getPositionsWithMoves(this.currentPlayer));
				if (move != null) {
					var currentMove = move.to;
					// run next move
					this.board.move(move);

					// check if more moves
					var moves = this.board.getMoves(currentMove);
					while (moves.length > 0) {
						var move = this.getFollowUpMove(currentMove);
						if (move != null) {
							this.board.move(move);
							currentMove = move.to;
							moves = this.board.getMoves(currentMove);
						} else {
							moves = [];
						}
					}
				}

				// change player
				this.currentPlayer = this.currentPlayer == Piece.WHITE ? Piece.BLACK : Piece.WHITE;
			}

			var scores:Map<Piece, Int> = new Map();
			scores.set(Piece.BLACK, this.board.calculateScore(Piece.BLACK));
			scores.set(Piece.WHITE, this.board.calculateScore(Piece.WHITE));
			this.display.endGame(scores, this.board);
			playing = this.display.playAgain();
		}
	}
}
