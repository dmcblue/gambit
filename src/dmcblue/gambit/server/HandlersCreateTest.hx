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

class HandlersCreateTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testCreate() {
		var request:Request = new Request({
			url: "/create",
			type: RequestType.POST,
			data: Json.stringify({
				startingAs: Piece.WHITE
			})
		});
		var response:ExternalGameRecordObject = cast Json.parse(Test.server.handle(request));
		Assert.isTrue(Reflect.hasField(response, 'id'));
		Assert.isTrue(Uuid.isV4(Reflect.field(response, 'id')));
		Assert.equals(Piece.BLACK, Reflect.field(response, 'currentPlayer'));
		Assert.equals(false, Reflect.field(response, 'canPass'));
		Assert.equals("00000000111111112222222200000000", Reflect.field(response, 'board'));
		Assert.equals(GameState.WAITING, Reflect.field(response, 'state'));
		Assert.isTrue(Reflect.hasField(response, 'player'));
		Assert.isTrue(Uuid.isV4(Reflect.field(response, 'player')));

		var game:GameRecord = Test.persistence.getGameRecordPersistence().get(Reflect.field(response, 'id'));
		Assert.equals(response.id, game.id);
		Assert.equals(response.currentPlayer, game.currentPlayer);
		Assert.equals(response.canPass, game.canPass);
		Assert.equals(response.board, game.board.toString());
		Assert.equals(response.state, game.state);
	}

	public function testNoParams() {
		var request:Request = new Request({
			url: "/create",
			type: RequestType.POST
		});

		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testBadParams1() {
		var request:Request = new Request({
			url: "/create",
			type: RequestType.POST,
			data: Json.stringify({
				startingAs: 3
			})
		});

		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(400, Reflect.field(response, 'status'));
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}

	public function testStringParams() {
		var request:Request = new Request({
			url: "/create",
			type: RequestType.POST,
			data: Json.stringify({
				startingAs: '2'
			})
		});

		var response:ExternalGameRecordObject = cast Json.parse(Test.server.handle(request));
		Assert.isTrue(Reflect.hasField(response, 'id'));
		Assert.isTrue(Uuid.isV4(Reflect.field(response, 'id')));
	}
}
