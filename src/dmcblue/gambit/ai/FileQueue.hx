package dmcblue.gambit.ai;

import interealmGames.common.queue.Queue;
import sys.io.File;
import sys.FileSystem;

class FileQueue implements Queue<String> {
	private var basePath:String;
	public function new(basePath:String) {
		this.basePath = basePath;
	}

	public function add(key:String) {
		File.saveContent(this.path(key), "");
	}

	public function next():String {
		//return this.queue.shift();
		var key = FileSystem.readDirectory(this.basePath)[0];
		FileSystem.deleteFile(this.path(key));
		return key;
	}

	public function hasNext():Bool {
		return FileSystem.readDirectory(this.basePath).length > 0;
	}

	private function path(key:String) {
		return haxe.io.Path.join([this.basePath, key]);
	}
}
