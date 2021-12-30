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

class HandlersPassTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testPass() {
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
		var request:Request = new Request({
			url: '/game/1234/pass/${playerId}',
			type: RequestType.GET
		});
		var response:ExternalGameRecordObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(200, request.getStatus());
		Assert.equals("1234", Reflect.field(response, 'id'));
		Assert.equals(Piece.WHITE, Reflect.field(response, 'currentPlayer'));
		Assert.equals(false, Reflect.field(response, 'canPass'));
		Assert.equals(board, Reflect.field(response, 'board'));
		Assert.equals(GameState.PLAYING, Reflect.field(response, 'state'));
		Assert.isTrue(Reflect.hasField(response, 'player'));
		Assert.isTrue(Uuid.isV4(Reflect.field(response, 'player')));
		Assert.equals(otherPlayerId, Reflect.field(response, 'player'));
		Assert.isTrue(Reflect.hasField(response, 'team'));
		Assert.equals(Piece.BLACK, Reflect.field(response, 'team'));
	}

	public function testNotFound() {
		var playerId = Uuid.v4();
		var request:Request = new Request({
			url: '/game/1234/pass/${playerId}',
			type: RequestType.GET
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
			true,
			playerId, // black
			null, // white
			GameState.WAITING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var request:Request = new Request({
			url: '/game/1234/pass/${playerId}',
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testGameFinished() {
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
		var request:Request = new Request({
			url: '/game/1234/pass/${playerId}',
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testWrongPlayer() {
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
		var request:Request = new Request({
			url: '/game/1234/pass/${otherPlayerId}',
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testCantPass() {
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
		var request:Request = new Request({
			url: '/game/1234/pass/${playerId}',
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, request.getStatus());
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}
}
