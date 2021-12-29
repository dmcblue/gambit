package dmcblue.gambit.server;

import interealmGames.server.http.ErrorObject;
import dmcblue.gambit.server.ExternalGameRecordObject;
import dmcblue.gambit.server.parameters.CreateParams;
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

class ApiCreateTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	// @:timeout(250) //change timeout (default: 250ms)
	public function testCreate(async:Async) {
		var params:CreateParams = {
			startingAs: Piece.WHITE
		};
		Test.api.create(params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(error);
			Assert.isTrue(Reflect.hasField(game, 'id'));
			Assert.isTrue(Uuid.isV4(Reflect.field(game, 'id')));
			Assert.equals(Piece.BLACK, Reflect.field(game, 'currentPlayer'));
			Assert.equals(false, Reflect.field(game, 'canPass'));
			Assert.equals("00000000111111112222222200000000", Reflect.field(game, 'board'));
			Assert.equals(GameState.WAITING, Reflect.field(game, 'state'));
			Assert.isTrue(Reflect.hasField(game, 'player'));
			Assert.isTrue(Uuid.isV4(Reflect.field(game, 'player')));
			async.done();
		});
	}
}
