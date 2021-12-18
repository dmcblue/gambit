package dmcblue.gambit.server;

import dmcblue.gambit.server.Handlers;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordPersistence;
import dmcblue.gambit.server.Persistence;
import interealmGames.server.http.RequestHandler;
import interealmGames.persistence.StandardFileSystemConnection;
import interealmGames.persistence.ObjectPersistence;

class Main 
{
	static public var GAMBIT_SERVER_ROOT_FILE_PATH:String;
	
	// static function __init__() dotenv.Env.init();
	
	static function main() 
	{
		var fileConnection = new StandardFileSystemConnection();
		var persistence = new Persistence(fileConnection);
		var handlers = new Handlers(persistence);
		handlers.getHandlers();
	}
}
