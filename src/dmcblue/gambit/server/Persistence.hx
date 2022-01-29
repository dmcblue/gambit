package dmcblue.gambit.server;

import interealmGames.persistence.NamespaceKeyValueConnection;
import interealmGames.persistence.ObjectPersistence;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordPersistence;
import dmcblue.gambit.ai.Record;
import dmcblue.gambit.ai.RecordPersistence;

class Persistence {
	private var serverConnection:NamespaceKeyValueConnection;
	private var aiConnection:NamespaceKeyValueConnection;

	public function new(
		serverConnection:NamespaceKeyValueConnection,
		aiConnection:NamespaceKeyValueConnection
	) {
		this.serverConnection = serverConnection;
		this.aiConnection = aiConnection;
	}

	public function getGameRecordPersistence():ObjectPersistence<String, GameRecord> {
		return new GameRecordPersistence(this.serverConnection);
	}

	public function getAiRecordPersistence():ObjectPersistence<String, Record> {
		return new RecordPersistence(this.aiConnection);
	}
}
