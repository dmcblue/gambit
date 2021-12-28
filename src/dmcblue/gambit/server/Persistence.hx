package dmcblue.gambit.server;

import interealmGames.persistence.NamespaceKeyValueConnection;
import interealmGames.persistence.ObjectPersistence;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordPersistence;

class Persistence {
	private var connection:NamespaceKeyValueConnection;

	public function new(connection:NamespaceKeyValueConnection) {
		this.connection = connection;
	}

	public function getGameRecordPersistence():ObjectPersistence<String, GameRecord> {
		return new GameRecordPersistence(this.connection);
	}
}
