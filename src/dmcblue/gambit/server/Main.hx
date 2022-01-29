package dmcblue.gambit.server;

import dmcblue.gambit.server.Handlers;
import dmcblue.gambit.server.Handlers;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordPersistence;
import dmcblue.gambit.server.Persistence;
import interealmGames.server.http.RequestHandler;
import interealmGames.persistence.FileConnection;
import interealmGames.persistence.RedisConnection;
import interealmGames.persistence.ObjectPersistence;

class Main 
{
	static public var GAMBIT_SERVER_ROOT_FILE_PATH:String;
	
	// static function __init__() dotenv.Env.init();
	
	static function main() 
	{
		/*var connection = new RedisConnection("localhost", 6379, 7);
		var persistence = new Persistence(connection);
		var handlers = new Handlers(persistence);
		handlers.getHandlers();*/
	}

	static function getHandlers():Array<RequestHandler> {
		var serverConnection = new RedisConnection("localhost", 6379, 7);
		var aiConnection = new FileConnection('/home/dmcblue/repos/tmp/', 'json');
		var persistence = new Persistence(
			serverConnection,
			aiConnection
		);
		var handlers = new Handlers(persistence);
		return handlers.getHandlers();
	}
}
