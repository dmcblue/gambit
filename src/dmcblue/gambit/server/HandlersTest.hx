package dmcblue.gambit.server;

import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecord;
import interealmGames.server.http.Error;
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

class HandlersTest extends Test 
{
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

	public function testJoin() {
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
		var request:Request = new Request({
			url: "/game/1234/join",
			type: RequestType.GET
		});
		var response:ExternalGameRecordObject = cast Json.parse(Test.server.handle(request));
		Assert.equals("1234", Reflect.field(response, 'id'));
		Assert.equals(Piece.BLACK, Reflect.field(response, 'currentPlayer'));
		Assert.equals(false, Reflect.field(response, 'canPass'));
		Assert.equals("00000000111111112222222200000000", Reflect.field(response, 'board'));
		Assert.equals(GameState.PLAYING, Reflect.field(response, 'state'));
		Assert.isTrue(Reflect.hasField(response, 'player'));
		Assert.isTrue(Uuid.isV4(Reflect.field(response, 'player')));
		Assert.notEquals(otherPlayerId, Reflect.field(response, 'player'));
	}
}
