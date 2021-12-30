package dmcblue.gambit.server;

import dmcblue.gambit.server.GameRecord;
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

class HandlersJoinTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testJoin() {
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false, // black
			otherPlayerId, // white
			"",
			GameState.WAITING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var request:Request = new Request({
			url: "/game/1234/join",
			type: RequestType.GET
		});
		var response:ExternalGameRecordObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(200, request.getStatus());
		Assert.equals("1234", Reflect.field(response, 'id'));
		Assert.equals(Piece.BLACK, Reflect.field(response, 'currentPlayer'));
		Assert.equals(false, Reflect.field(response, 'canPass'));
		Assert.equals("00000000111111112222222200000000", Reflect.field(response, 'board'));
		Assert.equals(GameState.PLAYING, Reflect.field(response, 'state'));
		Assert.isTrue(Reflect.hasField(response, 'player'));
		Assert.isTrue(Uuid.isV4(Reflect.field(response, 'player')));
		Assert.notEquals(otherPlayerId, Reflect.field(response, 'player'));
		Assert.isTrue(Reflect.hasField(response, 'team'));
		Assert.equals(Piece.BLACK, Reflect.field(response, 'team'));
		trace(haxe.Json.stringify(response));
	}

	public function testNotFound() {
		var request:Request = new Request({
			url: '/game/1234/join',
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(404, request.getStatus());
		Assert.equals(404, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testGameInProgress() {
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
		var request:Request = new Request({
			url: "/game/1234/join",
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testGameFinished() {
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
		var request:Request = new Request({
			url: "/game/1234/join",
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}
}
