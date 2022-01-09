package dmcblue.gambit.ai;

import dmcblue.gambit.PieceTools;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Board;

typedef Child = {
	var name:String;
	var success:Float;
};

typedef RecordObject = {
	var name:String;
	var children:Array<Child>;
};

class Record {
	static public function createName(team:Piece, board:Board):String {
		return PieceTools.toString(team) + board.toString();
	}

	static public function fromObject(record:RecordObject):Record {
		return new Record(
			record.name,
			record.children
		);
	}

	public var name:String;
	public var children:Array<Child>;

	public function new(name:String, children:Array<Child>) {
		this.name = name;
		this.children = children;
	}

	// doesn't take into account canPass
	public function createChildren() {
		this.children = [];
		var team = PieceTools.fromString(this.name.charAt(0));
		var boardStr = this.name.substring(1);
		var board = Board.fromString(boardStr);
		if(board.hasAnyMoreMoves(team)) {
			var opposingTeam = team == Piece.BLACK ? Piece.WHITE : Piece.BLACK;
			var positions = board.getPositionsWithMoves(opposingTeam);
			for(from in positions) {
				var tos = board.getMoves(from);
				for(to in tos) {
					var tempBoard = Board.fromString(boardStr);
					tempBoard.move({
						from: from,
						to: to
					});

					if (board.getMoves(to).length > 0) {
						this.children.push({
							name: Record.createName(team, tempBoard),
							success: -1
						});
					}

					if (board.hasAnyMoreMoves(opposingTeam)) {
						this.children.push({
							name: Record.createName(opposingTeam, tempBoard),
							success: -1
						});
					} // else DONE
				}
			}
		}
	}

	public function getChildren():Array<Record> {
		return this.children.map(function(child:Child) {
			var record = new Record(
				child.name,
				[]
			);
			record.createChildren();
			return record;
		});
	}

	public function toObject():RecordObject {
		return {
			name: this.name,
			children: this.children
		};
	}
}
