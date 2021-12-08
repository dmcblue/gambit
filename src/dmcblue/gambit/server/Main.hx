package dmcblue.gambit.server;

import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordPersistence;

class Main 
{
	static public var GAMBIT_SERVER_ROOT_FILE_PATH:String;
	
	static function __init__() dotenv.Env.init();
	
	static function main() 
	{
		
	}
	
	public static function getHandlers():Array<RequestHandler> {
		return Handlers.getHandlers();
	}
	
	public static function getGameRecordPersistence():ObjectPersistence<String, GameRecord> {
		var here = Main.GAMBIT_SERVER_ROOT_FILE_PATH;
		
		return new GameRecordPersistence(here);
	}
}
