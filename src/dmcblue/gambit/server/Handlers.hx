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
import dmcblue.gambit.Piece;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.Persistence;
import haxe.Json as Json;
import interealmGames.common.uuid.Uuid;

using interealmGames.common.StringToolsExtension;

typedef CreateParams = {
	var startingAs: Piece;
}

class Handlers {
	static public var ERROR_GAME_DNE = "There is no game with the ID '%s'";
	static public var ERROR_GAME_IN_PROGRESS = "You cannot join, this game is already in progress.";
	static public var ERROR_GAME_INVALID = "The game data is bad, please create a new game.";

	private var persistence:Persistence;
	public function new(persistence:Persistence) {
		this.persistence = persistence;
	}

	public function getHandlers():Array<RequestHandler> {
		var handlers:Array<RequestHandler> = [];

		handlers.push(this.createGame());
		handlers.push(this.joinGame());
		
		return handlers;
	}

	public function createGame():RequestHandler {
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

	public function joinGame():RequestHandler {
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
}
