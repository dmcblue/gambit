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
import dmcblue.gambit.server.parameters.CreateParams;
import dmcblue.gambit.server.parameters.MoveParams;

using interealmGames.common.StringToolsExtension;

class Handlers {
	static public var ERROR_GAME_DNE = "There is no game with the ID '%s'";
	static public var ERROR_GAME_FINISHED = "This game is already finished.";
	static public var ERROR_GAME_IN_PROGRESS = "You cannot join, this game is already in progress.";
	static public var ERROR_GAME_INVALID = "The game data is bad, please create a new game.";
	static public var ERROR_GAME_INVALID_MOVE = "Move is invalid.";
	static public var ERROR_GAME_INVALID_PLAYER = "Player is invalid.";
	static public var ERROR_GAME_NOT_PASSABLE = "Cannot pass this turn.";
	static public var ERROR_GAME_NOT_STARTED = "This game has not started yet.";
	static public var ERROR_GAME_NOT_TURN = "Not this players turn.";

	private var persistence:Persistence;
	public function new(persistence:Persistence) {
		this.persistence = persistence;
	}

	public function getHandlers():Array<RequestHandler> {
		var handlers:Array<RequestHandler> = [];

		handlers.push(this.create());
		handlers.push(this.get());
		handlers.push(this.join());
		handlers.push(this.move());
		handlers.push(this.pass());
		
		return handlers;
	}

	public function create():RequestHandler {
		return {
			type: RequestType.POST,
			path: "/create[/]",
			handler: function(request:Request) {
				var game = GameRecord.create();

				var content = request.getData();
				var params:CreateParams = cast Json.parse(content);
				var playerId:UuidV4 = Uuid.v4();
				if (params.startingAs == Piece.BLACK) {
					game.black = playerId;
				} else {
					game.white = playerId;
				}

				var persistence = this.persistence.getGameRecordPersistence();
				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, playerId);
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

				var error:Error = null;
				if (game == null) {
					var message = StringTools.format(Handlers.ERROR_GAME_DNE, [gameId], "%s");
					error = ClientError.notFound(message);
				}

				if (error != null) {
					return Json.stringify(error);
				}

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

				var error:Error = null;
				if (game == null) {
					var message = StringTools.format(Handlers.ERROR_GAME_DNE, [gameId], "%s");
					error = ClientError.notFound(message);
				}

				if (game.state != GameState.WAITING) {
					error = ClientError.badRequest(Handlers.ERROR_GAME_IN_PROGRESS);
				}

				if (game.black.length > 0 && game.white.length > 0) {
					error = ServerError.general(Handlers.ERROR_GAME_INVALID);
				}

				if (error != null) {
					return Json.stringify(error);
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

				var content = request.getData();
				var params:MoveParams = cast Json.parse(content);
				var playerId:UuidV4 = params.player;
				var move:Move = {
					from: Position.fromPoint(params.move.from),
					to: Position.fromPoint(params.move.to)
				};

				var error:Error = this.getRunningGameError(game, playerId);

				if (error == null && !game.board.isValidMove(move)) {
					error = ClientError.badRequest(Handlers.ERROR_GAME_INVALID_MOVE);
				}

				if (error != null) {
					return Json.stringify(error);
				}

				game.board.move(move);
				if (game.board.isOver()) {
					game.state = GameState.DONE;
				} else {
					// make sure the other player has moves
					if (game.board.getMoves(move.to).length > 0) {
						game.canPass = true;
					} else {
						game.next();
					}
				}

				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, game.currentPlayerId());
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

				var error:Error = this.getRunningGameError(game, playerId);

				if (error == null && !game.canPass) {
					error = ClientError.badRequest(Handlers.ERROR_GAME_NOT_PASSABLE);
				}

				if (error != null) {
					return Json.stringify(error);
				}

				game.next();

				persistence.save(game);
				var serializer = new ExternalGameRecordSerializer(persistence, game.currentPlayerId());
				return serializer.encode(game);
			}
		};
	}

	private function getRunningGameError(game:GameRecord, playerId:UuidV4): Error {
		var error:Error = null;
		if (error == null && game.state != GameState.PLAYING) {
			error = ClientError.badRequest(
				game.state == GameState.DONE ? Handlers.ERROR_GAME_FINISHED : Handlers.ERROR_GAME_NOT_STARTED
			);
		}

		// check if right player
		if (error == null && game.currentPlayerId() != playerId) {
			error = ClientError.badRequest(Handlers.ERROR_GAME_NOT_TURN);
		} else if (error == null && (game.black != playerId && game.white != playerId)) {
			error = ClientError.badRequest(Handlers.ERROR_GAME_INVALID_PLAYER);
		}

		return error;
	}
}
