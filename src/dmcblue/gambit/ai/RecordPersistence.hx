package dmcblue.gambit.ai;

import interealmGames.common.serializer.object.Json;
import dmcblue.gambit.ai.Record.RecordObject;
import dmcblue.gambit.ai.Record;
import interealmGames.persistence.NamespaceKeyValueConnection;
import interealmGames.persistence.ObjectPersistence;
import interealmGames.persistence.SerializedPersistence;

class RecordPersistence implements ObjectPersistence<String, Record> {
	private var recordObjectPersistence:ObjectPersistence<String, RecordObject>;
	public function new(connection:NamespaceKeyValueConnection) {
		this.recordObjectPersistence =
			new SerializedPersistence<String, RecordObject>(
				connection,
				"name",
				"ai",
				new Json<RecordObject>()
			);
	}

	public function delete(id:String):Void {
		this.recordObjectPersistence.delete(id);
	}

	public function get(id:String):Null<Record> {
		var ro:Null<RecordObject> = this.recordObjectPersistence.get(id);
		return ro == null ? null : Record.fromObject(ro);
	}

	public function getAll():Array<Record> {
		var results:Array<Record> = [];
		var ros = this.recordObjectPersistence.getAll();
		for(ro in ros) {
			results.push(Record.fromObject(ro));
		}
		return results;
	}

	public function getAllBy<V>(propertyName:String, propertyValue:V):Array<Record> {
		var results:Array<Record> = [];
		var ros = this.recordObjectPersistence.getAllBy(propertyName, propertyValue);
		for(ro in ros) {
			results.push(Record.fromObject(ro));
		}
		return results;
	}

	public function save(record:Record):Void {
		this.recordObjectPersistence.save(record.toObject());
	}
}
