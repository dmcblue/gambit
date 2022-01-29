package dmcblue.gambit.server;

import interealmGames.server.http.Error;
import interealmGames.server.http.ClientError;
import interealmGames.server.http.ServerError;
import dmcblue.gambit.server.GameState;
import dmcblue.gambit.server.GameRecord;
import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.Piece;
import dmcblue.gambit.server.GameRecordSerializer;
import interealmGames.common.uuid.Uuid;
import interealmGames.common.serializer.object.Json;
import interealmGames.server.http.Request;
import interealmGames.server.http.RequestHandler;
import interealmGames.server.http.RequestType;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.Persistence;
import haxe.Json as Json;
import interealmGames.common.uuid.Uuid;
import dmcblue.gambit.server.parameters.AiMoveParams;
import dmcblue.gambit.server.parameters.CreateParams;
import dmcblue.gambit.server.parameters.MoveParams;
import dmcblue.gambit.ai.Ai;
import dmcblue.gambit.ai.Level;

using interealmGames.common.StringToolsExtension;

class Handlers {
	static public var AI_PLAYER = "AI_PLAYER";
	static public var ERROR_GAME_DNE = "There is no game with the ID '%s'";
	static public var ERROR_GAME_FINISHED = "This game is already finished.";
	static public var ERROR_GAME_IN_PROGRESS = "You cannot join, this game is already in progress.";
	static public var ERROR_GAME_INVALID = "The game data is bad, please create a new game.";
	static public var ERROR_GAME_INVALID_MOVE = "Move is invalid.";
	static public var ERROR_GAME_INVALID_PLAYER = "Player is invalid.";
	static public var ERROR_GAME_INVALID_PIECE = "'%s' is not a valid Piece.";
	static public var ERROR_GAME_NOT_PASSABLE = "Cannot pass this turn.";
	static public var ERROR_GAME_NOT_STARTED = "This game has not started yet.";
	static public var ERROR_GAME_NOT_TURN = "Not this players turn.";
	static public var ERROR_INVALID_AI_REQUEST = "Cannot request AI Move.";
	static public var ERROR_INVALID_LEVEL = "Invalid level.";
	static public var ERROR_INVALID_PARAMETERS = "Invalid parameters.";
	static public var MESSAGE_STATUS_ONLINE = "Service online";

	private var persistence:Persistence;
	public function new(persistence:Persistence) {
		this.persistence = persistence;
	}

	public function getHandlers():Array<RequestHandler> {
		var handlers:Array<RequestHandler> = [];

		handlers.push(this.wrap(this.aiJoin()));
		handlers.push(this.wrap(this.aiMove()));
		handlers.push(this.wrap(this.create()));
		handlers.push(this.wrap(this.get()));
		handlers.push(this.wrap(this.join()));
		handlers.push(this.wrap(this.move()));
		handlers.push(this.wrap(this.pass()));
		handlers.push(this.wrap(this.status()));
		
		return handlers;
	}

