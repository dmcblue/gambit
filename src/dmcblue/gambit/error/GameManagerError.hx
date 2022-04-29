package dmcblue.gambit.error;

import interealmGames.common.errors.Error;

class GameManagerError extends Error {
	static public var TYPE = "GAMBIT_GAME_MANAGER_ERROR";

	public function new() {
		super(
			GameManagerError.TYPE,
			'Service not available'
		);
	}
}
