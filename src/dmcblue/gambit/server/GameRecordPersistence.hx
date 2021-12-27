package dmcblue.gambit.server;

import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecord;
import interealmGames.persistence.JsonFilePersistence;
import interealmGames.persistence.FileSystemConnection;
import interealmGames.persistence.FileSystemConnection;
import interealmGames.persistence.JsonFilePersistence;
import interealmGames.persistence.ObjectPersistence;
import dmcblue.gambit.server.GameRecord;

class GameRecordPersistence implements ObjectPersistence<String, GameRecord> {
	private var gameRecordObjectPersistence:ObjectPersistence<String, GameRecordObject>;
	public function new(fileConnection:FileSystemConnection) {
		this.gameRecordObjectPersistence =
			new JsonFilePersistence(
				fileConnection,
				"games",
				"id"
			);
	}

	public function get(id:String):Null<GameRecord> {
		return GameRecord.fromObject(
			this.gameRecordObjectPersistence.get(id)
		);
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
