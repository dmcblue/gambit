package dmcblue.gambit.server;

import haxe.Json;
import sys.io.File;
import interealmGames.server.http.RequestHandler;
import interealmGames.persistence.ConnectionFactory;
import interealmGames.persistence.FileConnection;
import interealmGames.persistence.RedisConnection;
import interealmGames.persistence.ObjectPersistence;
import dmcblue.gambit.server.Configuration in Config;
import dmcblue.gambit.server.Handlers;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordPersistence;
import dmcblue.gambit.server.Persistence;

class Main 
{
	static function main() 
	{

	}

	static function getHandlers():Array<RequestHandler> {
		new dotenv.Dotenv('../.env').load();
		var configPath = Sys.getEnv('GAMBIT_CONFIG_PATH');
		var config:Config = cast Json.parse(File.getContent(configPath));
		var serverConnection = ConnectionFactory.connection(config.gameConnection);
		var aiConnection = ConnectionFactory.connection(config.aiConnection);
		var persistence = new Persistence(
			serverConnection,
			aiConnection
		);
		var handlers = new Handlers(persistence);
		return handlers.getHandlers();
	}
}
