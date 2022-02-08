package dmcblue.gambit.error;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import interealmGames.common.errors.Error;

class EndGameInterrupt extends Error {
	static public var TYPE = "END_GAME_INTERRUPT";

	public function new() {
		super(
			EndGameInterrupt.TYPE,
			''
		);
	}
}
