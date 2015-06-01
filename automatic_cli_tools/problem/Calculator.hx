/**
Can you create a build macro that will turn this class into a CLI tool automatically?
**/
class Calculator {
	public function main() {
		// Run the tools!
	}

	public function new();

	/** Add 2 numbers. **/
	public function add( a:Float, b:Float ):Float {
		return a+b;
	}

	/** Subtract 2 numbers. **/
	public function subtract( a:Float, b:Float ):Float {
		return a-b;
	}

	/** Multiply 2 numbers. **/
	public function multiply( a:Float, b:Float ):Float {
		return a*b;
	}

	/** Divide 2 numbers. **/
	public function divide( a:Float, b:Float ):Float {
		return a/b;
	}
}
