package dmcblue.gambit.server;

import interealmGames.persistence.FilePersistence;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordSerializer;
/**
 * 
 */
class GameRecordPersistence extends FilePersistence<String, GameRecord> 
{
	public function new(basePath:String) 
	{
		super(basePath, 'id', new GameRecordSerializer(), 'gm');
	}
}
