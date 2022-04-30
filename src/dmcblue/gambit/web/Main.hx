package dmcblue.gambit.web;

import interealmGames.browser.api.HttpApi;
import dmcblue.gambit.server.Api;
import dmcblue.gambit.Environment;
import dmcblue.gambit.GameManagerAsync;
import dmcblue.gambit.Piece;
import dmcblue.gambit.web.Display;

class Main 
{
	static function main() 
	{
		var apiConnection = new HttpApi();
		var api = new Api(apiConnection, Environment.API_URL);
		var display = new Display();
		display.load();
		var game = new GameManagerAsync(api, display);
		game.run();
	}
}
