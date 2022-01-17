package dmcblue.gambit.ai;

import interealmGames.persistence.FileConnection;
import interealmGames.common.queue.Queue;
import interealmGames.common.queue.ArrayQueue;
import interealmGames.common.stack.Stack;
import interealmGames.common.stack.ArrayStack;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Board;
import dmcblue.gambit.ai.Record.RecordObject;
import dmcblue.gambit.ai.Record;
import dmcblue.gambit.ai.RecordPersistence;
import interealmGames.persistence.ObjectPersistence;
import sys.io.File;
import sys.FileSystem;

using interealmGames.common.math.MathExtension;

class Builder {
	static public var ROOT = 'root';
	static private var CURRENT_PATH = '/home/dmcblue/repos/tmp/current';
	static private var QUEUE_PATH = '/home/dmcblue/repos/tmp/queue/';

	static public function main():Void {
		var connection = new FileConnection('/home/dmcblue/repos/tmp/', 'json');
		var recordPersistence:ObjectPersistence<String, Record> = new RecordPersistence(connection);
		var builder = new Builder(recordPersistence);

		var clean = false;
		var build = false;
		var eval = true;

		if (clean) {
			Sys.println('Cleaning');
			builder.clean();
			Sys.println('Cleaned');
		}

		var queue = new FileQueue(Builder.QUEUE_PATH);
		if (build) {
			if(queue.hasNext()) {
				Sys.println('Resuming build');
				builder.resumeBuild();
			} else {
				Sys.println('Building');
				builder.build();
			}
			Sys.println('Built');
		}

		if (eval) {
			Sys.println('Evaluating');
			builder.evaluate();
			Sys.println('Evaulated');
		}
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
		record.createChildren();
		for(child in record.getChildren()) {
			var c = this.recordPersistence.get(child.name);
			if (c == null) {
				this.queue.add(child.name);
				this.recordPersistence.save(child);
			}
		}
		this.recordPersistence.save(record);
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

	public function hasBeenEvaluated(name:String):Bool {
		var record = this.recordPersistence.get(name);
		if (record.children.length == 0) {
			return true;
		}

		for(child in record.children) {
			if(child.success < 0) {
				return false;
			}
		}

		return true;
	}

	public function evaluateNode(record:Record):Float {
		if (record.children.length == 0) {
			var team = record.team();
			var board = record.board();
			var blackScore = board.calculateScore(Piece.BLACK);
			var whiteScore = board.calculateScore(Piece.WHITE);

			if (blackScore == whiteScore) {
				return 0.5; //?
			} else if(blackScore > whiteScore) {
				return team == Piece.BLACK ? 1 : 0;
			} else {
				return team == Piece.BLACK ? 0 : 1;
			}
		}

		var total = 0.0;
		for(child in record.children) {
			total += child.success;
		}

		return total/record.children.length;
	}

	public function evaluate() {
		var stack = new ArrayStack();
		var board = Board.newGame();
		var rootName = Record.createName(Piece.BLACK, board);
		stack.add(rootName);
		while(stack.hasNext()) {
			var name = stack.next();
			var record = this.recordPersistence.get(name);
			if (record.children.length > 0) {
				// check all children and see if any need more processing
				// if any, assume all
				// if none, assume this is our second viewing
				// then check all children
				//   if leaf => win state for black
				//   if not, avg of grandchildren
				var needsEvaluation = false;
				for(child in record.children) {
					if(!this.hasBeenEvaluated(child.name)) {
						needsEvaluation = true;
						break;
					}
				}

				if (needsEvaluation) {
					stack.add(name); // come back when children processed
					for(child in record.children) {
						stack.add(child.name);
					}
				} else {
					// this is redundant evaluating of children
					// Should probably cache all the values
					for(child in record.children) {
						var cr = this.recordPersistence.get(child.name);
						child.success = this.evaluateNode(cr);
					}

					this.recordPersistence.save(record);
				}
			} // else, leaf
		}
	}
}
