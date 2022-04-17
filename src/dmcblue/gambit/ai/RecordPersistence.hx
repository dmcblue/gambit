package dmcblue.gambit.ai;

import interealmGames.common.serializer.object.Json;
import dmcblue.gambit.ai.Record.RecordObject;
import dmcblue.gambit.ai.Record;
import interealmGames.persistence.NamespaceKeyValueConnection;
import interealmGames.persistence.ObjectPersistence;
import interealmGames.persistence.SerializedPersistence;

class RecordPersistence implements ObjectPersistence<String, Record> {
	private var dictionary:Map<String, String> = [
		'00000000' => '00',
		'00000001' => '01',
		'00000010' => '02',
		'00000011' => '03',
		'00000100' => '04',
		'00000101' => '05',
		'00000110' => '06',
		'00000111' => '07',
		'00001000' => '08',
		'00001001' => '09',
		'00001010' => '0a',
		'00001011' => '0b',
		'00001100' => '0c',
		'00001101' => '0d',
		'00001110' => '0e',
		'00001111' => '0f',
		'00010000' => '10',
		'00010001' => '11',
		'00010010' => '12',
		'00010011' => '13',
		'00010100' => '14',
		'00010101' => '15',
		'00010110' => '16',
		'00010111' => '17',
		'00011000' => '18',
		'00011001' => '19',
		'00011010' => '1a',
		'00011011' => '1b',
		'00011100' => '1c',
		'00011101' => '1d',
		'00011110' => '1e',
		'00011111' => '1f',
		'00100000' => '20',
		'00100001' => '21',
		'00100010' => '22',
		'00100011' => '23',
		'00100100' => '24',
		'00100101' => '25',
		'00100110' => '26',
		'00100111' => '27',
		'00101000' => '28',
		'00101001' => '29',
		'00101010' => '2a',
		'00101011' => '2b',
		'00101100' => '2c',
		'00101101' => '2d',
		'00101110' => '2e',
		'00101111' => '2f',
		'00110000' => '30',
		'00110001' => '31',
		'00110010' => '32',
		'00110011' => '33',
		'00110100' => '34',
		'00110101' => '35',
		'00110110' => '36',
		'00110111' => '37',
		'00111000' => '38',
		'00111001' => '39',
		'00111010' => '3a',
		'00111011' => '3b',
		'00111100' => '3c',
		'00111101' => '3d',
		'00111110' => '3e',
		'00111111' => '3f',
		'01000000' => '40',
		'01000001' => '41',
		'01000010' => '42',
		'01000011' => '43',
		'01000100' => '44',
		'01000101' => '45',
		'01000110' => '46',
		'01000111' => '47',
		'01001000' => '48',
		'01001001' => '49',
		'01001010' => '4a',
		'01001011' => '4b',
		'01001100' => '4c',
		'01001101' => '4d',
		'01001110' => '4e',
		'01001111' => '4f',
		'01010000' => '50',
		'01010001' => '51',
		'01010010' => '52',
		'01010011' => '53',
		'01010100' => '54',
		'01010101' => '55',
		'01010110' => '56',
		'01010111' => '57',
		'01011000' => '58',
		'01011001' => '59',
		'01011010' => '5a',
		'01011011' => '5b',
		'01011100' => '5c',
		'01011101' => '5d',
		'01011110' => '5e',
		'01011111' => '5f',
		'01100000' => '60',
		'01100001' => '61',
		'01100010' => '62',
		'01100011' => '63',
		'01100100' => '64',
		'01100101' => '65',
		'01100110' => '66',
		'01100111' => '67',
		'01101000' => '68',
		'01101001' => '69',
		'01101010' => '6a',
		'01101011' => '6b',
		'01101100' => '6c',
		'01101101' => '6d',
		'01101110' => '6e',
		'01101111' => '6f',
		'01110000' => '70',
		'01110001' => '71',
		'01110010' => '72',
		'01110011' => '73',
		'01110100' => '74',
		'01110101' => '75',
		'01110110' => '76',
		'01110111' => '77',
		'01111000' => '78',
		'01111001' => '79',
		'01111010' => '7a',
		'01111011' => '7b',
		'01111100' => '7c',
		'01111101' => '7d',
		'01111110' => '7e',
		'01111111' => '7f'
	];
	private var recordObjectPersistence:ObjectPersistence<String, RecordObject>;
	public function new(connection:NamespaceKeyValueConnection) {
		this.recordObjectPersistence =
			new SerializedPersistence<String, RecordObject>(
				connection,
				"name",
				"ai",
				new Json<RecordObject>()
			);
	}

	public function delete(id:String):Void {
		this.recordObjectPersistence.delete(id);
	}

	public function get(id:String):Null<Record> {
		var ro:Null<RecordObject> = this.recordObjectPersistence.get(id);
		return ro == null ? null : Record.fromObject(ro);
	}

	public function getAll():Array<Record> {
		var results:Array<Record> = [];
		var ros = this.recordObjectPersistence.getAll();
		for(ro in ros) {
			results.push(Record.fromObject(ro));
		}
		return results;
	}

	public function getAllBy<V>(propertyName:String, propertyValue:V):Array<Record> {
		var results:Array<Record> = [];
		var ros = this.recordObjectPersistence.getAllBy(propertyName, propertyValue);
		for(ro in ros) {
			results.push(Record.fromObject(ro));
		}
		return results;
	}

	public function save(record:Record):Void {
		this.recordObjectPersistence.save(record.toObject());
	}

	private function nameToShort(name:String) {
		var output = name.charAt(0);
		for(team in ["1", "2"]) {
			var mask = this.mask(name, team);
			for(i in 0...4) {
				output += this.toHex(mask.substr(8*i, 8));
			}
		}

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

	private function toHex(mask:String):String {
		if (mask.length != 8) {
			throw "NOT CHAR";
		}

		return this.dictionary.get(mask);
	}

	private function toRow(hex:String):String {
		if (hex.length != 2) {
			throw "NOT HEX";
		}

		for (key => value in this.dictionary) {
			if (value == hex) {
				return key;
			}
		}

		return "";
	}
}
