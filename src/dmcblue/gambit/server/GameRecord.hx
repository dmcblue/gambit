package dmcblue.gambit.server;

import dmcblue.gambit.Piece;
import interealmGames.common.uuid.UuidV4;
import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.server.GameRecordObject;
import dmcblue.gambit.Board;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.errors.InvalidInputError;
import interealmGames.common.uuid.Uuid;

class GameRecord {
	static public var REGEX_PIECES = ~/[^0-2]+/;

	static public function create():GameRecord {
		return new GameRecord(
			Uuid.v4(),
			Piece.BLACK,
			Board.newGame(),
			false,
			"",
			"",
			GameState.WAITING
		);
	}

	static public function fromObject(game:GameRecordObject):GameRecord {
		var lastMove = null;
		if(game.lastMove != null) {
			lastMove = {
				from: new Position(game.lastMove.from.x, game.lastMove.from.y),
				to: new Position(game.lastMove.to.x, game.lastMove.to.y)
			};
		}
		return new GameRecord(
			game.id,
			game.currentPlayer,
			Board.fromString(game.board),
			game.canPass,
			game.black,
			game.white,
			game.state,
			lastMove
		);
	}

	public var id:UuidV4; // UUID v4
	public var board:Board;
	public var currentPlayer:Piece;
	public var canPass:Bool = false;
	public var lastMove:Move = null;
	public var opposingPlayer:Piece;
	public var black:UuidV4;
	public var white:UuidV4;
	public var state:GameState;

	public function new(
		id:String,
		currentPlayer:Piece,
		board:Board,
		canPass:Bool,
		black:UuidV4,
		white:UuidV4,
		state:GameState,
		?lastMove:Move
	) {
		this.id = id;
		this.currentPlayer = currentPlayer;
		this.board = board;
		this.canPass = canPass;
		this.black = black;
		this.white = white;
		this.state = state;
		this.opposingPlayer = this.currentPlayer == Piece.BLACK ? Piece.WHITE : Piece.BLACK;
		this.lastMove = lastMove;
	}

	public function currentPlayerId():UuidV4 {
		return this.currentPlayer == Piece.BLACK ? this.black : this.white;
	}

	public function isFollowUpMove():Bool {
		if(this.lastMove == null) {
			return false;
		}

		var lastTeam = this.board.pieceAt(this.lastMove.to);
		return lastTeam == this.currentPlayer;
	}

	public function move(move:Move) {
		this.board.move(move);
		this.lastMove = move;
	}

	public function next():Void {
		this.canPass = false;
		this.currentPlayer = this.currentPlayer == Piece.BLACK ? Piece.WHITE : Piece.BLACK;
		if(!this.board.hasAnyMoreMoves(this.currentPlayer)) {
			this.state = GameState.DONE;
		}
	}

	public function opposingPlayerId():UuidV4 {
		return this.opposingPlayer == Piece.BLACK ? this.black : this.white;
	}

	public function toObject():GameRecordObject {
		var obj = {
			id: this.id,
			currentPlayer: this.currentPlayer,
			board: this.board.toString(),
			canPass: this.canPass,
			lastMove: null,
			black: this.black,
			white: this.white,
			state: this.state
		};

		if (this.lastMove != null) {
			obj.lastMove = {
				from: this.lastMove.from.toPoint(),
				to: this.lastMove.to.toPoint()
			};
		}

		return obj;
	}
}
