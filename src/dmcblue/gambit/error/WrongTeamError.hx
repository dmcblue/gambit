package dmcblue.gambit.error;

import dmcblue.gambit.Piece;
import interealmGames.common.errors.Error;

class WrongTeamError extends Error {
	static public var TYPE = "WRONG_TEAM_ERROR";

	public function new(team:Piece) {
		super(
			WrongTeamError.TYPE,
			'Wrong team "${team}" for this turn'
		);
	}
}
