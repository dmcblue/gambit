package dmcblue.gambit.server;

import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.server.ExternalGameRecordObject;
import dmcblue.gambit.server.ExternalGameRecordObject;
import interealmGames.common.serializer.object.Json;
import interealmGames.common.serializer.object.Serializer;
import interealmGames.persistence.ObjectPersistence;
import dmcblue.gambit.server.GameRecord;

class ExternalGameRecordObjectSerializer extends Json<ExternalGameRecordObject> {}

class ExternalGameRecordSerializer implements Serializer<GameRecord> {
	private var currentPlayer:UuidV4;
	private var objectSerializer:ExternalGameRecordObjectSerializer;
	private var persistence:ObjectPersistence<String, GameRecord>;
	public function new(persistence:ObjectPersistence<String, GameRecord>, currentPlayer:UuidV4) {
		this.objectSerializer = new ExternalGameRecordObjectSerializer();
		this.persistence = persistence;
		this.currentPlayer = currentPlayer;
	}

	public function decode(s:String):GameRecord {
		var egro:ExternalGameRecordObject = this.objectSerializer.decode(s);
		return this.persistence.get(egro.id);
	}

	public function encode(gameRecord:GameRecord):String {
		var obj:ExternalGameRecordObject = {
			id: gameRecord.id,
			board: gameRecord.board.toString(),
			currentPlayer: gameRecord.currentPlayer,
			canPass: gameRecord.canPass,
			state: gameRecord.state,
			player: this.currentPlayer
		};
		return this.objectSerializer.encode(obj);
	}
}
