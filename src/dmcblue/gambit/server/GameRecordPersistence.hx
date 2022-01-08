package dmcblue.gambit.server;

import interealmGames.common.serializer.object.Json;
import dmcblue.gambit.server.GameRecordObject;
import dmcblue.gambit.server.GameRecord;
import interealmGames.persistence.NamespaceKeyValueConnection;
import interealmGames.persistence.ObjectPersistence;
import interealmGames.persistence.SerializedPersistence;

class GameRecordPersistence implements ObjectPersistence<String, GameRecord> {
	private var gameRecordObjectPersistence:ObjectPersistence<String, GameRecordObject>;
	public function new(connection:NamespaceKeyValueConnection) {
		this.gameRecordObjectPersistence =
			new SerializedPersistence<String, GameRecordObject>(
				connection,
				"id",
				"games",
				new Json<GameRecordObject>()
			);
	}

	public function delete(id:String):Void {
		this.gameRecordObjectPersistence.delete(id);
	}

	public function get(id:String):Null<GameRecord> {
		var gro:Null<GameRecordObject> = this.gameRecordObjectPersistence.get(id);
		return gro == null ? null : GameRecord.fromObject(gro);
	}

	public function getAll():Array<GameRecord> {
		var results:Array<GameRecord> = [];
		var gros = this.gameRecordObjectPersistence.getAll();
		for(gro in gros) {
			results.push(GameRecord.fromObject(gro));
		}
		return results;
	}

	public function getAllBy<V>(propertyName:String, propertyValue:V):Array<GameRecord> {
		var results:Array<GameRecord> = [];
		var gros = this.gameRecordObjectPersistence.getAllBy(propertyName, propertyValue);
		for(gro in gros) {
			results.push(GameRecord.fromObject(gro));
		}
		return results;
	}

	public function save(game:GameRecord):Void {
		this.gameRecordObjectPersistence.save(game.toObject());
	}
}
