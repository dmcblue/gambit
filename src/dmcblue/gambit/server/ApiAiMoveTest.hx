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
import dmcblue.gambit.server.Handlers;
import dmcblue.gambit.server.errors.InvalidInputError;
import dmcblue.gambit.server.parameters.AiMoveParams;
import utest.Assert;
import utest.Async;
import utest.Test;

class ApiAiMoveTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testMove(async:Async) {
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
			level: Level.HARD,
			player: otherPlayerId
		};
		Test.api.aiMove("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(error);
			Assert.equals("1234", Reflect.field(game, 'id'));
			Assert.equals(Piece.WHITE, Reflect.field(game, 'currentPlayer'));
			Assert.equals(false, Reflect.field(game, 'canPass'));
			Assert.equals("20000000011111110222222200000000", Reflect.field(game, 'board'));
			Assert.equals(GameState.PLAYING, Reflect.field(game, 'state'));
			Assert.isTrue(Reflect.hasField(game, 'player'));
			Assert.equals(otherPlayerId, Reflect.field(game, 'player'));
			async.done();
		});
	}

	public function testNotFound(async:Async) {
		var playerId = Uuid.v4();
		var params:AiMoveParams = {
			level: Level.HARD,
			player: playerId
		};
		Test.api.aiMove("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(404, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameUnstarted(async:Async) {
		var playerId = Handlers.AI_PLAYER;
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.WAITING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:AiMoveParams = {
			level: Level.HARD,
			player: otherPlayerId
		};
		Test.api.aiMove("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameFinished(async:Async) {
		var playerId = Handlers.AI_PLAYER;
		var otherPlayerId = Uuid.v4();
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
			level: Level.HARD,
			player: otherPlayerId
		};
		Test.api.aiMove("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testWrongPlayer(async:Async) {
		var playerId = Handlers.AI_PLAYER;
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			otherPlayerId, // black
			playerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:AiMoveParams = {
			level: Level.HARD,
			player: otherPlayerId
		};
		Test.api.aiMove("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testNotMyGame(async:Async) {
		var playerId = Handlers.AI_PLAYER;
		var otherPlayerId = Uuid.v4();
		var randomPlayerId = Uuid.v4();
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
			level: Level.HARD,
			player: randomPlayerId
		};
		Test.api.aiMove("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}
}
