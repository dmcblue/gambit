package dmcblue.gambit.error;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import interealmGames.common.errors.Error;

class OccupiedSpaceError extends Error {
	static public var TYPE = "OCCUPIED_SPACE_ERROR";

	public function new(position:Position, occupiedBy:Piece) {
		super(
			OccupiedSpaceError.TYPE,
			'Position "${position}" taken by $occupiedBy'
		);
	}
}
