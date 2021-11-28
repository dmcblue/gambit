package dmcblue.gambit;

import dmcblue.gambit.Position;

interface GameMaster {
	//getBoard
	public function getMoves(position:Position):Array<Position>;
}
