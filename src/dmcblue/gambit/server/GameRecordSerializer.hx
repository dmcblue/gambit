package dmcblue.gambit.server;

import interealmGames.common.serializer.object.Serializer;

class GameRecordSerializer implements Serializer<GameRecord> 
{

	public function new() {}
	
	
	/* INTERFACE interealmGames.common.serializer.object.Serializer.Serializer<T> */
	
	public function decode(s:String):GameRecord
	{
		var item:GameRecord = GameRecord.fromString('',s);
		return item;
	}
	
	public function encode(t:GameRecord):String 
	{
		return t.toString();
	}
}
