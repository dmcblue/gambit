package dmcblue.gambit.server;

import interealmGames.server.http.Error;
import interealmGames.server.http.ErrorObject;
import interealmGames.common.uuid.Uuid;
import dmcblue.gambit.server.ExternalGameRecordObject;
import haxe.Json;
import interealmGames.server.http.test.Request;
import interealmGames.server.http.RequestType;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.ai.Level;
import dmcblue.gambit.ai.Record;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.errors.InvalidInputError;
import dmcblue.gambit.server.parameters.AiMoveParams;
import dmcblue.gambit.server.parameters.MoveParams;
import utest.Assert;
import utest.Async;
import utest.Test;

class HandlersAiMoveTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testMove() {
		var playerId = Handlers.AI_PLAYER;
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var record = Record.fromObject({
			name: "200000000111111112222222200000000",
			children:[{"name":"120000000011111110222222200000000","success":1}]
		});	
		Test.persistence.getAiRecordPersistence().save(record);
		var params:AiMoveParams = {
			level:  Level.HARD,
			player: otherPlayerId
		};
		var request:Request = new Request({
			url: "/game/1234/ai/move/",
			data: Json.stringify(params),
			type: RequestType.POST
		});
		var response:ExternalGameRecordObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(200, request.getStatus());
		Assert.equals("1234", Reflect.field(response, 'id'));
		Assert.equals(Piece.WHITE, Reflect.field(response, 'currentPlayer'));
		Assert.equals(false, Reflect.field(response, 'canPass'));
		Assert.equals("20000000011111110222222200000000", Reflect.field(response, 'board'));
		Assert.equals(GameState.PLAYING, Reflect.field(response, 'state'));
		Assert.isTrue(Reflect.hasField(response, 'player'));
		Assert.equals(otherPlayerId, Reflect.field(response, 'player'));
		Assert.isTrue(Reflect.hasField(response, 'team'));
		Assert.equals(Piece.WHITE, Reflect.field(response, 'team'));
	}

	public function testNotFound() {
		var playerId = Uuid.v4();
		var params:AiMoveParams = {
			level:  Level.HARD,
			player: playerId
		};
		var request:Request = new Request({
			url: "/game/1234/ai/move/",
			data: Json.stringify(params),
			type: RequestType.POST
		});

		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(404, request.getStatus());
		Assert.equals(404, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testGameUnstarted() {
		var playerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			Handlers.AI_PLAYER, // white
			GameState.WAITING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var playerId = Uuid.v4();
		var params:AiMoveParams = {
			level:  Level.HARD,
			player: playerId
		};
		var request:Request = new Request({
			url: "/game/1234/ai/move/",
			data: Json.stringify(params),
			type: RequestType.POST
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testGameFinished() {
		var playerId = Uuid.v4();
		var otherPlayerId = Handlers.AI_PLAYER;
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.DONE
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:AiMoveParams = {
			level:  Level.HARD,
			player: playerId
		};
		var request:Request = new Request({
			url: "/game/1234/ai/move/",
			data: Json.stringify(params),
			type: RequestType.POST
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testBadPlayer() {
		var randomId = Uuid.v4();
		var playerId = Uuid.v4();
		var otherPlayerId = Handlers.AI_PLAYER;
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:AiMoveParams = {
			level:  Level.HARD,
			player: playerId
		};
		var request:Request = new Request({
			url: "/game/1234/ai/move/",
			data: Json.stringify(params),
			type: RequestType.POST
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testNotMyGame() {
		var playerId = Uuid.v4();
		var otherPlayerId = Handlers.AI_PLAYER;
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			Handlers.AI_PLAYER, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:AiMoveParams = {
			level:  Level.HARD,
			player: playerId
		};
		var request:Request = new Request({
			url: "/game/1234/ai/move/",
			data: Json.stringify(params),
			type: RequestType.POST
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testWrongPlayer() {
		var playerId = Uuid.v4();
		var otherPlayerId = Handlers.AI_PLAYER;
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:AiMoveParams = {
			level:  Level.HARD,
			player: playerId
		};
		var request:Request = new Request({
			url: "/game/1234/ai/move/",
			data: Json.stringify(params),
			type: RequestType.POST
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}
}
