package dmcblue.gambit;

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
			}
		});
	}

	public function check() {
		this.api.get(this.gameId, function(game:ExternalGameRecordObject, error: ErrorObject) {
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				var board = Board.fromString(game.board);
				this.display.showBoard(game.currentPlayer, board);
				if (game.currentPlayer == this.team) {
					if (game.canPass) {
						this.getFollowUpMove(board);
					} else {
						this.getMove(board);
					}
				} else if (game.state == GameState.DONE) {
					this.display.endGame(board, null);
				} else {
					// probably update display
					haxe.Timer.delay(function() {
						this.check();
					}, 1000);
				}
			}
		});
	}

	// for this and next, need some confirmation for the user,
	// not sure if that is display or this
	public function getMove(board:Board):Void {
		var move = this.display.requestNextMove(this.team, board.getPositions(this.team), null);
		this.move(move);
	}

	public function getFollowUpMove(board:Board):Void {
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
				this.check();
			});
		}
	}

	public function move(move:Move) {
		var params:MoveParams = {
			move: move,
			player: this.playerId
		};
		this.api.move(this.gameId, params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			var board = Board.fromString(game.board);
			if (error != null) {
				this.lastPosition = move.to;
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
				this.getMove(board);
			}
			this.check();
		});
	}
}
