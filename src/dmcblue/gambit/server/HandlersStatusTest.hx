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

class HandlersStatusTest extends Test 
{
	public function testStatus() {
		var request:Request = new Request({
			url: '/status',
			type: RequestType.GET
		});
		var response:ErrorObject = cast Json.parse(Test.server.handle(request));
		Assert.equals(200, request.getStatus());
		Assert.isTrue(Reflect.hasField(response, 'message'));
	}
}
