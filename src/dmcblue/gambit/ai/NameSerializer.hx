package dmcblue.gambit.ai;

import dmcblue.gambit.Piece;
import dmcblue.gambit.PieceTools
import dmcblue.gambit.ai.HexSerializer;
import interealmGames.common.serializer.Serializer;

using StringTools;

class NameSerializer extends HexSerializer {

	public function new() {}
	
	
	/* INTERFACE interealmGames.editorBackend.serializer.Serializer.Serializer<T> */
	
	/**
		1
		row 0 - BLACK => 2 char
		...
		row 3 - BLACK
		row 0 - WHITE
		...
		row 3 - WHITE


		total 1 + (2 * 4) + (2 * 4)
	**/

	// hex to bin
	public function decode(name:String):Dynamic 
	{
		var output = name.charAt(0);
		var black = "";
		for (i in 0...4) {
			black += name.substr(1 + (i * 2), 2);
		}
		black = super.decode(black);


		var white = "";
		for (i in 0...4) {
			white += name.substr(1 + 8 + (i * 2), 2);
		}
		white = super.decode(white);

		output += this.zip(black, white);
		
		return output;
	}
	
	// bin to hex
	// 00000201 => 0401 sort of
	public function encode(name:String):String 
	{
		var output = name.charAt(0);

		var black = this.mask(name.substr(1), PieceTools.toString(Piece.BLACK));
		output += super.encode(black);


		var white = this.mask(name.substr(1), PieceTools.toString(Piece.BLACK));
		output += super.encode(white);
		
		return output;
	}

	private function mask(name:String, team:String) {
		var output = "";
		for(i in 1...name.length) {
			var char = name.charAt(i);
			if (char == team) {
				output += "1";
			} else {
				output += "0";
			}
		}

		return output;
	}

	private function zip(black:String, white:String) {
		var bl = PieceTools.toString(Piece.BLACK);
		var wh = PieceTools.toString(Piece.WHITE)
		var output = "";
		for(i in 0...black.length) {
			if (black[i] != "0") {
				output += bl;
			} else if (white[i] != "0") {
				output += wh;
			} else {
				output += "0";
			}
		}

		return output;
	}
}
