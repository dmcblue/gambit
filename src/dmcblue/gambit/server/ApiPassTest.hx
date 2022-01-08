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
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.errors.InvalidInputError;
import dmcblue.gambit.server.parameters.MoveParams;
import utest.Assert;
import utest.Async;
import utest.Test;

class ApiPassTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testPass(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var board =
			'20000200' +
			'01010111' +
			'02002222' +
			'00100000';
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.fromString(board),
			true,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.pass("1234", playerId, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(error);
			Assert.equals("1234", Reflect.field(game, 'id'));
			Assert.equals(Piece.WHITE, Reflect.field(game, 'currentPlayer'));
			Assert.equals(false, Reflect.field(game, 'canPass'));
			Assert.equals(board, Reflect.field(game, 'board'));
			Assert.equals(GameState.PLAYING, Reflect.field(game, 'state'));
			Assert.isTrue(Reflect.hasField(game, 'player'));
			Assert.isTrue(Uuid.isV4(Reflect.field(game, 'player')));
			Assert.equals(playerId, Reflect.field(game, 'player'));
			async.done();
		});
	}

	public function testNotFound(async:Async) {
		var playerId = Uuid.v4();

		Test.api.pass("1234", playerId, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(404, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameUnstarted(async:Async) {
		var playerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			true,
			playerId, // black
			null, // white
			GameState.WAITING
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.pass("1234", playerId, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameFinished(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var board =
			'20000200' +
			'01010111' +
			'02002222' +
			'00100000';
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.fromString(board),
			true,
			playerId, // black
			otherPlayerId, // white
			GameState.DONE
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.pass("1234", playerId, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testWrongPlayer(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var board =
			'20000200' +
			'01010111' +
			'02002222' +
			'00100000';
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.fromString(board),
			true,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.pass("1234", otherPlayerId, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testCantPass(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var board =
			'20000200' +
			'01010111' +
			'02002222' +
			'00100000';
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.fromString(board),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);

		Test.api.pass("1234", playerId, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}
}
