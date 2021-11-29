package dmcblue.gambit;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;

interface GameMaster {
	public function getBoard():Array<Array<Piece>>;
	public function getMoves(position:Position):Array<Position>;
}
