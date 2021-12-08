package dmcblue.gambit.server.errors;

import interealmGames.common.errors.Error;

class InvalidInputError extends Error {
	static public var TYPE = "INVALID_INPUT_ERROR";

	public function new(input:Dynamic) {
		super(
			InvalidInputError.TYPE,
			'Invalid input "$input"'
		);
	}
}
