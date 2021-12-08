package dmcblue.gambit.server;

import interealmGames.common.Uuid;
import dmcblue.gambit.Piece;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.server.GameRecord;

typedef CreateParams {
	var startingPlayer: String;
}

class Handlers {
	public static function getHandlers():Array<RequestHandler> {
		var handlers:Array<RequestHandler> = [];
		
		handlers.push(Handlers.getAll());
		
		return handlers;
	}

	public static function createGame():RequestHandler {
		return {
			type: RequestType.POST,
			path: "/create[/]",
			handler: function(request:Request) {
				var game = GameRecord.create();

				var content = request.getData();
				var params:CreateParams = cast Json.parse(content);
				var startingPlayer:Piece = PieceTools.fromString(params.startingPlayer);
				game.currentPlayer = startingPlayer;

				var persistence = Main.getGameRecordPersistence();
				persistence.save(game);
				return game;
			}
		};
	}
}
