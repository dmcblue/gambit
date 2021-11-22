package dmcblue.gambit;

typedef Point = {
	var x: Int;
	var y: Int;
}

abstract Position(Point) {
	public var x(get,set):Int;
	public var y(get,set):Int;

	public inline function new(x:Int, y:Int) {
		this = {
			x: x,
			y: y
		};
	}

	public function clone():Position {
		return new Position(this.x, this.y);
	}

	@:op(A == B)
	public function equals(other:Position):Bool {
		return this.x == other.x && this.y == other.y;
	}

	@:op(A + B)
	public function add(other:Position):Position {
		return new Position(this.x + other.x, this.y + other.y);
	}

	public function toString():String {
		return '{x: ${this.x}, y: ${this.y}}';
	}

	private inline function get_x():Int {  return this.x; }
    private inline function get_y():Int {  return this.y; }
    private inline function set_x(value:Int):Int {  return this.x = value; }
    private inline function set_y(value:Int):Int {  return this.y = value; }
}
