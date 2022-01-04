package dmcblue.gambit;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Display.StartChoice;
import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.Display.StartChoice;
import dmcblue.gambit.server.parameters.MoveParams;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.GameState;
import dmcblue.gambit.Piece;
import interealmGames.common.uuid.UuidV4;
import interealmGames.server.http.ErrorObject;
import dmcblue.gambit.server.ExternalGameRecordObject;
import dmcblue.gambit.server.parameters.CreateParams;
import dmcblue.gambit.Piece;
import haxe.macro.Expr.Error;
import interealmGames.common.errors.Error;
import dmcblue.gambit.Display;
import dmcblue.gambit.server.Api;

class GameManager {
	static public var ERROR_TYPE = "GAMBIT_GAME_MANAGER_ERROR";
	static public var ERROR_TYPE_API = "GAMBIT_API_ERROR";
	private var api:Api;
	private var display:Display;
	private var lastPosition:Position;
	private var playerId:UuidV4;
	private var gameId:UuidV4;
	private var team:Piece;
	// private var game
	public function new(api:Api, display:Display) {
		this.api = api;
		this.display = display;
		this.resetGame();

		this.api.checkStatus(function(isAvailable) {
			if (!isAvailable) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE,
					'Service not available'
				));
			}
		});
	}

	private function resetGame() {
		this.playerId = null;
		this.gameId = null;
	}

	public function check(withUpdate:Bool) {
		this.api.get(this.gameId, function(game:ExternalGameRecordObject, error: ErrorObject) {
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				var board = Board.fromString(game.board);
				if(withUpdate) {
					this.display.showBoard(
						game.currentPlayer,
						this.team == game.currentPlayer,
						game.state,
						board.board
					);
				}
				if (game.state == GameState.WAITING) {
					haxe.Timer.delay(function() {
						this.check(false);
					}, 1000);
				} else if (game.currentPlayer == this.team) {
					if (game.canPass) {
						this.getFollowUpMove(board);
					} else {
						this.getMove(board);
					}
				} else if (game.state == GameState.DONE) {
					var scores:Map<Piece, Int> = new Map();
					scores.set(Piece.BLACK, board.calculateScore(Piece.BLACK));
					scores.set(Piece.WHITE, board.calculateScore(Piece.WHITE));
					this.display.endGame(scores, board.board);
				} else {
					// probably update display
					haxe.Timer.delay(function() {
						this.check(false);
					}, 1000);
				}
			}
		});
	}

	public function create(myTeam:Piece) {
		this.resetGame();
		var params:CreateParams = {
			startingAs: myTeam
		};
		this.api.create(params, function(game:ExternalGameRecordObject, error: ErrorObject) {
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				this.gameId = game.id;
				this.playerId = game.player;
				this.team = myTeam;
				this.display.invite(this.gameId);
				this.check(true);
			}
		});
	}

	public function opposingTeam():Piece {
		return this.team == Piece.BLACK ? Piece.WHITE : Piece.BLACK;
	}

	// for this and next, need some confirmation for the user,
	// not sure if that is display or this
	public function getMove(board:Board):Void {
		this.display.showBoard(this.team, true, GameState.PLAYING, board.board);
		var from = this.display.requestNextMoveFrom(this.team, board.getPositionsWithMoves(this.team));
		var moves = board.getMoves(from);
		var to = this.display.requestNextMoveTo(this.team, moves);
		this.move({
			from: from,
			to: to
		});
	}

	public function getFollowUpMove(board:Board):Void {
		this.display.showBoard(this.team, true, GameState.PLAYING, board.board);
		var move = this.display.requestFollowUpMove(
			this.team,
			this.lastPosition,
			board.getMoves(this.lastPosition)
		);
		if (move != null) {
			this.move(move);
		} else {
			this.api.pass(this.gameId, this.playerId, function(game:ExternalGameRecordObject, error:ErrorObject) {
				if (error != null) {
					this.display.displayError(new Error(
						GameManager.ERROR_TYPE_API,
						error.message
					));
				}
				this.check(true);
			});
		}
	}

	public function join(gameId:UuidV4) {
		this.api.join(gameId, function(game:ExternalGameRecordObject, error:ErrorObject) {
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				this.gameId = game.id;
				this.playerId = game.player;
				this.team = game.team;
				this.check(true);
			}
		});
	}

	public function move(move:Move) {
		var params:MoveParams = {
			move: {
				from: move.from.toPoint(),
				to: move.to.toPoint()
			},
			player: this.playerId
		};

		this.api.move(this.gameId, params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			var board = Board.fromString(game.board);
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				this.lastPosition = move.to;
			}
			this.check(true);
		});
	}

	public function run() {
		var choice = this.display.createJoinResume();
		if (choice == StartChoice.CREATE) {
			this.create(this.display.getTeamChoice());
		} else if (choice == StartChoice.JOIN) {
			this.join(this.display.getGameId());
		}
	}
}
