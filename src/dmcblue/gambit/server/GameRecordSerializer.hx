package dmcblue.gambit.server;

import interealmGames.common.serializer.object.Json;
import interealmGames.common.serializer.object.Serializer;
import dmcblue.gambit.server.GameRecord;

class GameRecordObjectSerializer extends Json<GameRecordObject> {}

class GameRecordSerializer implements Serializer<GameRecord> {
	private var objectSerializer:GameRecordObjectSerializer;
	public function new() {
		this.objectSerializer = new GameRecordObjectSerializer();
	}

	public function decode(s:String):GameRecord {
		var gro = this.objectSerializer.decode(s);
		return GameRecord.fromObject(gro);
	}

	public function encode(gameRecord:GameRecord):String {
		return this.objectSerializer.encode(gameRecord.toObject());
	}
}
