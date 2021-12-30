package dmcblue.gambit;

import dmcblue.gambit.Position;
import dmcblue.gambit.errors.OccupiedSpaceError;
import dmcblue.gambit.errors.WrongTeamError;
import dmcblue.gambit.Board;
import dmcblue.gambit.Display;
import dmcblue.gambit.GameSource;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import interealmGames.common.errors.Error;

class Game implements GameSource {
	public var board:Board;
	public var currentPlayer:Piece;
	public var display:Display;

	public function new(display:Display, ?startingPlayer:Piece = Piece.WHITE) {
		this.currentPlayer = startingPlayer;
		this.display = display;
	}

	/**
		@implements GameMaster
	**/
	public function getBoard():Array<Array<Piece>> {
		var board:Array<Array<Piece>> = [];
		for(row in this.board.board) {
			var r:Array<Piece> = [];
			for(cell in row) {
				r.push(cell);
			}
			board.push(r);
		}
		return board;
	}

	/**
		If a player is able to make multi-jump moves, requests that user input
		and allows the player to skip subsequent jumps.
	**/
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

			var error = this.board.isValidMove(move);
			if (error == null) {
				isValidMove = true;
			} else {
				this.display.displayError(error);
			}
		}

		return move;
	}

	/**
		@implements GameMaster
	**/
	public function getMoves(position:Position):Array<Position> {
		return this.board.getMoves(position);
	}

	/**
		Requests user input for an initial move and checks validity.
	**/
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

			var error = this.board.isValidMove(move);
			if (error == null) {
				isValidMove = true;
			} else {
				this.display.displayError(error);
			}
		}

		return move;
	}

	/**
		Game loop
	**/
	public function run() {
		var playing = true;
		while (playing) {
			this.board = Board.newGame();
			while(this.board.hasAnyMoreMoves(this.currentPlayer)) {
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
			this.display.endGame(scores, this);
			playing = this.display.playAgain();
		}
	}
}
