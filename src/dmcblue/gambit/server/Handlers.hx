package dmcblue.gambit.server;

import interealmGames.common.Uuid;
import interealmGames.server.http.Request;
import interealmGames.server.http.RequestHandler;
import interealmGames.server.http.RequestType;
import dmcblue.gambit.Piece;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.Persistence;
import haxe.Json as Json;

typedef CreateParams = {
	var startingPlayer: String;
}

class Handlers {
	private var persistence:Persistence;
	public function new(persistence:Persistence) {
		this.persistence = persistence;
	}

	public function getHandlers():Array<RequestHandler> {
		var handlers:Array<RequestHandler> = [];
		
		handlers.push(this.createGame());
		
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
				var startingPlayer:Piece = PieceTools.fromString(params.startingPlayer);
				game.currentPlayer = startingPlayer;

				var persistence = this.persistence.getGameRecordPersistence();
				persistence.save(game);
				return game;
			}
		};
	}
}
