package dmcblue.gambit.terminal;

import interealmGames.browser.api.HttpApi;
import dmcblue.gambit.server.Api;
import dmcblue.gambit.GameManager;
import dmcblue.gambit.Piece;
import dmcblue.gambit.terminal.Display;

class Main 
{
	static function main() 
	{
		var apiConnection = new HttpApi();
		var api = new Api(apiConnection, "http://0.0.0.0:8080");
		var display = new Display();
		var game = new GameManager(api, display);
		display.greetings();
		game.run();
	}
}
