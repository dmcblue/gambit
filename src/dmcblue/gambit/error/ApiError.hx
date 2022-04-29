package dmcblue.gambit.error;

import interealmGames.common.errors.Error;

class ApiError extends Error {
	static public var TYPE = "GAMBIT_API_ERROR";

	public function new(message:String) {
		super(
			ApiError.TYPE,
			message
		);
	}
}
