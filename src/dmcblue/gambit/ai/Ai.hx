package dmcblue.gambit.ai;

import thx.Set;
import interealmGames.persistence.ObjectPersistence;
import interealmGames.persistence.errors.NoRecordError;
import dmcblue.gambit.Board;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.Position;
import dmcblue.gambit.ai.Level;
import dmcblue.gambit.ai.Record;
import dmcblue.gambit.ai.Record.Child;
import dmcblue.gambit.ai.RecordPersistence;

// using StringTools;
using interealmGames.common.StringToolsExtension;

typedef NameCount = {
	var name: String;
	var count: Float;
};

class Ai {
	private var persistence:ObjectPersistence<String, Record>;

	public function new(persistence:ObjectPersistence<String, Record>) {
		this.persistence = persistence;
	}

	public function getMove(level:Level, team:Piece, board:Board):Move {
		var name = Record.createName(team, board);
		var record = this.persistence.get(name);
		if (record == null) {
			// throw 'ERROR: ${name}';
			throw new NoRecordError('Record', name);
		}
		var children:Array<Child> = record.children;
		// Reverse Sort
		// children.sort(function(a:Child, b:Child) {
		// 	if (a.success == b.success) {
		// 		return 0;
		// 	}

		// 	if (a.success > b.success) {
		// 		return -1;
		// 	}

		// 	return 1;
		// });

		// var factor = switch(level) {
		// 	case Level.EASY: 1;
		// 	case Level.MEDIUM: 2;
		// 	case Level.HARD: 3;
		// };

		// var count = 0.0;
		// var counts:Array<NameCount> = [];
		// for(child in children) {
		// 	// add 0.01 to deal with 0 success
		// 	count += (child.success + 0.01) * factor;
		// 	counts.push({
		// 		name: child.name,
		// 		count: count
		// 	});
		// }

		// var value = Math.random() * count;

		// var choice:String = "";
		// for(option in counts) {
		// 	if (option.count > value) {
		// 		choice = option.name;
		// 		break;
		// 	}
		// }

		// // get move from name
		// return this.moveFromStrings(
		// 	team,
		// 	board.toString(),
		// 	choice.substring(1) // standardize, DRY			
		// );

		return this.chooseMoveFromChildren(level, team, board, children);
	}


	public function getMoveFrom(level:Level, team:Piece, board:Board, from:Position):Move {
		var name = Record.createName(team, board);
		var record = this.persistence.get(name);
		if (record == null) {
			// throw 'ERROR: ${name}';
			throw new NoRecordError('Record', name);
		}

		var tos = board.getMoves(from);
		var boards:Array<String> = [];
		for(to in tos) {
			var newBoard = board.clone();
			newBoard.move({
				from: from,
				to: to
			});
			boards.push(Record.createName(Piece.WHITE, newBoard));
			boards.push(Record.createName(Piece.BLACK, newBoard));
		}

		var validChildren = record.children.filter(function(child:Child) {
			return boards.indexOf(child.name) != -1;
		});
		
		// var children:Array<Child> = record.children;
		// // Reverse Sort
		// children.sort(function(a:Child, b:Child) {
		// 	if (a.success == b.success) {
		// 		return 0;
		// 	}

		// 	if (a.success > b.success) {Child
		// 	case Level.MEDIUM: 2;
		// 	case Level.HARD: 3;
		// };

		// var count = 0.0;
		// var counts:Array<NameCount> = [];
		// for(child in children) {
		// 	// add 0.01 to deal with 0 success
		// 	count += (child.success + 0.01) * factor;
		// 	counts.push({
		// 		name: child.name,
		// 		count: count
		// 	});
		// }

		// var value = Math.random() * count;

		// var choice:String = "";
		// for(option in counts) {
		// 	if (option.count > value) {
		// 		choice = option.name;
		// 		break;
		// 	}
		// }

		// // get move from name
		// return this.moveFromStrings(
		// 	team,
		// 	board.toString(),
		// 	choice.substring(1) // standardize, DRY			
		// );
		return this.chooseMoveFromChildren(level, team, board, validChildren);
	}

	public function chooseMoveFromChildren(level:Level, team:Piece, board:Board, children:Array<Child>):Move {
		// Reverse Sort
		children.sort(function(a:Child, b:Child) {
			if (a.success == b.success) {
				return 0;
			}

			if (a.success > b.success) {
				return -1;
			}

			return 1;
		});

		var factor = switch(level) {
			case Level.EASY: 1;
			case Level.MEDIUM: 2;
			case Level.HARD: 3;
		};

		var count = 0.0;
		var counts:Array<NameCount> = [];
		for(child in children) {
			// add 0.01 to deal with 0 success
			count += (child.success + 0.01) * factor;
			counts.push({
				name: child.name,
				count: count
			});
		}

		var value = Math.random() * count;

		var choice:String = "";
		for(option in counts) {
			if (option.count > value) {
				choice = option.name;
				break;
			}
		}

		// get move from name
		return this.moveFromStrings(
			team,
			board.toString(),
			choice.substring(1) // standardize, DRY			
		);
	}

	public function moveFromStrings(team:Piece, start:String, finish:String):Move {
		var startIndices:Set<Int> =
			Set.createInt(
				StringTools.indexOfAll(start, PieceTools.toString(team))
			);
		var finishIndices:Set<Int> =
			Set.createInt(
				StringTools.indexOfAll(finish, PieceTools.toString(team))
			);
		var startIndex:Int =
			startIndices
				.difference(finishIndices)
				.toArray()[0];
		var finishIndex:Int =
			finishIndices
				.difference(startIndices)
				.toArray()[0];

		return {
			from: this.indexToPosition(startIndex),
			to: this.indexToPosition(finishIndex)
		};
	}

	public function indexToPosition(index:Int):Position {
		var y = Math.floor(index/8.0);
		var x = index % 8;
		return new Position(x, y);
	}
}
