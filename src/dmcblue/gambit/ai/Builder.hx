package dmcblue.gambit.ai;

import interealmGames.persistence.FileConnection;
import interealmGames.common.queue.Queue;
import interealmGames.common.queue.ArrayQueue;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Board;
import dmcblue.gambit.ai.Record.RecordObject;
import dmcblue.gambit.ai.Record;
import dmcblue.gambit.ai.RecordPersistence;
import interealmGames.persistence.ObjectPersistence;
import sys.FileSystem;

class Builder {
	static public var ROOT = 'root';

	static public function main():Void {
		var connection = new FileConnection('/home/dmcblue/repos/tmp/', 'json');
		var recordPersistence:ObjectPersistence<String, Record> = new RecordPersistence(connection);
		var builder = new Builder(recordPersistence);
		trace('Cleaning');
		builder.clean();
		trace('Cleaned');
		trace('Building');
		builder.build();
		trace('Built');
	}

	private var recordPersistence:ObjectPersistence<String, Record>;
	private var queue:Queue<String> = new FileQueue('/home/dmcblue/repos/gambit/queue/');

	public function new(recordPersistence:ObjectPersistence<String, Record>) {
		this.recordPersistence = recordPersistence;
	}

	public function build() {
		//this.queue = new FileQueue('/home/dmcblue/repos/gambit/queue/');
		this.queue = new ArrayQueue();
		var board = Board.newGame();
		var rootName = Record.createName(Piece.BLACK, board);
		var root = new Record(
			rootName,
			Builder.ROOT,
			[]
		);
		this.recordPersistence.save(root);
		this.queue.add(root.name);
		while(this.queue.hasNext()) {
			var name = this.queue.next();
			var record = this.recordPersistence.get(name);
			if (record == null) {
				trace(name);
				throw "aaaa";
			}
			record.createChildren();
			for(child in record.getChildren()) {
				this.queue.add(child.name);
				this.recordPersistence.save(child);
			}
		}
	}

	public function clean() {
		this.queue = new FileQueue('/home/dmcblue/repos/gambit/queue/');
		while(this.queue.hasNext()) {
			this.queue.next();
			// var name = this.queue.next();
			//FileSystem.deleteFile('/home/dmcblue/repos/gambit/queue/${name}');
		}
		var records = this.recordPersistence.getAll();
		for(record in records) {
			this.recordPersistence.delete(record.name);
		}
	}
}
