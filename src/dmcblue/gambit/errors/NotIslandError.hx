package dmcblue.gambit.errors;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import interealmGames.common.errors.Error;

class NotIslandError extends Error {
	static public var TYPE = "NOT_ISLAND_ERROR";

	public function new(position:Position) {
		super(
			NotIslandError.TYPE,
			'"$position" not Island'
		);
	}
}
