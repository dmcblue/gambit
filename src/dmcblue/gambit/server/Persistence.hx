package dmcblue.gambit.server;

import interealmGames.persistence.FileSystemConnection;
import interealmGames.persistence.ObjectPersistence;
import interealmGames.persistence.JsonFilePersistence;
import dmcblue.gambit.server.GameRecord;

class Persistence {
	private var fileConnection:FileSystemConnection;

	public function new(fileConnection:FileSystemConnection) {
		this.fileConnection = fileConnection;
	}

	public function getGameRecordPersistence():ObjectPersistence<String, GameRecord> {
		return new GameRecordPersistence(this.fileConnection);
	}
}