	public function aiJoin():RequestHandler {
		return {
			type: RequestType.GET,
			path: "/game/{id}/ai/join",
			handler: function(request:Request) {
				var gameId = request.getPathArgument('id');
				var persistence = this.persistence.getGameRecordPersistence();
				var game:GameRecord = persistence.get(gameId);

				this.checkGameExistsError(gameId, game);

				if (game.state != GameState.WAITING) {
					throw ClientError.badRequest(Handlers.ERROR_GAME_IN_PROGRESS);
				}

				if (game.black.length > 0 && game.white.length > 0) {
					throw ServerError.general(Handlers.ERROR_GAME_INVALID);
				}

				var playerId = Handlers.AI_PLAYER;
				if (game.black.length > 0) {
					game.white = playerId;
				} else {
					game.black = playerId;
				}

				game.state = GameState.PLAYING;
				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, playerId);
				return serializer.encode(game);
			}
		};
	}

	public function aiMove():RequestHandler {
		return {
			type: RequestType.POST,
			path: "/game/{id}/ai/move/",
			handler: function(request:Request) {
				var params:AiMoveParams = cast parseParams(request, ['level', 'player']);
				var playerId:UuidV4 = params.player;
				var levelInt:Int = cast params.level;

				var gameId = request.getPathArgument('id');
				var persistence = this.persistence.getGameRecordPersistence();
				var game:GameRecord = persistence.get(gameId);
				var aiId = Handlers.AI_PLAYER;
				this.checkRunningGameError(gameId, game, aiId);

				if (game.opposingPlayerId() != playerId) {
					throw ClientError.badRequest(Handlers.ERROR_INVALID_AI_REQUEST);
				}

				if ([Level.EASY, Level.MEDIUM, Level.HARD].indexOf(cast levelInt) == -1) {
					throw ClientError.badRequest(Handlers.ERROR_INVALID_LEVEL);
				}
				var level:Level = cast levelInt;

				var ai = new Ai(this.persistence.getAiRecordPersistence());
				var move = ai.getMove(level, Piece.BLACK, Board.newGame());

				// Leave this in?
				if (!game.board.isValidMove(move)) {
					throw ClientError.badRequest(Handlers.ERROR_GAME_INVALID_MOVE);
				}

				if (game.board.pieceAt(move.from) != game.currentPlayer) {
					throw ClientError.badRequest(Handlers.ERROR_GAME_INVALID_MOVE);
				}

				game.board.move(move);
				if (game.board.getMoves(move.to).length > 0) {
					game.canPass = true;
				} else {
					if (game.board.hasAnyMoreMoves(game.opposingPlayer)) {
						game.next();
					} else {
						game.state = GameState.DONE;
					}
				}

				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, playerId);
				return serializer.encode(game);
			}
		};
	}

	public function create():RequestHandler {
		return {
			type: RequestType.POST,
			path: "/create[/]",
			handler: function(request:Request) {
				var game = GameRecord.create();

				var params:CreateParams = cast parseParams(request, ['startingAs']);
				this.validatePiece(cast params.startingAs);
				var playerId:UuidV4 = Uuid.v4();
				if (params.startingAs == Piece.BLACK) {
					game.black = playerId;
				} else {
					game.white = playerId;
				}

				var persistence = this.persistence.getGameRecordPersistence();
				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, playerId);

				request.setStatus(201);
				return serializer.encode(game);
			}
		};
	}

	public function get():RequestHandler {
		return {
			type: RequestType.GET,
			path: "/game/{id}[/]",
			handler: function(request:Request) {
				var gameId = request.getPathArgument('id');
				var persistence = this.persistence.getGameRecordPersistence();
				var game:GameRecord = persistence.get(gameId);

				this.checkGameExistsError(gameId, game);

				var serializer = new ExternalGameRecordSerializer(persistence, null);
				return serializer.encode(game);
			}
		};
	}

	public function join():RequestHandler {
		return {
			type: RequestType.GET,
			path: "/game/{id}/join[/]",
			handler: function(request:Request) {
				var gameId = request.getPathArgument('id');
				var persistence = this.persistence.getGameRecordPersistence();
				var game:GameRecord = persistence.get(gameId);

				this.checkGameExistsError(gameId, game);

				if (game.state != GameState.WAITING) {
					throw ClientError.badRequest(Handlers.ERROR_GAME_IN_PROGRESS);
				}

				if (game.black.length > 0 && game.white.length > 0) {
					throw ServerError.general(Handlers.ERROR_GAME_INVALID);
				}

				var playerId = Uuid.v4();
				if (game.black.length > 0) {
					game.white = playerId;
				} else {
					game.black = playerId;
				}

				game.state = GameState.PLAYING;
				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, playerId);
				return serializer.encode(game);
			}
		};
	}

	public function move():RequestHandler {
		return {
			type: RequestType.POST,
			path: "/game/{id}/move[/]",
			handler: function(request:Request) {
				var gameId = request.getPathArgument('id');
				var persistence = this.persistence.getGameRecordPersistence();
				var game:GameRecord = persistence.get(gameId);

				var params:MoveParams = cast parseParams(request, ['move', 'player']);
				var playerId:UuidV4 = params.player;
				var move:Move = {
					from: Position.fromPoint(params.move.from),
					to: Position.fromPoint(params.move.to)
				};

				this.checkRunningGameError(gameId, game, playerId);

				if (!game.board.isValidMove(move)) {
					throw ClientError.badRequest(Handlers.ERROR_GAME_INVALID_MOVE);
				}

				if (game.board.pieceAt(move.from) != game.currentPlayer) {
					throw ClientError.badRequest(Handlers.ERROR_GAME_INVALID_MOVE);
				}

				game.board.move(move);
				if (game.board.getMoves(move.to).length > 0) {
					game.canPass = true;
				} else {
					if (game.board.hasAnyMoreMoves(game.opposingPlayer)) {
						game.next();
					} else {
						game.state = GameState.DONE;
					}
				}
				// if (game.board) {
				// 	game.state = GameState.DONE;
				// } else {
				// 	// make sure the other player has moves
				// 	if (game.board.getMoves(move.to).length > 0) {
				// 		game.canPass = true;
				// 	} else {
				// 		game.next();
				// 	}
				// }

				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, playerId);
				return serializer.encode(game);
			}
		};
	}

	public function pass():RequestHandler {
		return {
			type: RequestType.GET,
			path: "/game/{id}/pass/{playerId}[/]",
			handler: function(request:Request) {
				var gameId = request.getPathArgument('id');
				var playerId = request.getPathArgument('playerId');
				var persistence = this.persistence.getGameRecordPersistence();
				var game:GameRecord = persistence.get(gameId);

				this.checkRunningGameError(gameId, game, playerId);

				if (!game.canPass) {
					throw ClientError.badRequest(Handlers.ERROR_GAME_NOT_PASSABLE);
				}

				game.next();

				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, playerId);
				return serializer.encode(game);
			}
		};
	}

	public function status():RequestHandler {
		return {
			type: RequestType.GET,
			path: "/status[/]",
			handler: function(request:Request) {
				return Json.stringify({
					status: 200,
					message: Handlers.MESSAGE_STATUS_ONLINE
				});
			}
		};
	}

	private function checkGameExistsError(gameId:UuidV4, game:GameRecord):Void {
		if (game == null) {
			var message = StringTools.format(Handlers.ERROR_GAME_DNE, [gameId], "%s");
			throw ClientError.notFound(message);
		}
	}

	private function checkRunningGameError(gameId:UuidV4, game:GameRecord, playerId:UuidV4):Void {
		this.checkGameExistsError(gameId, game);

		if (game.state != GameState.PLAYING) {
			throw ClientError.badRequest(
				game.state == GameState.DONE ? Handlers.ERROR_GAME_FINISHED : Handlers.ERROR_GAME_NOT_STARTED
			);
		}

		// check if right player
		if (game.currentPlayerId() != playerId) {
			throw ClientError.badRequest(Handlers.ERROR_GAME_NOT_TURN);
		} else if (game.black != playerId && game.white != playerId) {
			throw ClientError.badRequest(Handlers.ERROR_GAME_INVALID_PLAYER);
		}
	}

	private function parseParams<T>(request:Request, fields:Array<String>):T {
		var content = request.getData();
		if (content == null || content == "") {
			throw ClientError.badRequest(Handlers.ERROR_INVALID_PARAMETERS);
		}
		var params = cast Json.parse(content);
		for (field in fields) {
			if (!Reflect.hasField(params, field)) {
				throw ClientError.badRequest(Handlers.ERROR_INVALID_PARAMETERS);
			}
		}

		return params;
	}

	private function validatePiece(val:Int):Void {
		if (val < 0 || val > 2) {
			var message = StringTools.format(Handlers.ERROR_GAME_INVALID_PIECE, ['' + val], "%s");
			throw ClientError.badRequest(message);
		}
	}

	private function wrap(requestHandler:RequestHandler):RequestHandler {
		var handler = requestHandler.handler;
		requestHandler.handler = function(request:Request) {
			var response = null;
			try {
				response = handler(request);
			} catch(error:Error) {
				request.setStatus(error.status);
				return Json.stringify(error);
			}

			if (request.getStatus() == null) {
				request.setStatus(200);
			}

			return response;
		};

		return requestHandler;
	}
}
