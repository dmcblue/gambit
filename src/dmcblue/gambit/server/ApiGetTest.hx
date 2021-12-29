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

class ApiGetTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testGet(async:Async) {
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

		Test.api.get("1234", function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(error);
			Assert.equals("1234", Reflect.field(game, 'id'));
			Assert.equals(Piece.BLACK, Reflect.field(game, 'currentPlayer'));
			Assert.equals(true, Reflect.field(game, 'canPass'));
			Assert.equals(board, Reflect.field(game, 'board'));
			Assert.equals(GameState.PLAYING, Reflect.field(game, 'state'));
			Assert.isFalse(Reflect.hasField(game, 'player'));
			async.done();
		});
	}

	public function testNotFound(async:Async) {
		Test.api.get("1234", function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(404, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}
}
