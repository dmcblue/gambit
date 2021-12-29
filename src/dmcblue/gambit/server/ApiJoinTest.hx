package dmcblue.gambit.server;

import dmcblue.gambit.server.Api;
import dmcblue.gambit.server.GameRecord;
import interealmGames.server.http.Error;
import interealmGames.server.http.ErrorObject;
import interealmGames.common.uuid.Uuid;
import dmcblue.gambit.server.ExternalGameRecordObject;
import haxe.Json;
import interealmGames.server.http.test.Request;
import interealmGames.server.http.RequestType;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.errors.InvalidInputError;
import utest.Assert;
import utest.Async;
import utest.Test;

class ApiJoinTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testJoin(async:Async) {
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			otherPlayerId,
			"",
			GameState.WAITING
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.join("1234", function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(error);
			Assert.equals("1234", Reflect.field(game, 'id'));
			Assert.equals(Piece.BLACK, Reflect.field(game, 'currentPlayer'));
			Assert.equals(false, Reflect.field(game, 'canPass'));
			Assert.equals("00000000111111112222222200000000", Reflect.field(game, 'board'));
			Assert.equals(GameState.PLAYING, Reflect.field(game, 'state'));
			Assert.isTrue(Reflect.hasField(game, 'player'));
			Assert.isTrue(Uuid.isV4(Reflect.field(game, 'player')));
			Assert.notEquals(otherPlayerId, Reflect.field(game, 'player'));
			async.done();
		});
	}

	public function testNotFound(async:Async) {
		var request:Request = new Request({
			url: '/game/1234/join',
			type: RequestType.GET
		});
		Test.api.join("1234", function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(404, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameInProgress(async:Async) {
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			otherPlayerId,
			"",
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.join("1234", function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameFinished(async:Async) {
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			otherPlayerId,
			"",
			GameState.DONE
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.join("1234", function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}
}
