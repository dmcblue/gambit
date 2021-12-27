package dmcblue.gambit.server;

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
import dmcblue.gambit.server.parameters.MoveParams;
import utest.Assert;
import utest.Async;
import utest.Test;

class HandlersPassTest extends Test 
{
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
		Assert.equals("1234", Reflect.field(response, 'id'));
		Assert.equals(Piece.WHITE, Reflect.field(response, 'currentPlayer'));
		Assert.equals(false, Reflect.field(response, 'canPass'));
		Assert.equals(board, Reflect.field(response, 'board'));
		Assert.equals(GameState.PLAYING, Reflect.field(response, 'state'));
		Assert.isTrue(Reflect.hasField(response, 'player'));
		Assert.isTrue(Uuid.isV4(Reflect.field(response, 'player')));
		Assert.equals(otherPlayerId, Reflect.field(response, 'player'));
	}
}
