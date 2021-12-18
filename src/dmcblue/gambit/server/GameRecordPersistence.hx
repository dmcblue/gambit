package dmcblue.gambit.server;

import interealmGames.persistence.FilePersistence;
import interealmGames.persistence.FileSystemConnection;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordSerializer;
/**
 * 
 */
class GameRecordPersistence extends FilePersistence<String, GameRecord> 
{
	public function new(fileConnection:FileSystemConnection, basePath:String)
	{
		super(fileConnection, basePath, 'id', new GameRecordSerializer(), 'gm');
	}
}
