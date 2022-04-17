package dmcblue.gambit;

import haxe.io.Eof;
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
import dmcblue.gambit.ai.Level;
import dmcblue.gambit.server.Api;
import dmcblue.gambit.server.parameters.AiMoveParams;
import dmcblue.gambit.error.EndGameInterrupt;

using haxe.EnumTools;

class GameManagerAsync {
	static public var ERROR_TYPE = "GAMBIT_GAME_MANAGER_ERROR";
	static public var ERROR_TYPE_API = "GAMBIT_API_ERROR";
	private var aiLevel:Level;
	private var aiMode:Bool;
	private var api:Api;
	private var currentPlayer:Piece;
	private var display:DisplayAsync;
	private var lastPosition:Position;
	private var needUpdate:Bool = false;
	private var playerId:UuidV4;
	private var isPlaying:Bool = false;
	private var gameId:UuidV4;
	private var team:Piece;
	#if js
	private var handle:Int;
	#end

	public function new(api:Api, display:DisplayAsync) {
		this.api = api;
		this.display = display;
		this.resetGame();

		this.api.checkStatus(function(isAvailable) {
			if (!isAvailable) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE,
					'Service not available'
				));
				this.exit();
			}
		});
	}

	private function resetGame() {
		this.playerId = null;
		this.gameId = null;
	}

	public function check() {
		this.api.get(this.gameId, function(game:ExternalGameRecordObject, error: ErrorObject) {
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				if (game.state == GameState.WAITING) {
					if(this.needUpdate) {
						this.needUpdate = false;
					}
					return;
				} else if (this.handle != null) {
					js.Browser.window.clearInterval(this.handle);
					this.handle = null;
				}

				if (game.currentPlayer != this.currentPlayer) {
					this.needUpdate = true;
				}
				this.currentPlayer = game.currentPlayer;

				var board = Board.fromString(game.board);
				if(this.needUpdate) {
					this.display.showBoard(
						game.currentPlayer,
						this.team == game.currentPlayer,
						game.state,
						board.board
					);
					this.needUpdate = false;
				}

				if (game.state == GameState.DONE) {
					var scores:Map<Piece, Int> = new Map();
					scores.set(Piece.BLACK, board.calculateScore(Piece.BLACK));
					scores.set(Piece.WHITE, board.calculateScore(Piece.WHITE));
					this.display.endGame(scores, board.board);
					this.isPlaying = false;
					this.display.playAgain(function(response:Bool) {
						if(response) {
							this.start();
						} else {
							this.exit();
						}
					});
					return;
				}

				if (game.currentPlayer == this.team) {
					if (game.canPass) {
						this.getFollowUpMove(board);
					} else {
						this.getMove(board);
					}
				}  else {
					if (this.aiMode) {
						js.Browser.window.setTimeout(function() {
							this.getAiMove();
						}, 500);
					} else if (this.handle == null) {
						this.handle = js.Browser.window.setInterval(function() {
							this.check();
						}, 1000);
					}
				}
			}
		});
	}

	public function exit() {
		this.display.exit();
		#if js
		js.Browser.window.clearTimeout(this.handle);
		this.handle = null;
		#end
	}

	public function getAiMove() {
		var params:AiMoveParams = {
			level: this.aiLevel,
			player: this.playerId
		};
		this.api.aiMove(this.gameId, params, function(game:ExternalGameRecordObject, error: ErrorObject) {
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				var board = Board.fromString(game.board);
				this.display.showLastMove(this.opposingTeam(), game.lastMove);
				this.display.showBoard(
					game.currentPlayer,
					this.team == game.currentPlayer,
					game.state,
					board.board
				);
				this.needUpdate = true;
				js.Browser.window.setTimeout(function() {
					this.check();
				}, 500);
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
				if (this.aiMode) {
					this.joinAi();
				} else {
					this.display.invite(this.gameId);
					this.needUpdate = true;
					this.currentPlayer = myTeam == Piece.BLACK ? Piece.WHITE : Piece.BLACK;
					this.handle = js.Browser.window.setInterval(function() {
						this.check();
					}, 1000);
				}
			}
		});
	}

	public function joinAi() {
		this.api.aiJoin(this.gameId, function(game:ExternalGameRecordObject, error: ErrorObject) {
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				this.needUpdate = true;
				this.check();
			}
		});
	}

	public function opposingTeam():Piece {
		return this.team == Piece.BLACK ? Piece.WHITE : Piece.BLACK;
	}

	// for this and next, need some confirmation for the user,
	// not sure if that is display or this
	public function getMove(board:Board):Void {
		this.display.requestNextMoveFrom(
			this.team,
			board.getPositionsWithMoves(this.team),
			function(from:Position) {
				var moves = board.getMoves(from);
				this.display.requestNextMoveTo(this.team, moves, function(to:Position) {
					this.move({
						from: from,
						to: to
					});
				});
			}
		);
	}

	public function getFollowUpMove(board:Board):Void {
		this.display.showBoard(this.team, true, GameState.PLAYING, board.board);
		this.display.requestFollowUpMove(
			this.team,
			this.lastPosition,
			board.getMoves(this.lastPosition),
			function(move:Move) {
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
						
						this.needUpdate = true;
						this.check();
					});
				}
			}
		);
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
				this.currentPlayer = Piece.BLACK;
						
				this.needUpdate = true;
				this.check();
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
			if (error != null) {
				this.display.displayError(new Error(
					GameManager.ERROR_TYPE_API,
					error.message
				));
			} else {
				this.lastPosition = move.to;
			}
			var board = Board.fromString(game.board);
			this.display.showBoard(
				game.currentPlayer,
				this.team == game.currentPlayer,
				game.state,
				board.board
			);
			this.needUpdate = true;
			this.check();
		});
	}

	public function run() {
		var running = true;
		this.handle = js.Browser.window.setTimeout(function() {
			if(running) {
				try {
					this.start();
				} catch(interrupt:EndGameInterrupt) {
					running = false;
				} catch(error:Error) {
					this.display.displayError(error);
				} catch(error:Eof) {
					running = false; // force quit
				} catch(e) {
					trace(e);
				}
			} else {
				this.exit();
			}
		}, 1000);
	}

	public function start() {
		this.display.getGameStart(function(choice:StartChoice) {
			if (choice == StartChoice.AI || choice == StartChoice.CREATE) {
				this.aiMode = choice == StartChoice.AI;
				var createCallback = function(team:Piece) {
					this.create(team);
				};
				if(this.aiMode) {
					this.display.getAiLevel(function(level:Level) {
						this.aiLevel = level;
						this.display.getTeamChoice(createCallback);
					});
				} else {
					this.display.getTeamChoice(createCallback);
				}
			} else if (choice == StartChoice.JOIN) {
				this.needUpdate = true;
				this.display.getGameId(function(gameId:UuidV4) {
					this.join(gameId);
				});
			}
			this.isPlaying = true;
		});
	}
}
