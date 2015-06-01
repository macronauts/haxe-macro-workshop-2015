/**
ObjectInitExample

We want to create lots of `Person` objects. See if you can make a macro to save some keystrokes but achieves the same thing.

Can you create a macro to save a lot of lines of code here?

The same macro should be able to be used for both "Person" and "Job" objects.
**/
class ObjectInitExample {
	static function main() {
		var person1 = new Person();
		person1.name = "Jason";
		person1.likes = [Burritos,Haxe];
		person1.job = new Job();
		person1.job.role = "Developer";
		person1.job.company = "Sheridan";
		person1.job.pay = 50;

		var person2 = new Person();
		person2.name = "Simon";
		person2.likes = [Burritos,LongWalksOnBeach];
		person2.job = new Job();
		person2.job.role = "Engineer";
		person2.job.company = "Monadlphous";
		person2.job.pay = 30;

		var person3 = new Person();
		person3.name = "Chanelle";
		person3.likes = [Netflix,LongWalksOnBeach];
		person3.job = new Job();
		person3.job.role = "Designer";
		person3.job.company = "Red Meets Blue";
		person3.job.pay = 60;

		var person4 = new Person();
		person4.name = "Justin";
		person4.likes = [Haxe,Netflix,Burritos];
		person4.job = new Job();
		person4.job.role = "IT";
		person4.job.company = "Sheridan";
		person4.job.pay = 60;

		info( person1 );
		info( person2 );
		info( person3 );
		info( person4 );
	}

	static function info(p:Person) {
		trace('$p works as a ${p.job} for ${p.job.role}/hour. They like ${p.likes.join(", ")}.');
	}
}

class Person {
	public function new() {}
	public var name:String;
	public var likes:Array<Like>;
	public var job:Job;

	function toString() return name;
}

class Job {
	public function new() {}
	public var role:String;
	public var company:String;
	public var pay:Int;
	function toString() return '$role at $company';
}

enum Like {
	Burritos;
	Haxe;
	LongWalksOnBeach;
	Netflix;
}
