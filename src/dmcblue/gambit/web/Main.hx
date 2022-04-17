package dmcblue.gambit.web;

import interealmGames.browser.api.HttpApi;
import dmcblue.gambit.server.Api;
import dmcblue.gambit.GameManagerAsync;
import dmcblue.gambit.Piece;
import dmcblue.gambit.web.Display;

class Main 
{
	static function main() 
	{
		var apiConnection = new HttpApi();
		var api = new Api(apiConnection, "http://0.0.0.0:8080");
		var display = new Display();
		display.load();
		var game = new GameManagerAsync(api, display);
		game.run();
	}
}
