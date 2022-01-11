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
import sys.io.File;
import sys.FileSystem;

class Builder {
	static public var ROOT = 'root';
	static private var CURRENT_PATH = '/home/dmcblue/repos/tmp/current';
	static private var QUEUE_PATH = '/home/dmcblue/repos/tmp/queue/';

	static public function main():Void {
		var connection = new FileConnection('/home/dmcblue/repos/tmp/', 'json');
		var recordPersistence:ObjectPersistence<String, Record> = new RecordPersistence(connection);
		var builder = new Builder(recordPersistence);

		var clean = false;
		if (clean) {
			Sys.println('Cleaning');
			builder.clean();
			Sys.println('Cleaned');
		}

		var queue = new FileQueue(Builder.QUEUE_PATH);
		if(queue.hasNext()) {
			Sys.println('Resuming build');
			builder.resumeBuild();
		} else {
			Sys.println('Building');
			builder.build();
		}
		Sys.println('Built');
	}

	private var recordPersistence:ObjectPersistence<String, Record>;
	private var queue:Queue<String> = new FileQueue(Builder.QUEUE_PATH);

	public function new(recordPersistence:ObjectPersistence<String, Record>) {
		this.recordPersistence = recordPersistence;
		this.queue = new FileQueue(Builder.QUEUE_PATH);
	}

	public function getCurrent():String {
		return File.getContent(Builder.CURRENT_PATH);	
	}

	public function setCurrent(name:String):Void {
		File.saveContent(Builder.CURRENT_PATH, name);
	}

	public function build() {
		var board = Board.newGame();
		var rootName = Record.createName(Piece.BLACK, board);
		var root = new Record(
			rootName,
			[]
		);
		this.recordPersistence.save(root);
		this.queue.add(root.name);
		this.runBuild();	
	}

	public function resumeBuild() {
		var name = this.getCurrent();
		var record = this.recordPersistence.get(name);
		if (record != null) {
			Sys.println('Picking up ${name}');
			this.processRecord(name);
		}
		this.runBuild();
	}

	public function runBuild() {
		while(this.queue.hasNext()) {
			var name = this.queue.next();
			this.processRecord(name);	
		}
	}

	public function processRecord(name:String):Void {
		this.setCurrent(name);
		var record = this.recordPersistence.get(name);
		if (record == null) {
			trace(name);
			throw "aaaa";
		}
		record.createChildren();
		for(child in record.getChildren()) {
			var c = this.recordPersistence.get(child.name);
			if (c == null) {
				this.queue.add(child.name);
				this.recordPersistence.save(child);
			}
		}
	}

	public function clean() {
		while(this.queue.hasNext()) {
			this.queue.next();
		}
		var records = this.recordPersistence.getAll();
		for(record in records) {
			this.recordPersistence.delete(record.name);
		}
	}
}
