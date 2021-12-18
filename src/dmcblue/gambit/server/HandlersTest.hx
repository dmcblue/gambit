package dmcblue.gambit.server;

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
				startingPlayer: "1"
			})
		});
		var response:GameRecord = Test.server.handle(request);
		trace(response);
		Assert.equals("100000000111111112222222200000000", response.toString());
	}
}
