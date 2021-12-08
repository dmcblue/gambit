package dmcblue.gambit.server;

import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.Board;
import dmcblue.gambit.Piece;
import dmcblue.gambit.server.errors.InvalidInputError;
import interealmGames.common.Uuid;

class GameRecord {
	static public var REGEX_PIECES = ~/[^0-2]+/;

	static public function create():GameRecord {
		var board = Board.newGame();
		var id = Uuid.v4();
		var startingPlayer = Piece.BLACK;
		return new GameRecord(id, startingPlayer, board);
	}

	static public function fromString(id:String, str:String):GameRecord {
		if(GameRecord.REGEX_PIECES.match(str)) {
			// invalid chars
			throw new InvalidInputError(str);
		}

		if(str.length != 33) {
			// invalid input
			throw new InvalidInputError(str);
		}

		if(str.charAt(0) == '0') {
			// invalid team
			throw new InvalidInputError(str);
		}

		var currentPlayer:Piece = GameRecord.pieceFromString(str.charAt(0));
		var board = Board.fromString(str.substring(1));

		return new GameRecord(id, currentPlayer, board);
	}

	static public function pieceFromString(str:String):Piece {
		return switch str {
			case '0': Piece.NONE;
			case '1': Piece.WHITE;
			case '2': Piece.BLACK;
			default: Piece.NONE;
		}
	}

	static public function pieceToString(piece:Piece):String {
		return switch piece {
			case Piece.NONE: '0';
			case Piece.WHITE: '1';
			case Piece.BLACK: '2';
			default: '0';
		}
	}

	public var id:String; // UUID v4
	public var board:Board;
	public var currentPlayer:Piece;

	public function new(id:String, currentPlayer:Piece, board:Board) {
		this.id = id;
		this.currentPlayer = currentPlayer;
		this.board = board;
	}

	public function toString():String {
		var str:String = GameRecord.pieceToString(this.currentPlayer);
		str += this.board.board.map(function(pieces:Array<Piece>) {
			return pieces.map(function(piece:Piece) {
				return GameRecord.pieceToString(piece);
			}).join('');
		}).join('');
		return str;
	}
}
